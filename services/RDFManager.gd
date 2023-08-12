extends Node2D

#
#	Service for interfacing with RDF
#	We should decide fairly quickly if we want to do this in a C# script so we can use an RDF library
#

func get_texture_from_jsonld(instance, depiction_url):
	# default depiction if none set
	if depiction_url == null:
		return load(Globals.PORTRAIT_CACHE["https://raw.githubusercontent.com/Multi-User-Domain/games-transformed-jam-2023/assets/portrait/ospreyWithers.png"])
	
	if depiction_url in Globals.PORTRAIT_CACHE.keys():
		return load(Globals.PORTRAIT_CACHE[depiction_url])
	
	# read remote texture - if caller supports it
	if not instance.has_method("get_remote_image"):
		return load(Globals.PORTRAIT_CACHE["https://raw.githubusercontent.com/Multi-User-Domain/games-transformed-jam-2023/assets/portrait/ospreyWithers.png"])
	
	instance.get_remote_image(depiction_url)
	return null

func _load_from_cache(urlid):
	for cache in Globals.CACHES:
		if urlid in cache.keys():
			var save_file = File.new()
			save_file.open(cache[urlid], File.READ)
			return parse_json(save_file.get_as_text())
	
	return null

func load_from_jsonld(urlid):
	# TODO: read remote Event Urlid if not in cache
	return _load_from_cache(urlid)

func obj_through_urlid(obj):
	"""
	:return: an expanded version of the object (if it's just a urlid')
	"""
	if len(obj.keys()) == 1 and "@id" in obj:
		obj = load_from_jsonld(obj["@id"])
	return obj

func parse_health_points(jsonld_store):
	if "mudcombat:hasHealthPoints" in jsonld_store and "mudcombat:maximumP" in jsonld_store["mudcombat:hasHealthPoints"]:
		# default current HP to maximum HP
		if not "mudcombat:currentP" in jsonld_store["mudcombat:hasHealthPoints"]:
			jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:currentP"] = jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:maximumP"]
		
		# type checking of both properties
		if typeof(jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:currentP"]) == TYPE_STRING:
			jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:currentP"] = float(jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:currentP"])
		if typeof(jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:maximumP"]) == TYPE_STRING:
			jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:maximumP"] = float(jsonld_store["mudcombat:hasHealthPoints"]["mudcombat:maximumP"])
		
	# default value for both health points if not included
	else:
		jsonld_store["mudcombat:hasHealthPoints"] = {
			"mudcombat:maximumP": Globals.DEFAULT_AVATAR_HP,
			"mudcombat:currentP": Globals.DEFAULT_AVATAR_HP
		}
	return jsonld_store
