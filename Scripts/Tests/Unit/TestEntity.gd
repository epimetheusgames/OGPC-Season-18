# Owned by: carsonetb
extends GutTest

var test_entity: Entity

func before_each():
	test_entity = Entity.new()

func test_defaults():
	assert_eq(test_entity.entity_type, "Entity")
	assert_eq(test_entity._has_physics, false)
	assert_eq(test_entity.has_multiplayer_sync, true)
	assert_eq(test_entity.sync_by_increment, false)
	assert_eq(test_entity.node_owner, 0, "Entity should be owned by the server by default.")
	assert_eq(test_entity.components_dictionary, {})

func test_uid_generation():
	test_entity._process(0.0166)
	assert_true(test_entity.uid.get("uid") != null, "Entity UID should not be null after one process call.")

func test_requiest_uid_generation():
	test_entity.update_uid()
	assert_true(test_entity.uid.get("uid") != null, "Entity UID should not be null after request that it's updated.")

func test_save_generation():
	test_entity._process(0.0166)
	assert_true(test_entity.get("save_resource") != null, "Entity save resource should not be null after one process call.")
	assert_eq(test_entity.save_resource.position, test_entity.position)
	assert_eq(test_entity.save_resource.velocity, test_entity.velocity)
	
	test_entity.position = Vector2(5, 10)
	test_entity.velocity = Vector2(-1, 0)
	test_entity._process(0.0166)
	assert_eq(test_entity.save_resource.position, test_entity.position)
	assert_eq(test_entity.save_resource.velocity, test_entity.velocity)

func test_has_component():
	var new_component := HealthComponent.new()
	test_entity.add_child(new_component)
	test_entity.add_component("HealthComponent", new_component)
	assert_true(test_entity.has_component("HealthComponent"), "Entity should report that it has a specific component.")

func test_get_component():
	var new_component := HealthComponent.new()
	test_entity.add_child(new_component)
	test_entity.add_component("HealthComponent", new_component)
	assert_eq(test_entity.get_component("HealthComponent"), new_component)

func test_setters():
	test_entity.set_new_velocity(Vector2(10, 10))
	assert_eq(test_entity.velocity, Vector2(10, 10))
	
	test_entity.enable_physics()
	assert_eq(test_entity._has_physics, true)
	
	test_entity.disable_physics()
	assert_eq(test_entity._has_physics, false)

func test_getters():
	assert_eq(test_entity.get_entity_type(), "Entity")
