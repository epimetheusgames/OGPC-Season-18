extends MissionRoot

enum State {
	START,
	POOL,
	ITEM,
	SELLING,
	BUYING,
	BUYING2,
	KILLING,
	HOUSE,
	PLACING,
	CIVILLIANS,
}

var state := State.START
@onready var dialog: NPC = $LevelContainer/TutorialDailog

func _ready():
	super._ready()
	Global.ingame_dialog.dialog("Hello, welcome to the Tutorial.")
	Global.game_time_system.pause_time = true
	Global.player.diver_inventory.building_bought.connect(bought)

func _process(delta: float) -> void:
	if state == State.START:
		state = State.POOL
		Global.ingame_dialog.dialog("Welcome to the testing enclosure. Here you will learn the basics of the game. You can start by entering the water.")
	if !Global.player.diver_movement.is_in_gravity_area && state == State.POOL:
		state = State.ITEM
		Global.ingame_dialog.dialog("Good job. Here you can swim around. On the walls there are items that you can pick up.")
	if Global.player.diver_inventory.inventory.size() > 0 && state == State.ITEM:
		state = State.SELLING
		Global.ingame_dialog.dialog("Items are sold when you enter the research station (where you started the tutorial).")
	if Global.player.diver_movement.is_in_research_station && state == State.SELLING:
		state = State.BUYING
		Global.ingame_dialog.dialog("Selling items gives you money. Collect a few more items until you have more than $10.")
	if Global.player.diver_stats.current_money > 10 && state == State.BUYING:
		state = State.BUYING2
		Global.ingame_dialog.dialog("With this money you can buy the pistol weapon in the item unlock terminal inside the research station. Select the Weapons menu, buy the pistol then select Primary Weapon.")
	if Global.player.diver_combat.primary_weapon && state == State.BUYING2:
		state = State.KILLING
		Global.ingame_dialog.dialog("Once you exit the research station you can press Q to select your weapon. If you are ever confused as to what buttons you should press, the available actions will be in the bottom right corner. Use the pistol to kill the fish")
	if $Arrowfish.state_machine.current_state.name == "Dead" && state == State.KILLING:
		state = State.HOUSE
		Global.player.diver_stats.current_money += 10
		Global.ingame_dialog.dialog("Good job! You can now return to the research station to buy a house. In the unlock terminal hit back, Items, and buy the Building.")

func bought() -> void:
	state = State.CIVILLIANS
	var follower_spawn_positions := get_tree().get_nodes_in_group("civillian_spawn_points")
	var follower_node: CivillianFollower = Global.research_station.follower.instantiate()
	var spawn_node = follower_spawn_positions.pick_random()
	spawn_node.add_child(follower_node)
	follower_node.position += Util.random_vector(Global.rng, 50, 0)
	Global.research_station.follower_spawned.emit(follower_node.global_position)
	if Global.is_multiplayer_host():
		Global.godot_steam_abstraction.run_remote_function(self, "_spawn_remote", [
			str(get_path_to(spawn_node)), 
			follower_node.global_position, 
			follower_node.name, 
			Global.game_time_system._days
		])
	Global.ingame_dialog.dialog("Outside of the research station you can select the house in your inventory to place the house. After this lead the civillian to the house. Once you house enough civillians you will win the mission.")
