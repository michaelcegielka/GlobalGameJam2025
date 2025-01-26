extends Control

const MenuTheme = preload("res://Objects/Menu/Sounds/DuckSlayer_MenuTheme_cut.wav")
const BUBBLE_BLOP = preload("res://Objects/Menu/Sounds/bubble_blop.wav")

@onready var start_game = $"HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Start Game"
@onready var options = $HBoxContainer/VBoxContainer2/HBoxContainer/VBoxContainer2/Options

func _ready():
	self.start_game.grab_focus()
	AudioHandler.set_bgm(self.MenuTheme)

func _on_start_game_pressed() -> void:
	AudioHandler.add_sound_everwhere(self.BUBBLE_BLOP)
	get_tree().change_scene_to_file("res://Objects/main_scene.tscn")


func _on_options_pressed() -> void:
	AudioHandler.add_sound_everwhere(self.BUBBLE_BLOP)
	get_tree().change_scene_to_file("res://Objects/Menu/help.tscn")
	#if PlayerStats.sound_on:
		#options.text = "Sound: Off"
	#else:
		#options.text = "Sound: On"
	#PlayerStats.sound_on = !PlayerStats.sound_on


func _on_exit_pressed() -> void:
	get_tree().quit()
