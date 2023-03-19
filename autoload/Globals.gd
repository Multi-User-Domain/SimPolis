extends Node


enum PLAY_TARGET {
	MAP = 0,
	NONE = 1,
	ANY_OBJECT = 2,
	CHARACTER = 3
}

enum PLACE_TARGET {
	NONE = 0,
	CHARACTER = 1,
	HOUSE = 2
}

const MUD = {
	BUILDING = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mud.ttl#Building"
}

const MUD_CHAR = {
	CHARACTER = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudchar.ttl#Character"
}

const MUD_BUILDING = {
	HOUSE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudbuildings.ttl#House"
}

const MUD_WORLD = {
	TILE = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/mudworld.ttl#Tile"
}

const MUD_ITEMS = {
	TREASURE_CHEST = "https://raw.githubusercontent.com/Multi-User-Domain/vocab/main/muditems.ttl#TreasureChest"
}
