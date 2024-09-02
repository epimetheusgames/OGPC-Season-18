class_name Enemy
extends CharacterBody2D

const IFRAME_DURATION: float = 0.25 # In seconds

var health : float

var iframes_active: bool = false


func _physics_process(delta: float) -> void:
	pass

func take_damage(amount: float, cares_about_iframes : bool) -> void:
	if !iframes_active or !cares_about_iframes:
		health -= amount
		iframes_on(IFRAME_DURATION)
		
		if health <= 0:
			pass
			# Whatever you want to do when you die

func iframes_on(duration_in_seconds: float) -> void:
	iframes_active = true
	await get_tree().create_timer(duration_in_seconds).timeout
	iframes_active = false
