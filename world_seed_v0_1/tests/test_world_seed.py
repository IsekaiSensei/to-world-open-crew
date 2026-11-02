import copy
import json
import sys
import tempfile
from pathlib import Path
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import world_seed as ws
HERE = Path(__file__).resolve().parents[1]

class ConstructionDNATests(unittest.TestCase):
    def setUp(self):
        self.catalog = ws.read_json(HERE/"module_catalog.json")
        self.seed = ws.read_json(HERE/"examples/bridge_seed.json")

    def test_valid_original(self):
        self.assertTrue(ws.validate_assembly(self.seed, self.catalog))
        self.assertIn("bridge_candidate", ws.infer_roles(self.seed, self.catalog))
        self.assertEqual({i["template"] for i in self.seed["instances"]}, {"geom:cube_frame"})
        self.assertNotIn("bridge", json.dumps(self.catalog["templates"]["geom:cube_frame"]["intrinsic_capabilities"]))

    def test_scan_twice_same_dna_and_dog_build_no_inventory(self):
        library = {}
        a = ws.scan(self.seed, self.catalog, library)
        b = ws.scan(self.seed, self.catalog, library)
        self.assertEqual(a,b)
        build1, job1 = ws.dog_build(library,a,self.catalog,"build:first","world:moon")
        build2, job2 = ws.dog_build(library,a,self.catalog,"build:second","world:ship")
        self.assertEqual(job1["inventory_consumption"],0)
        self.assertEqual(job1["inventory_reads"],0)
        self.assertNotEqual(build1["seed_id"],build2["seed_id"])
        self.assertEqual(self.seed, library["blueprints"][a]["seed"])

    def test_port_not_coincident_fails(self):
        s=copy.deepcopy(self.seed)
        s["instances"][1]["pose"]["position"][0]+=0.1
        with self.assertRaises(ws.SeedError):ws.validate_assembly(s,self.catalog)

    def test_port_normal_wrong_fails(self):
        s=copy.deepcopy(self.seed)
        s["instances"][1]["pose"]["yaw_deg"]=180
        with self.assertRaises(ws.SeedError):ws.validate_assembly(s,self.catalog)

    def test_channel_incompatible_fails(self):
        s=copy.deepcopy(self.seed)
        s["connections"][0]["channels"].append("fluid")
        with self.assertRaises(ws.SeedError):ws.validate_assembly(s,self.catalog)

    def test_double_occupied_port_fails(self):
        s=copy.deepcopy(self.seed)
        s["connections"].append(copy.deepcopy(s["connections"][0]))
        with self.assertRaises(ws.SeedError):ws.validate_assembly(s,self.catalog)

    def test_moving_all_modules_preserves_topology_and_dna_of_source(self):
        original_dna=ws.construction_dna(self.seed)
        moved=ws.move_assembly(self.seed,[30,20,-10],"bridge:new-location")
        ws.validate_assembly(moved,self.catalog)
        self.assertEqual(original_dna,ws.construction_dna(self.seed))
        self.assertEqual(original_dna,ws.construction_dna(moved))
        self.assertEqual(self.seed["connections"],moved["connections"])

    def test_upgrade_copy_does_not_change_original(self):
        original=copy.deepcopy(self.seed)
        revised=ws.reskin_copy(self.seed,"prism_crystal",self.catalog,"bridge:upgraded")
        ws.validate_assembly(revised,self.catalog)
        self.assertEqual(original,self.seed)
        self.assertTrue(all(i["material"]=="prism_crystal" for i in revised["instances"]))

    def test_cannot_fake_38_part_corvette(self):
        s=ws.read_json(HERE/"examples/corvette_38_source_manifest.json")
        self.assertEqual(len(s["source_module_slots"]),38)
        self.assertTrue(all(x["pose"] is None for x in s["source_module_slots"]))
        with self.assertRaises(ws.SeedError): ws.validate_assembly(s,self.catalog)
        with self.assertRaises(ws.SeedError): ws.scan(s,self.catalog,{})

    def test_atomic_save_round_trip(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/"blueprint.json"
            ws.save_json_atomic(p,self.seed)
            self.assertEqual(ws.read_json(p),self.seed)

if __name__=="__main__":unittest.main()