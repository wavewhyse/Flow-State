extends Spatial

export(PackedScene) var path_piece

func _ready():
	for i in range(25):
		var next_piece = path_piece.instance()
		next_piece.translation.z = i * -16
		add_child(next_piece)
