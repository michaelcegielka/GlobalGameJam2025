extends Control

@onready var button: Button = $Button


func _ready():
	self.button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Objects/Menu/menu.tscn")
