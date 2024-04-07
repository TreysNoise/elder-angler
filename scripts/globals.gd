extends Node


func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().quit()
