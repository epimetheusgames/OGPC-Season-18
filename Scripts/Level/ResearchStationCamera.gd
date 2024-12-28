extends Camera2D


enum CameraState {
	MISSIONS,
	SUBMARINE,
	DOCKS,
}

var camera_state: CameraState = CameraState.MISSIONS

func _on_move_right_button_button_up() -> void:
	if camera_state == CameraState.SUBMARINE:
		$MoveRightButton.disabled = true
		$MoveLeftButton.disabled = false
		camera_state = CameraState.DOCKS
	if camera_state == CameraState.MISSIONS:
		camera_state = CameraState.SUBMARINE

func _on_move_left_button_button_up() -> void:
	if camera_state == CameraState.SUBMARINE:
		$MoveRightButton.disabled = false
		$MoveLeftButton.disabled = true
		camera_state = CameraState.MISSIONS
	if camera_state == CameraState.DOCKS:
		camera_state = CameraState.SUBMARINE

func _process(delta: float) -> void:
	var target_node: Node2D
	if camera_state == CameraState.MISSIONS:
		target_node = $"../CameraPositions/Missions"
	if camera_state == CameraState.SUBMARINE:
		target_node = $"../CameraPositions/Submarine"
	if camera_state == CameraState.DOCKS:
		target_node = $"../CameraPositions/Docks"
	
	position = Util.better_vec2_lerp(position, target_node.position, 0.1, delta)
