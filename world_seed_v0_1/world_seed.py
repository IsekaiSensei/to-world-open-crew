"""TO WORLD construction DNA / reproducible world seed (Python 3.10+; no third-party libs).

Prototype rules; this does not convert JPEGs/video into reliable 3D geometry.
"""
from __future__ import annotations
import copy
import hashlib
import json
import math
import os
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent


class SeedError(ValueError):
    pass


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def rotate_y(v, yaw_deg):
    """Exactly supported discrete yaw orientations, right handed Y-up."""
    x, y, z = v
    yaw = yaw_deg % 360
    if yaw == 0: return [x, y, z]
    if yaw == 90: return [-z, y, x]
    if yaw == 180: return [-x, y, -z]
    if yaw == 270: return [z, y, -x]
    raise SeedError("Only 0/90/180/270 degree yaw is implemented")


def world_port(instance, port):
    p = instance["pose"]
    rp = rotate_y(port["point"], p["yaw_deg"])
    return ([p["position"][i] + rp[i] for i in range(3)],
            rotate_y(port["normal"], p["yaw_deg"]))


def close3(a, b, tolerance=1e-6):
    return all(abs(a[i]-b[i]) <= tolerance for i in range(3))


def validate_assembly(seed, catalog, require_complete=True):
    """Validate syntax + references + every explicit port constraint.

    Structural loads, fluid flow and thermal properties are NOT certified by this.
    """
    if seed.get("schema_version") != "0.1.0": raise SeedError("Unsupported construction DNA version")
    if require_complete and seed.get("status") == "incomplete":
        raise SeedError("Source assembly has unresolved modules/placements; exact rebuild blocked")
    if len(seed.get("instances", [])) != len({i.get("id") for i in seed.get("instances", [])}):
        raise SeedError("Duplicate instance ID")
    templates = catalog["templates"]
    ins = {i["id"]: i for i in seed["instances"]}
    for i in ins.values():
        if i["template"] not in templates: raise SeedError("Unknown template: " + i["template"])
        if i["material"] not in catalog["materials"]: raise SeedError("Unknown material: " + i["material"])
        if len(i["pose"]["position"]) != 3: raise SeedError("Expected XYZ pose")
        rotate_y([1,0,0], i["pose"]["yaw_deg"])
        ports = templates[i["template"]]["ports"]
        if set(i.get("faces", {})) - set(ports): raise SeedError("Unknown face state port")
    occupied = set()
    for e in seed["connections"]:
        ai, ap = e["a"]; bi, bp = e["b"]
        if ai == bi: raise SeedError("Self connection forbidden")
        if ai not in ins or bi not in ins: raise SeedError("Dangling connection instance")
        if (ai, ap) in occupied or (bi, bp) in occupied: raise SeedError("Port already connected")
        apt = templates[ins[ai]["template"]]["ports"].get(ap)
        bpt = templates[ins[bi]["template"]]["ports"].get(bp)
        if apt is None or bpt is None: raise SeedError("Unknown port")
        if apt["lock"] != bpt["lock"]: raise SeedError("Mismatched joint family")
        ch = e["channels"]
        if not ch or len(ch) != len(set(ch)) or not set(ch).issubset(set(apt["channels"]) & set(bpt["channels"])):
            raise SeedError("Channels unsupported by both ports")
        pa, na = world_port(ins[ai], apt)
        pb, nb = world_port(ins[bi], bpt)
        if not close3(pa, pb): raise SeedError("Ports are not co-located: " + ai + "/" + bi)
        if not close3(na, [-v for v in nb]): raise SeedError("Port normals do not oppose")
        occupied.add((ai, ap)); occupied.add((bi, bp))
    return True


def structural_path(seed, source, destination):
    edges = {}
    for e in seed["connections"]:
        if "structure" not in e["channels"]: continue
        a, b = e["a"][0], e["b"][0]
        edges.setdefault(a, set()).add(b)
        edges.setdefault(b, set()).add(a)
    seen = {source}
    todo = [source]
    for x in todo:
        if x == destination: return True
        for n in sorted(edges.get(x, [])):
            if n not in seen:
                seen.add(n); todo.append(n)
    return False


def infer_roles(seed, catalog):
    """A role emerges from the connected graph + environment; never from `geom:cube_frame`."""
    validate_assembly(seed, catalog)
    instances = {i["id"]: i for i in seed["instances"]}
    anchors = [i["id"] for i in instances.values() if "ground_anchor" in i.get("world_tags", [])]
    result = []
    if len(anchors) >= 2:
        for n, a in enumerate(anchors):
            for b in anchors[n+1:]:
                if not structural_path(seed, a, b): continue
                # Prototype checks that all vertices in the traversed assembly claim walkable deck.
                # This is not a real collision or structural load analysis.
                if all("walkable_surface" in i.get("world_tags", []) for i in instances.values()):
                    result.append("bridge_candidate"); break
            if result: break
    has_drive = any("thrust_when_powered" in catalog["templates"][i["template"]]["intrinsic_capabilities"] and i.get("state",{}).get("active") for i in instances.values())
    if has_drive: result.append("propulsion_equipped_candidate")
    has_relay = any("ether_transport_when_powered" in catalog["templates"][i["template"]]["intrinsic_capabilities"] and i.get("state",{}).get("active") for i in instances.values())
    if has_relay: result.append("relay_equipped_candidate")
    return result or ["unclassified_connected_assembly"]


def construction_dna(seed):
    """Snapshot topology, state, material and pose—not renderer preferences."""
    if seed.get("status") == "incomplete": raise SeedError("Cannot scan an incomplete source into an exact rebuild blueprint")
    data = {k: copy.deepcopy(seed[k]) for k in ("schema_version", "instances", "connections")}
    # World placement is not a blueprint property. Normalize every pose against
    # a deterministic anchor to preserve DNA under rigid translations.
    if data["instances"]:
        anchor = min(data["instances"], key=lambda i: i["id"])["pose"]["position"][:]
        for i in data["instances"]:
            i["pose"]["position"] = [round(i["pose"]["position"][k] - anchor[k], 8) for k in range(3)]
        data["instances"].sort(key=lambda i: i["id"])
    data["connections"].sort(key=canonical)
    return hashlib.sha256(canonical(data).encode("utf-8")).hexdigest()


def scan(seed, catalog, library):
    validate_assembly(seed, catalog)
    dna = construction_dna(seed)
    library.setdefault("blueprints", {})[dna] = {
        "dna": dna, "seed": copy.deepcopy(seed), "source_seed_id": seed["seed_id"],
        "reusable": True, "requires_inventory": False,
        "usage": "in_game_blueprint_not_real_world_ownership_claim"
    }
    return dna


def dog_build(library, dna, catalog, build_id, destination):
    """Blueprint-first, no scavenging/part quantities; actual hardware fabrication not implemented."""
    b = library["blueprints"][dna]
    seed = copy.deepcopy(b["seed"])
    validate_assembly(seed, catalog)
    seed["seed_id"] = build_id
    seed["built_from_dna"] = dna
    seed["galactic_ether_relay"] = {"destination": destination, "status": "delivery_requested"}
    operations = [{"op": "synthesize_module", "id": i["id"], "template": i["template"]} for i in seed["instances"]]
    operations += [{"op": "lock_ports", "a": e["a"], "b": e["b"], "channels": e["channels"]} for e in seed["connections"]]
    operations.append({"op": "deliver_via_galactic_ether_relay", "destination": destination})
    job = {"builder": "to-dog:seed-engine", "build_id": build_id, "source_dna": dna,
           "inventory_reads": 0, "inventory_consumption": 0, "build_plan": operations}
    return seed, job


def move_assembly(seed, offset, new_id=None):
    result = copy.deepcopy(seed)
    for i in result["instances"]:
        i["pose"]["position"] = [i["pose"]["position"][k] + offset[k] for k in range(3)]
    if new_id: result["seed_id"] = new_id
    return result


def reskin_copy(seed, material, catalog, new_id):
    if material not in catalog["materials"]: raise SeedError("Unknown material")
    upgraded = copy.deepcopy(seed)
    upgraded["seed_id"] = new_id
    for i in upgraded["instances"]: i["material"] = material
    upgraded["derived_from"] = seed["seed_id"]
    return upgraded


def save_json_atomic(path, obj):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(obj, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")
    os.replace(temp, path)


def demo(path):
    catalog = read_json(HERE/"module_catalog.json")
    seed = read_json(path)
    library = {"blueprints": {}}
    dna = scan(seed, catalog, library)
    a, job_a = dog_build(library, dna, catalog, "build:bridge:001", "world:moon:x10")
    b, job_b = dog_build(library, dna, catalog, "build:bridge:002", "world:dog:y20")
    relocated = move_assembly(b, [10, 0, -2])
    assert validate_assembly(relocated, catalog)
    assert construction_dna(seed) == construction_dna(library["blueprints"][dna]["seed"])
    return {"source_dna":dna,"inferred_roles":infer_roles(a,catalog),
            "independent_build_ids":[a["seed_id"],b["seed_id"]],
            "dog_operations_per_build":[len(job_a["build_plan"]),len(job_b["build_plan"])],
            "inventory_consumption":job_a["inventory_consumption"],"relocated_valid":True}


if __name__ == "__main__":
    print(json.dumps(demo(sys.argv[1] if len(sys.argv) > 1 else HERE/"examples/bridge_seed.json"), indent=2))