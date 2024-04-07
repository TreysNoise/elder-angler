extends Node3D

@export var num_of_shrimps: float = 40

var packed_shrimp: PackedScene = preload("res://entities/shrimp/shrimp.tscn")
var min_coord: float = -60
var max_coord: float = 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_child_count() < num_of_shrimps:
		var new_shrimp: Shrimp = packed_shrimp.instantiate()
		add_child(new_shrimp)
		while true:
			var random_pos: Vector3 = Vector3(randf_range(min_coord,max_coord), 6.5, randf_range(min_coord,max_coord))
			new_shrimp.position = random_pos
			if new_shrimp.is_overlapping_with_area() == false:
				break
		print("New Shrimp at %s : %s" % [roundf(new_shrimp.position.x), roundf(new_shrimp.position.z)])

