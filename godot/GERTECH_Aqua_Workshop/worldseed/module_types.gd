class_name ModuleTypes
extends RefCounted

# Strings are the stable wire/save identifiers. The enum is convenient for tools.
enum Type { EMPTY, ORE, SOIL, SALVAGE, PURE_COMPONENT, ALLOY, CORE, PACKED_BLOCK, FORGED_BLANK }
enum Joint { STRUCTURAL, CONDUCTIVE, FLEXIBLE, PIPE, DATA }
const MODULES := ["empty", "ore", "soil", "salvage", "pure_component", "alloy", "core", "packed_block", "forged_blank"]
const JOINTS := ["structural", "conductive", "flexible", "pipe", "data"]
