extends Node

@onready var instructions: Label = $CanvasLayer/LiveGame/Instructions
@onready var live_game: Control = $CanvasLayer/LiveGame
@onready var game_over: Control = $CanvasLayer/GameOver
@onready var victory: Control = $CanvasLayer/Victory
@onready var score_label: Label = $CanvasLayer/LiveGame/ScoreLabel
@onready var angler: Angler = $Angler
@onready var dead_score: Label = $CanvasLayer/GameOver/ColorRect/VBoxContainer/DeadScore
@onready var alive_score: Label = $CanvasLayer/Victory/ColorRect/VBoxContainer/AliveScore

var max_score: float = 25
var time: float = 0
var started: bool = false
func _ready() -> void:
	live_game.show()
	var tween = get_tree().create_tween()
	tween.tween_property(instructions, "modulate", Color(1,1,1,0), 10)

func _process(delta: float) -> void:
	if started:
		time += delta
		score_label.text = "Seconds: %s" % snappedf(time, 0.01)

func _on_angler_dead() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	dead_score.text = "Final Time: %s" % snappedf(time, 0.01)
	game_over.show()
	live_game.hide()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()	


func _on_angler_victory() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	alive_score.text = "Final Time: %s" % snappedf(time, 0.01)
	victory.show()
	live_game.hide()


func _on_start_delay_timeout() -> void:
	started = true
