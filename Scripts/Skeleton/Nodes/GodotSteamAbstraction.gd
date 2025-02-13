# Owned by: carsonetb
class_name GodotSteamAbstraction
extends Node


const PACKET_READ_LIMIT: int = 100

var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var lobby_data
var lobby_id: int = 0
var lobby_members: Array = []
var lobby_members_max: int = 4
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""
var lobbies_list: Array[Array] = []
var lobby_owner: int = 0
var is_lobby_owner := false
var handshake_completed_ids: Array[int] = []
var new_lobby_name: String
var new_lobby_mode: String
var packets_queue: Dictionary = {}

# VC
var current_sample_rate: int = 48000
var has_loopback: bool = false
var local_playback: AudioStreamGeneratorPlayback = null
var local_voice_buffer: PackedByteArray = PackedByteArray()
var network_playback: AudioStreamGeneratorPlayback = null
var network_voice_buffer: PackedByteArray = PackedByteArray()
var packet_read_limit: int = 5

@export var local_player: AudioStreamPlayer
@export var networked_player: AudioStreamPlayer

signal lobby_joined
signal user_joined_lobby(user_id, user_name)
signal handshake_received(user_id, user_name)

func _init() -> void:
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))
	Global.godot_steam_abstraction = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Tests for GodotSteam stun
	# Initialize steam
	var initialize_response: Dictionary = Steam.steamInitEx()
	if Global.verbose_debug:
		print("DEBUG: Steam initialization status: %s " % initialize_response)
	
	if initialize_response["status"] > 0:
		print("ERROR: Failed to initialize Steam, shutting down.") 
		get_tree().quit()
	
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	
	# P2P connect
	Steam.p2p_session_request.connect(_on_session_request)
	Steam.p2p_session_connect_fail.connect(_on_session_connect_fail)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.persona_state_change.connect(_on_persona_change)
	
	# Check for command line arguments
	check_command_line()
	
	# Fetch lobby list, calls a signal.
	get_lobby_list()
	
	# Start up packet sender
	sync_packets()
	
	# Voice chat
	if local_player:
		local_player.stream.mix_rate = current_sample_rate
		local_player.play()
		local_playback = local_player.get_stream_playback()
	
	if networked_player:
		networked_player.stream.mix_rate = current_sample_rate
		networked_player.play()
		network_playback = networked_player.get_stream_playback()
	
	record_voice(true)
	
	#if "host" in OS.get_cmdline_args():
		#create_lobby("TEST", "GodotSteam TEST")
	#if "client" in OS.get_cmdline_args():
		#get_lobby_list()
		#await Steam.lobby_match_list
		#
		## TODO: This variable will be used at some point.
		#var _lobby_join_id: int = 0
		#for lobby in lobbies_list:
			#if lobby[1] == "TEST":
				#join_lobby(lobby[0])
				#lobby_joined.emit()

func record_voice(is_recording: bool) -> void:
	# If talking, suppress all other audio or voice comms from the Steam UI
	Steam.setInGameVoiceSpeaking(steam_id, is_recording)

	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
	check_for_voice()
	
	if lobby_id > 0:
		read_all_packets()

func ext_join_lobby(lobby_index: int):
	join_lobby(lobbies_list[lobby_index][0])
	lobby_joined.emit()

func get_lobby_list() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	
	if Global.verbose_debug:
		print("DEBUG: Requesting lobby list.")
	Steam.requestLobbyList()

func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	
	if these_arguments.size() > 0 && these_arguments[0] == "+connect_lobby" && int(these_arguments[1]) > 0:
		if Global.verbose_debug:
			print("DEBUG: Command line lobby ID: %s" % these_arguments[1])
		join_lobby(int(these_arguments[1]))

func create_lobby(lobby_name: String, lobby_mode: String) -> void:
	if lobby_id == 0:
		new_lobby_name = lobby_name
		new_lobby_mode = lobby_mode
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)

func join_lobby_by_name(name: String):
	get_lobby_list()
	await Steam.lobby_match_list
	
	if Global.verbose_debug:
		print("DEBUG: Fetched lobby list.")
	
	for lobby in lobbies_list:
		if Global.verbose_debug:
			print("DEBUG: Found lobby with data: " + str(lobby))
		if lobby[1] == name:
			join_lobby(lobby[0])
			lobby_joined.emit()
			return
	
	print("WARNING: Lobby not found.")

func join_lobby(this_lobby_id: int) -> void:
	if Global.verbose_debug:
		print("DEBUG: Attempting to join lobby %s" % this_lobby_id)
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)

func leave_lobby() -> void:
	if lobby_id != 0:
		Steam.leaveLobby(lobby_id)
		lobby_id = 0
		
		for this_member in lobby_members:
			if this_member["steam_id"] != steam_id:
				Steam.closeP2PSessionWithUser(this_member["steam_id"])
		
		lobby_members.clear()

# Write this later, it's when accepting a notification from steam.
func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	pass

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		get_lobby_members()
		make_handshake()
		lobby_owner = Steam.getLobbyOwner(lobby_id)
		is_lobby_owner = lobby_owner == steam_id
		Global.is_multiplayer = true
		
		for member in lobby_members:
			user_joined_lobby.emit(member["steam_id"], member["steam_name"])
	else:
		print("ERROR: Failed to join the lobby, but I'm not gonna tell you what the error is.")
		print("ERROR: Fine, I'll at least tell you the number, it's %s" % response)

func _on_lobby_created(connect_info: int, this_lobby_id: int) -> void:
	if connect_info == 1:
		lobby_id = this_lobby_id
		if Global.verbose_debug:
			print("DEBUG: Created a lobby: %s" % lobby_id)
		
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyData(lobby_id, "name", new_lobby_name)
		Steam.setLobbyData(lobby_id, "mode", new_lobby_mode)
		
		user_joined_lobby.emit(steam_id, Steam.getFriendPersonaName(steam_id))
		
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		if Global.verbose_debug:
			print("DEBUG: Allowing Steam to relay backup: %s" % set_relay)

func _on_lobby_match_list(these_lobbies: Array) -> void:
	if Global.verbose_debug:
		print("DEBUG: Lobby list fetched, printing below.")
	lobbies_list = []
	for this_lobby in these_lobbies:
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var formatted_lobby_data := [this_lobby, lobby_name, lobby_mode, lobby_num_members]
		lobbies_list.append(formatted_lobby_data)
		if Global.verbose_debug && lobby_mode == "DivingGameLobby":
			print("DEBUG: Name: " + lobby_name)

func read_all_packets(read_count: int = 0):
	if read_count >= PACKET_READ_LIMIT:
		printerr("WARNING: Packet read count is greater than packet read limit")
		return
	
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_packet()
		read_all_packets(read_count + 1)

func _on_session_request(remote_id: int) -> void:
	# Get the requester's name
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	
	if Global.verbose_debug:
		print("DEBUG: %s is requesting a P2P session" % this_requester)
	
	Steam.acceptP2PSessionWithUser(remote_id)
	
	make_handshake()

func _on_session_connect_fail(failed_steam_id: int, session_error: int) -> void:
	print("ERROR: Steam connect failed for target %s, the error code is %s, go figure out what it means for yourself." % [failed_steam_id, session_error])

func _on_persona_change(this_steam_id: int, _flag: int) -> void:
	if lobby_id > 0:
		get_lobby_members()

func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	var changer_name: String = Steam.getFriendPersonaName(change_id)
	
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		if Global.verbose_debug:
			print("DEBUG: %s has joined the lobby." % changer_name)
		user_joined_lobby.emit(change_id, changer_name)
	
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT && Global.verbose_debug:
		print("DEBUG: %s has left the lobby." % changer_name)
	
	get_lobby_members()

# Sets lobby_members array.
func get_lobby_members() -> void:
	lobby_members.clear()
	
	var num_members: int = Steam.getNumLobbyMembers(lobby_id)
	for this_member in range(num_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		lobby_members.append({"steam_id": member_steam_id, "steam_name": member_steam_name})

func make_handshake():
	if Global.verbose_debug:
		print("DEBUG: Sending P2P handshake to the lobby.")
	send_packet("HANDSHAKE", {"message": "handshake", "from": steam_id})

func sync_var(node: Node, variable_name: String) -> void:
	send_packet(str(node.get_path())+variable_name, {
		"message": "sync_var",
		"node_path": node.get_path(),
		"var_name": variable_name,
		"var_val": node.get(variable_name)
	})

func sync_var_in_group(group: String, variable_name: String) -> void:
	var variables = []
	for node in get_tree().get_nodes_in_group(group):
		variables.append(node.get(variable_name))
		
	send_packet(group+variable_name, {
		"message": "sync_group_var",
		"group": group,
		"var_name": variable_name,
		"var_values": variables
	})

func run_remote_function(node: Node, function_name: String, args: Array, args_as_node_paths=false):
	send_packet(str(node.get_path())+function_name, {
		"message": "run_function",
		"node_path": node.get_path(),
		"func_name": function_name,
		"args": args,
		"args_as_node_paths": args_as_node_paths,
	})

func read_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		
		if this_packet.is_empty() || this_packet == null && Global.verbose_debug:
				printerr("WARNING: Read an empty packet with non-zero size!")
		
		var packet_sender: int = this_packet["remote_steam_id"]
		var packet_code: PackedByteArray = this_packet["data"]
		var readable_data: Dictionary = bytes_to_var(packet_code.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))
		
		parse_readable_data(readable_data, packet_sender)

func check_for_voice() -> void:
	var available_voice: Dictionary = Steam.getAvailableVoice()

	# Seems there is voice data
	if available_voice['result'] == Steam.VOICE_RESULT_OK and available_voice['buffer'] > 0:
		# Valve's getVoice uses 1024 but GodotSteam's is set at 8192?
		# Our sizes might be way off; internal GodotSteam notes that Valve suggests 8kb
		# However, this is not mentioned in the header nor the SpaceWar example but -is- in Valve's docs which are usually wrong
		var voice_data: Dictionary = Steam.getVoice()
		if voice_data['result'] == Steam.VOICE_RESULT_OK and voice_data['written']:
			print("Voice message has data: %s / %s" % [voice_data['result'], voice_data['written']])

			# Here we can pass this voice data off on the network
			#send_raw_data(voice_data['buffer'])

			# If loopback is enable, play it back at this point
			if has_loopback:
				print("Loopback on")
				process_voice_data(voice_data, "local")

func get_sample_rate() -> void:
	current_sample_rate = Steam.getVoiceOptimalSampleRate()
	print("Current sample rate: %s" % current_sample_rate)
	local_player.stream.mix_rate = current_sample_rate
	networked_player.stream.mix_rate = current_sample_rate
	print("Current sample rate: %s" % current_sample_rate)

func process_voice_data(voice_data: Dictionary, voice_source: String) -> void:
	# Our sample rate function above without toggling
	get_sample_rate()

	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data['buffer'], Steam.getVoiceOptimalSampleRate())
	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		print("Decompressed voice: %s" % decompressed_voice['size'])

		if voice_source == "local":
			local_voice_buffer = decompressed_voice['uncompressed']
			local_voice_buffer.resize(decompressed_voice['size'])

			# We now iterate through the local_voice_buffer and push the samples to the audio generator
			for i: int in range(0, mini(local_playback.get_frames_available() * 2, local_voice_buffer.size()), 2):
				# Steam's audio data is represented as 16-bit single channel PCM audio, so we need to convert it to amplitudes
				# Combine the low and high bits to get full 16-bit value
				var raw_value: int = local_voice_buffer[0] | (local_voice_buffer[1] << 8)
				# Make it a 16-bit signed integer
				raw_value = (raw_value + 32768) & 0xffff
				# Convert the 16-bit integer to a float on from -1 to 1
				var amplitude: float = float(raw_value - 32768) / 32768.0

				# push_frame() takes a Vector2. The x represents the left channel and the y represents the right channel
				local_playback.push_frame(Vector2(amplitude, amplitude))

				# Delete the used samples
				local_voice_buffer.remove_at(0)
				local_voice_buffer.remove_at(0)

func parse_readable_data(readable_data: Dictionary, packet_sender: int) -> void:
	if readable_data["message"] == "handshake":
		if Global.verbose_debug:
			print("DEBUG: Handshake received from " + Steam.getFriendPersonaName(readable_data["from"]))
		handshake_completed_ids.append(packet_sender)
		handshake_received.emit(packet_sender, Steam.getFriendPersonaName(readable_data["from"]))
	
	elif readable_data["message"] == "remote_print":
		print("REMOTE DEBUG: " + readable_data["content"])
	
	# Loop through all packets if it's a packet group.
	elif readable_data["message"] == "packet_group":
		for packet in readable_data["packets"]:
			parse_readable_data(packet, packet_sender)
	
	# Parse packet if it's node data.
	elif readable_data["message"] == "sync_var":
		var node_path: String = readable_data["node_path"]
		var variable_name: String = readable_data["var_name"]
		var variable_value = readable_data["var_val"]
		if get_node_or_null(node_path):
			get_node(node_path).set(variable_name, variable_value)
		elif Global.verbose_debug:
			print("ERROR: Remote set on null node. This isn't neccesarily bad but it might mean some things are out of synced and something broke.")
			print("DEBUG: The path was " + str(node_path))
	
	elif readable_data["message"] == "sync_group_var":
		var nodes_list = get_tree().get_nodes_in_group(readable_data["group"])
		for node_index in range(nodes_list.size()):
			nodes_list[node_index].set(readable_data["var_name"], readable_data["var_values"][node_index])
	
	elif readable_data["message"] == "run_function":
		var node_path: String = readable_data["node_path"]
		var function_name: String = readable_data["func_name"]
		
		var function_args = readable_data["args"]
		if readable_data["args_as_node_paths"]:
			for i in range(len(function_args)):
				function_args[i] = get_node(function_args[i])
				if !function_args[i] && Global.verbose_debug:
					print("ERROR: Remote function call on node has an argument to a nonexistant node path.")
					return
		
		if get_node_or_null(node_path):
			get_node(node_path).callv(function_name, function_args)
		elif Global.verbose_debug:
			print("ERROR: Remote function call on null node. This isn't neccesarily bad but it might mean some things are out of synced and something broke.")
	
	elif Global.verbose_debug:
		print("ERROR: Invalid packet received. Data: " + str(readable_data))

func send_raw_data(data: PackedByteArray):
	var send_type: int = Steam.P2P_SEND_RELIABLE
	
	# If sending a packet to everyone
	if lobby_members.size() > 1:
		# Loop through all members that aren't us
		for this_member in lobby_members:
			if this_member["steam_id"] != steam_id:
				Steam.sendP2PPacket(this_member["steam_id"], data.compress(FileAccess.COMPRESSION_GZIP), send_type, 0)

func sync_packets() -> void:
	while true:
		await get_tree().create_timer(0.05).timeout
		
		#if Global.verbose_debug:
			#print("DEBUG: Sending packets. Packet queue: " + str(packets_queue))
		
		var packet_group: Dictionary = {
			"message": "packet_group",
			"packets": [],
		}
		var packet_group_bytes: PackedByteArray
		var send_type: int = Steam.P2P_SEND_RELIABLE
		var channel: int = 0
		var num_packet_groups: int = 0
		
		for key in packets_queue.keys():
			var packet_data: Dictionary = packets_queue[key]
			var this_target: int = 0
			
			# Create a data array to send the data through
			var this_data: PackedByteArray
			
			# Compress data.
			var compressed_data: PackedByteArray = var_to_bytes(packet_data)
			this_data.append_array(compressed_data)
			
			if this_data.size() > 3000: # bytes
				print("WARNING: Packet size greater than packet size limit. Size is " + str(this_data.size()) + ". Sending anyway.")
			
			# We can group the packet up if the target is everyone.
			if this_target == 0 && lobby_members.size() > 1:
				if packet_group_bytes.size() + this_data.size() < 3000:
					packet_group["packets"].append(packet_data)
					packet_group_bytes = var_to_bytes(packet_group)
					continue
				
				# If the packet would be too big if we added them all up, send it.
				elif packet_group["packets"].size() > 0:
					num_packet_groups += 1
					for this_member in lobby_members:
						if this_member["steam_id"] != steam_id:
							Steam.sendP2PPacket(this_member["steam_id"], packet_group_bytes.compress(FileAccess.COMPRESSION_GZIP), send_type, channel)
					
					# Reset the group with the current packet.
					if this_data.size() < 3000:
						packet_group = {
							"message": "packet_group",
							"packets": [packet_data]
						}
						packet_group_bytes = var_to_bytes(packet_group)
						continue
			
			# If sending a packet to everyone
			if this_target == 0:
				# If there is more than one user, send packets
				if lobby_members.size() > 1:
					# Loop through all members that aren't us
					for this_member in lobby_members:
						if this_member["steam_id"] != steam_id:
							Steam.sendP2PPacket(this_member["steam_id"], this_data.compress(FileAccess.COMPRESSION_GZIP), send_type, channel)
			else:
				Steam.sendP2PPacket(this_target, this_data.compress(FileAccess.COMPRESSION_GZIP), send_type, channel)
		
		# Once we've looped through all the packets there's going to be a partially filled group left.
		num_packet_groups += 1
		if packet_group["packets"].size() > 0:
			for this_member in lobby_members:
				if this_member["steam_id"] != steam_id:
					Steam.sendP2PPacket(this_member["steam_id"], packet_group_bytes.compress(FileAccess.COMPRESSION_GZIP), send_type, channel)
		
		#if Global.verbose_debug:
			#print("DEBUG: Sent " + str(num_packet_groups) + " packet groups.")
		
		packets_queue = {}

# If this_target is 0, send to all peers.
func send_packet(key: String, packet_data: Dictionary) -> void:
	packets_queue[key] = packet_data
