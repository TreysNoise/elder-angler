extends Node3D
@onready var hurt_box: Area3D = $HurtBox
@onready var deal_damage_timer: Timer = $DealDamageTimer

@export var move_speed: float = 0.5
@export var move_amp: float = 5

var time_elapsed: float
var original_height: float

func _ready() -> void:
	time_elapsed = randf_range(0,30)
	original_height = position.y
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	position.y = original_height + (sin(time_elapsed * move_speed) * move_amp)

func _physics_process(delta: float) -> void:
	if hurt_box.has_overlapping_bodies():
			for body in hurt_box.get_overlapping_bodies():
				if body is Angler and deal_damage_timer.is_stopped():
					body.take_damage(10)
					deal_damage_timer.start()
