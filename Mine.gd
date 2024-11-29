extends TextureButton
class_name Field


var field_col_position : int
var field_row_position : int
var nearby_bombs_count : int = 0
var has_bomb : bool
var p : MainGameDirector
var option : String

func check_for_bombs() -> void:
	var f1 = p.get_field(field_col_position + 1, field_row_position + 1)
	var f2 = p.get_field(field_col_position + 1, field_row_position)
	var f3 = p.get_field(field_col_position + 1, field_row_position - 1)
	var f4 = p.get_field(field_col_position, field_row_position + 1)
	var f5 = p.get_field(field_col_position, field_row_position - 1)
	var f6 = p.get_field(field_col_position - 1, field_row_position + 1)
	var f7 = p.get_field(field_col_position - 1, field_row_position)
	var f8 = p.get_field(field_col_position - 1, field_row_position - 1)
	if f1 != null && f1.has_bomb:
		nearby_bombs_count += 1
	if f2 != null && f2.has_bomb:
		nearby_bombs_count += 1
	if f3 != null && f3.has_bomb:
		nearby_bombs_count += 1
	if f4 != null && f4.has_bomb:
		nearby_bombs_count += 1
	if f5 != null && f5.has_bomb:
		nearby_bombs_count += 1
	if f6 != null && f6.has_bomb:
		nearby_bombs_count += 1
	if f7 != null && f7.has_bomb:
		nearby_bombs_count += 1
	if f8 != null && f8.has_bomb:
		nearby_bombs_count += 1
	if has_bomb:
		option = "res://bomb.png"
	elif nearby_bombs_count != 0:
		option = str("res://" + str(nearby_bombs_count) + ".png")
	else:
		option = "res://empty_pressed.png"


func _on_pressed() -> void:
	if !p.has_started:
		p.set_values([field_col_position, field_row_position])
		p.has_started = true
	if p.is_flag_mode_on: 
		if texture_normal.resource_path == "res://flag.png":
			change_bombs_display(1)
			texture_normal = ResourceLoader.load("res://empty.png")
			return
		if texture_normal.resource_path != "res://empty.png":
			return
		if p.bombs != 0:
			change_bombs_display(-1)
			texture_normal = ResourceLoader.load("res://flag.png")
			return
	if option == "res://bomb.png":
		texture_normal = ResourceLoader.load(option)
		p.game_end("YOU LOST")
		return
	if texture_normal.resource_path == "res://empty.png":
		non_bomb_field_pressed()
	elif texture_normal.resource_path == "res://flag.png":
		change_bombs_display(1)
		non_bomb_field_pressed()


func change_bombs_display(change : int) -> void:
	p.bombs += change
	p.change_label()

func non_bomb_field_pressed() -> void:
	texture_normal = ResourceLoader.load(option)
	p.check_fields(self)
	if option == "res://empty_pressed.png":
		var f1 = p.get_field(field_col_position + 1, field_row_position)
		var f2 = p.get_field(field_col_position - 1, field_row_position)
		var f3 = p.get_field(field_col_position, field_row_position + 1)
		var f4 = p.get_field(field_col_position, field_row_position - 1)
		if f1 != null:
			f1._on_pressed()
		if f2 != null:
			f2._on_pressed()
		if f3 != null:
			f3._on_pressed()
		if f4 != null:
			f4._on_pressed()
