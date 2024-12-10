extends Node2D

@onready var white: Sprite2D = %White
@onready var black: Sprite2D = %Black
@onready var white_edit: LineEdit = %WhiteEdit
@onready var black_edit: LineEdit = %BlackEdit
@onready var current_degrees: Label = %CurrentDegrees

@export var tween_duration:float=2

func _ready() -> void:
	show_current_label()

func _on_ok_pressed() -> void:
	var tween:Tween=get_tree().create_tween()
	if white_edit.text:
		var degrees:float=float(white_edit.text)
		tween.tween_property(white,"rotation_degrees",degrees,tween_duration)
	elif black_edit.text:
		var degrees:float=float(black_edit.text)
		tween.tween_property(black,"rotation_degrees",degrees,tween_duration)
	tween.tween_callback(show_current_label)

	
func show_current_label():
	current_degrees.text="黑角度为： %d"%black.rotation_degrees+"\n"+\
						"白角度为： %d"%white.rotation_degrees
