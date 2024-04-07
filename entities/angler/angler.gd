class_name Angler
extends CharacterBody3D

signal shrimp_eaten
signal dead
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var spring_arm_pivot: Node3D = $SpringArmPivot
@onready var spring_arm_3d: SpringArm3D = $SpringArmPivot/SpringArm3D
@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D
@onready var light_holder: Node3D = $LightHolder
@onready var chomp_timer: Timer = $ChompTimer
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var charged: Label = $CanvasLayer/Charged
@onready var stun_area: Area3D = $StunArea
@onready var flash: ColorRect = $CanvasLayer/Flash
@onready var health_bar: ProgressBar = $CanvasLayer/HealthBar
@onready var ui_animator: AnimationPlayer = $UIAnimator
@onready var chomp_audio: AudioStreamPlayer3D = $ChompAudio
@onready var hurt_audio: AudioStreamPlayer3D = $HurtAudio
@onready var charge_audio: AudioStreamPlayer3D = $ChargeAudio
@onready var flash_audio: AudioStreamPlayer3D = $FlashAudio
@onready var health_reduction_timer: Timer = $HealthReductionTimer
@onready var health_label: Label = $CanvasLayer/HealthBar/HealthLabel


var stalk_bone_name: String = "stalk.end"
var current_charge_time: float = 0
var max_charge: float = 1
var look_sensitivity: float = ProjectSettings.get_setting("player/look_sensitivity")
var max_health: float = 100
var health: float = 100

var light_is_on: bool = true
var dying: bool = true

@export_category("Angler Parameters")
@export var swim_speed: float = 500
@export var charge_speed: float = 0.5
@export var turn_speed: float = 2
@onready var chomp_area: Area3D = $ChompArea

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	progress_bar.max_value = max_charge
	health_bar.value = health

func _physics_process(delta: float) -> void:	
	var movement_direction: float = Input.get_axis("swim_backward", "swim_forward")
	var turn_direction: float = Input.get_axis("turn_right", "turn_left")
	var forward_vector = global_transform.basis.z.normalized()
	velocity = forward_vector * movement_direction * swim_speed * delta * (0.5 if movement_direction < 0 else 1)
	rotate_y(turn_direction * delta * turn_speed)
	animation_tree["parameters/swim_dir/blend_amount"] = movement_direction
	global_position.y = 6.5
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * look_sensitivity)
		spring_arm_3d.rotate_x(-event.relative.y * look_sensitivity)
		spring_arm_pivot.rotation.x = clamp(spring_arm_pivot.rotation.x, -PI/4, PI/4)
	if Input.is_action_pressed("chomp") and chomp_timer.is_stopped():
		attempt_chomp()
	if Input.is_action_just_released("charge_light"):
		attempt_stun()
		light_is_on = true

func _process(delta: float) -> void:
	handle_light_follow_stalk_bulb()
	progress_bar.value = current_charge_time
	
	if Input.is_action_pressed("charge_light"):
		current_charge_time = min(max_charge, current_charge_time + charge_speed * delta)
		animation_tree["parameters/light_blend/blend_amount"] = current_charge_time
		if charge_audio.playing == false:
			charge_audio.play()
	if current_charge_time >= max_charge:
		light_is_on = false
		charged.show()
	else:
		charged.hide()

func handle_light_follow_stalk_bulb() -> void:
	# Get the global pose of the bone
	var bonePose = skeleton_3d.get_bone_global_pose(skeleton_3d.find_bone(stalk_bone_name))
	# Update the position of the node to follow the bone
	light_holder.position = bonePose.origin
	light_holder.position += Vector3(0,-0.5,0.2)

func attempt_stun() -> void:
	flash_audio.play()
	charge_audio.stop()
	# try to stun if fully charged
	if current_charge_time == progress_bar.max_value:
		animation_tree["parameters/release_os/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		flash.color = Color(1,1,1,0.4)
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(flash, "color", Color(1,1,1,0), 1)
		var potential_stun_targets: Array[Node3D] = stun_area.get_overlapping_bodies()
		for body in potential_stun_targets:
			if body is Shrimp:
				body.stun()
	# reset things to normal
	current_charge_time = 0
	animation_tree["parameters/light_blend/blend_amount"] = 0
	
func attempt_chomp() -> void:
	animation_tree["parameters/chomp_os/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	chomp_audio.play()
	chomp_timer.start()
	for body: Node3D in chomp_area.get_overlapping_bodies() as Array[Node3D]:
		if body is Shrimp:
			body.die(self)
			shrimp_eaten.emit()
			#heal when you eat a shrimp
			health = min(max_health, health + 10)

func take_damage(value:float) -> void:
	health -= value
	health_bar.value = health
	health_label.text = "Health: %s" % health
	if value >= 3:
		ui_animator.play("take_damage")
		hurt_audio.play()
	if health <= 0:
		dead.emit()
		queue_free()


func _on_health_reduction_timer_timeout() -> void:
	var value = 2 if dying else 0
	take_damage(value)

func stop_dying() -> void:
	dying = false
