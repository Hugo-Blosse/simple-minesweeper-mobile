extends Control
class_name MainGameDirector


const FieldBase = preload("res://mine.tscn")


@export_range(1, 10) var column_length : int
@export_range(1, 20) var row_length : int
@export_range(1, 199) var bombs : int

var has_started : bool = false
var fields : Dictionary = {}
var field_positions : Array = []
var bomb_positions : Array = []
var is_flag_mode_on : bool
var fields_to_check : int


@onready var texture_rect : TextureRect = $Control/TextureRect
@onready var label : Label = $Control/Label
@onready var spin_box : SpinBox = $Menu/CanvasLayer/SpinBox
@onready var menu : Control = $Menu
@onready var canvas_layer : CanvasLayer = $Menu/CanvasLayer
@onready var game_end_label : Label = $Menu/CanvasLayer/Label
@onready var timer : Timer = $Timer
@onready var hamburger : TextureButton = $Menu/CanvasLayer/TextureRect/hamburger


func _ready() -> void:
	start()
	$Menu/CanvasLayer/SpinBox.max_value = 199


func get_field(col_pos : int, row_pos : int) -> Field:
	if row_pos < 0 || col_pos < 0 || col_pos > column_length - 1 || row_pos > row_length - 1:
		return null
	return fields[[col_pos, row_pos]]


func create_field(col_pos : int, row_pos : int) -> void:
	var field = FieldBase.instantiate()
	field.field_col_position = col_pos
	field.field_row_position = row_pos
	field_positions.append([col_pos, row_pos])
	field.p = self
	field.global_position = Vector2(20 * col_pos, 20 * row_pos + 50)
	fields[[col_pos, row_pos]] = field
	field.name = str(col_pos, " ", row_pos)
	add_child(field)


func set_values(pos : Array) -> void:
	field_positions.erase(pos)
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	for bomb in bombs:
		var rand_field : Array = field_positions[rng.randi_range(0, len(field_positions) - 1)]
		fields[rand_field].has_bomb = true
		bomb_positions.append(rand_field)
		field_positions.erase(rand_field)

	field_positions.append(pos)

	for f in fields.values():
		f.check_for_bombs()
		if f.nearby_bombs_count != 0 && f.option != "res://art/bomb.png":
			fields_to_check += 1


func start() -> void:
	fields_to_check = 0
	bombs = int(spin_box.value)
	for i in column_length:
		for j in row_length:
			create_field(i, j)

	size = Vector2(22 * column_length, 22 * row_length)
	texture_rect.global_position = Vector2(column_length * 19 - 14, 10)
	label.text = str(bombs)
	label.global_position = Vector2(column_length * 10 - 8, 5)


func change_label() -> void:
	label.text = str(bombs)


func _on_texture_button_pressed() -> void:
	if texture_rect.texture.resource_path == "res://art/bomb_mode.png":
		texture_rect.texture = ResourceLoader.load("res://art/flag_mode.png")
		is_flag_mode_on = true
	else:
		texture_rect.texture = ResourceLoader.load("res://art/bomb_mode.png")
		is_flag_mode_on = false


func _on_texture_button_2_pressed() -> void:
	menu.visible = !menu.visible
	canvas_layer.visible = !canvas_layer.visible
	get_tree().paused = !get_tree().paused


func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


func game_end(end_text : String) -> void:
	game_end_label.text = end_text
	game_end_label.visible = true
	get_tree().paused = !get_tree().paused
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().paused = !get_tree().paused
	hamburger.disabled = true
	_on_texture_button_2_pressed()


func _on_restart_pressed() -> void:
	game_end_label.visible = false
	hamburger.disabled = false
	for child in get_children():
		if child is Field:
			child.queue_free()
	field_positions.clear()
	start()
	has_started = false
	_on_texture_button_2_pressed()


func check_fields(field : Field) -> void:
	if field.nearby_bombs_count != 0:
		fields_to_check -= 1
		if fields_to_check == 0:
			game_end("YOU WIN")
