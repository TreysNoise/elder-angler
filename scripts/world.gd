extends Node

@onready var instructions: Label = $CanvasLayer/LiveGame/Instructions
@onready var live_game: Control = $CanvasLayer/LiveGame
@onready var game_over: Control = $CanvasLayer/GameOver
@onready var victory: Control = $CanvasLayer/Victory
@onready var score_label: Label = $CanvasLayer/LiveGame/ScoreLabel
var score: float = 0
var max_score: float = 25

func _ready() -> void:
	live_game.show()
	var tween = get_tree().create_tween()
	tween.tween_property(instructions, "modulate", Color(1,1,1,0), 10)
	
func _on_angler_shrimp_eaten() -> void:
	score += 1
	score_label.text = "Shrimp Eaten: %s / %s" % [score, max_score]
	if score >= max_score:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		victory.show()
		live_game.hide()

func _on_angler_dead() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over.show()
	live_game.hide()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()	
