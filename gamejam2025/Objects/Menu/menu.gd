extends Control




func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/main_scene.tscn")
	
	


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/Menu/options_menu.tscn")
	
	
	

func _on_exit_pressed() -> void:
	get_tree().quit()
