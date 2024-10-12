class_name EnemyBehaviorSettings
extends Resource


@export var health: int
@export var damage: int
@export_range(0, 1) var agressiveness: float
@export var attack_distance: float
@export var sensor_type: SENSOR_TYPE
@export var wander_type: WANDER_TYPE

@export_group("Random Wander Settings")
@export var wander_range: float

@export_group("View Sensor Settings")
@export_range(0, 360) var view_range
@export var view_distance: float

@export_group("Sound Sensor Settings")
@export var sound_max_distance: float

enum SENSOR_TYPE {LIGHT, MOTION, NOISE}
enum WANDER_TYPE {RANDOM_POSITION, ATTACH_TO_WALL}
