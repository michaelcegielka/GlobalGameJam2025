extends Control

const BUBBLE_BLOP = preload("res://Objects/Menu/Sounds/bubble_blop.wav")

@onready var button: Button = $Button


func _ready():
	self.button.grab_focus()


func _on_button_pressed() -> void:
	AudioHandler.add_sound_everwhere(self.BUBBLE_BLOP)
	get_tree().change_scene_to_file("res://Objects/Menu/menu.tscn")
