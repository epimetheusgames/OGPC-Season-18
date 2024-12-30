extends Node2D
class_name ModuleLoader

func load_sub(custom_sub : CustomSubmarineResource):
	for module in custom_sub.modules:
		var module_scene : SubmarineModule = load(module.module_scene.file).instantiate()
		module_scene.position = module.position
		module_scene.rotation = module.rotation
		add_child(module_scene)
