extends Resource
class_name FilePathResource

@export_file var file

static func create(file: String):
	var out := FilePathResource.new()
	out.file = file
	return out
