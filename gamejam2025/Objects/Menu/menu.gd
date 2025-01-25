extends Control

@onready var start_game = $"VBoxContainer2/HBoxContainer/VBoxContainer2/Start Game"


func _ready():
	self.start_game.grab_focus()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/main_scene.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/Menu/options_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
