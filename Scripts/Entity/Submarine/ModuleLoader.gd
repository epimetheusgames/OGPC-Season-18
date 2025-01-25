extends Node2D
class_name ModuleLoader

func load_sub(custom_sub : CustomSubmarineResource):
	for module in custom_sub.modules:
		var module_scene : SubmarineModule = load(module.module_scene.file).instantiate()
		module_scene.position = module.position
		module_scene.rotation = module.rotation
		add_child(module_scene)

func construct_remote_sub(custom_sub: CustomSubmarineResource) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for module in custom_sub.modules:
		var module_dict := {
			"module_scene": module.module_scene.file,
			"position": module.position,
			"rotation": module.rotation,
		}
		var attachment_points: Array[Dictionary] = []
		for point in module.attachment_points:
			attachment_points.append({
				"position": point.position,
				"direction": point.direction,
				"is_attached": point.is_attached,
			})
		module_dict["attachment_points"] = attachment_points
		output.append(module_dict)
	return output

func load_sub_remote(data: Array[Dictionary]):
	var output := CustomSubmarineResource.new()
	for module in data:
		var resource := SubmarineModuleResource.new()
		resource.module_scene = FilePathResource.create(resource["module_scene"])
		resource.position = resource["position"]
		resource.rotation = resource["rotation"]
		for point in resource["attachment_points"]:
			var attachment_point = AttachmentPointResource.new()
			attachment_point.position = point["position"]
			attachment_point.direction = point["direction"]
			attachment_point.is_attached = point["is_attached"]
			resource.attachment_points.append(attachment_point)
		output.modules.append(resource)
	
	load_sub(output)
