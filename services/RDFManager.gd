extends Node2D

#
#	Service for interfacing with RDF
#	We should decide fairly quickly if we want to do this in a C# script so we can use an RDF library
#

func get_texture_from_jsonld(instance, depiction_url):
	# first try the cache
	if depiction_url in Globals.TEXTURE_CACHE.keys():
		return load(Globals.TEXTURE_CACHE[depiction_url])
	
	# read remote texture
	if not instance.has_method("get_remote_image"):
		# TODO: have a default way to handle this - read it ourselves, and then just set the texture without transforming it
		print("ERR: attempt to call RDFManager.get_texture_from_jsonld, without supporting get_remote_image!")
		return null
	
	# NOTE: it must be done by the caller, because the request is asynchronous and we don't want to use a signal
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
		var tmp = load_from_jsonld(obj["@id"])
		if(tmp != null):
			obj = tmp
	return obj
