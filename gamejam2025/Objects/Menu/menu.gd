extends Control

@onready var start_game = $"HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Start Game"
@onready var options = $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Options


func _ready():
	self.start_game.grab_focus()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/main_scene.tscn")


func _on_options_pressed() -> void:
	if PlayerStats.sound_on:
		options.text = "Sound: Off"
	else:
		options.text = "Sound: On"
	PlayerStats.sound_on = !PlayerStats.sound_on


func _on_exit_pressed() -> void:
	get_tree().quit()
