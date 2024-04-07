extends Node3D
@onready var label: Label = $CanvasLayer/Label
@onready var jellyfish: Node3D = $Jellyfish


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "pos.y: %s" % jellyfish.position.y
