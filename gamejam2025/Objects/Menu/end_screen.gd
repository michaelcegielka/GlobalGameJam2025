extends CanvasLayer

signal restart_game

var block_input := false

@onready var restart_button = $VBoxContainer/HBoxContainer2/RestartButton

func _ready():
	self.visible = false


func show_end_screen():
	self.visible = true
	self.block_input = false
	self.restart_button.grab_focus()


func _on_quit_button_pressed():
	if not self.block_input: self.get_tree().quit()


func _on_restart_button_pressed():
	if not self.block_input:
		self.block_input = true
		self.emit_signal("restart_game")
