extends Node


enum PLAY_TARGET {
	MAP = 0,
	NONE = 1,
	ANY_OBJECT = 2,
	CHARACTER = 3
}

const SH_CONFORM = {
	SHAPE_CONFORM_OBJ = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/common/shapeconform.ttl#ShapeConformObj"
}

const MUD = {
	BUILDING = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#Building",
	BUILDING_TYPE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#BuildingType",
	QUEST = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#Quest",
	QUEST_OBJECTIVE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#QuestObjective"
}

const MUD_LOGIC = {
	ACTOR_BINDING = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudlogic.ttl#ActorBinding",
	TARGET_BINDING = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudlogic.ttl#TargetBinding",
	WITNESS_BINDING = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudlogic.ttl#WitnessBinding"
}

const MUD_CHAR = {
	CHARACTER = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudchar.ttl#Character"
}

const MUD_BUILDING = {
	HOUSE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudbuildings.ttl#House",
	KITCHEN = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudbuildings.ttl#Kitchen"
}

const MUD_WORLD = {
	TILE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudworld.ttl#Tile"
}

const MUD_ITEMS = {
	TREASURE_CHEST = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/muditems.ttl#TreasureChest"
}

const SIMPOLIS = {
	PROBLEM = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/games/simpolis.ttl#Problem",
	PROBLEM_GENERATION_INSTRUCTION = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/games/simpolis.ttl#ProblemGenerationInstruction",
}

const SPECIES = {
	HUMAN = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#Human",
	VAMPIRE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudfantasy.ttl#Vampire"
}

#
#	Caches
#

const TEXTURE_CACHE = {
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/objects/house_1.png": "res://assets/objects/buildings/house_1.png",
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/card/birth.png": "res://assets/objects/card/birth.png"
}

const ACTION_CACHE = {
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/cards/spawn_fox.json": "res://assets/rdf/cards/spawn_fox.json",
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/cards/spawn_house.json": "res://assets/rdf/cards/spawn_house.json",
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/cards/spawn_kitchen.json": "res://assets/rdf/cards/spawn_kitchen.json",
}

const CHARACTER_CACHE = {
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/characters/fox.json": "res://assets/rdf/characters/fox.json"
}

const BUILDING_CACHE = {
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/buildings/house.json": "res://assets/rdf/buildings/house.json",
	"https://raw.githubusercontent.com/Multi-User-Domain/SimPolis/master/assets/rdf/buildings/kitchen.json": "res://assets/rdf/buildings/kitchen.json",
}

const CACHES = [
	TEXTURE_CACHE,
	ACTION_CACHE,
	CHARACTER_CACHE,
	BUILDING_CACHE
]
