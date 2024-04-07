class_name Vent
extends StaticBody3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var explode_timer: Timer = $ExplodeTimer
@onready var smoke_timer: Timer = $SmokeTimer
@onready var hurt_box: Area3D = $HurtBox
@onready var deal_damage_timer: Timer = $DealDamageTimer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	explode_timer.wait_time = randi_range(2,explode_timer.wait_time)

func _physics_process(delta: float) -> void:
	if cpu_particles_3d.emitting:
		if hurt_box.has_overlapping_bodies():
			for body in hurt_box.get_overlapping_bodies():
				if body is Angler and deal_damage_timer.is_stopped():
					body.take_damage(10)
					deal_damage_timer.start()

func _on_explode_timer_timeout() -> void:
	animation_player.play("explode")
	explode_timer.wait_time = randi_range(5,10)
	smoke_timer.start()

func _on_smoke_timer_timeout() -> void:
	cpu_particles_3d.restart()
	audio_stream_player_3d.play()
