extends TextureButton
class_name Field


var field_col_position : int
var field_row_position : int
var nearby_bombs_count : int = 0
var has_bomb : bool
var p : MainGameDirector
var option : String

func check_for_bombs() -> void:
	if has_bomb:
		option = "res://art/bomb.png"
		return

	for i in range(-1, 2):
			for j in range(-1, 2):
				if i == 0 and j == 0:
					continue

				var f = p.get_field(field_col_position + i, field_row_position + j)
				if f != null  && f.has_bomb:
					nearby_bombs_count += 1

	if nearby_bombs_count != 0:
		option = str("res://art/" + str(nearby_bombs_count) + ".png")
	else:
		option = "res://art/empty_pressed.png"


func _on_pressed() -> void:
	if !p.has_started:
		p.set_values([field_col_position, field_row_position])
		p.has_started = true

	if p.is_flag_mode_on: 
		if texture_normal.resource_path == "res://art/flag.png":
			change_bombs_display(1)
			texture_normal = ResourceLoader.load("res://art/empty.png")
			return
		if texture_normal.resource_path != "res://art/empty.png":
			return
		if p.bombs != 0:
			change_bombs_display(-1)
			texture_normal = ResourceLoader.load("res://art/flag.png")
			return

	if option == "res://art/bomb.png":
		texture_normal = ResourceLoader.load(option)
		p.game_end("YOU LOST")
		return
	if texture_normal.resource_path == "res://art/empty.png":
		non_bomb_field_pressed()
	elif texture_normal.resource_path == "res://art/flag.png":
		change_bombs_display(1)
		non_bomb_field_pressed()


func change_bombs_display(change : int) -> void:
	p.bombs += change
	p.change_label()

func non_bomb_field_pressed() -> void:
	texture_normal = ResourceLoader.load(option)
	p.check_fields(self)
	if option == "res://art/empty_pressed.png":
		for i in range(-1, 2):
			for j in range(-1, 2):
				var f = p.get_field(field_col_position + i, field_row_position + j)
				if f != null:
					f._on_pressed()
