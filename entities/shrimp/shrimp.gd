class_name Shrimp
extends RigidBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stun_timer: Timer = $StunTimer
@onready var dazed_effect: Sprite3D = $DazedEffect
@onready var area_check_timer: Timer = $AreaCheckTimer
@onready var jet_timer: Timer = $JetTimer
@onready var view_area: Area3D = $ViewArea

var jet_speed: float = 12

var stunned: bool = false

func jet(body: Node3D) -> void:
	# turn towards player
	look_at(body.position)
	rotate_y(PI)
	# play jet animation
	animation_player.play("jet")
	# apply impulse
	var randomness: Vector3 = Vector3(randf_range(0.9,1.1), 0, randf_range(0.9,1.1))
	var jet_direction: Vector3 = (body.position * randomness).direction_to(position).normalized()
	apply_impulse(jet_direction * jet_speed)
	#start jet cooldown
	jet_timer.start()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "jet":
		animation_player.play("idle")

func _on_view_area_body_entered(body: Node3D) -> void:
	if body is Angler:
		if body.light_is_on:
			jet(body)

func stun() -> void:
	freeze = true
	dazed_effect.show()
	stun_timer.start()

func _on_stun_timer_timeout() -> void:
	freeze = false
	dazed_effect.hide()

func die(body: Node3D) -> void:
	apply_impulse(position.direction_to(body.position).normalized())
	queue_free()
	


func _on_area_check_timer_timeout() -> void:
	# every timeout, check if a body is still in the area
	if view_area.has_overlapping_bodies() and jet_timer.is_stopped():
		var bodies = view_area.get_overlapping_bodies()
		for body in bodies:
			_on_view_area_body_entered(body)

func is_overlapping_with_area() -> bool:
	return view_area.has_overlapping_areas()
