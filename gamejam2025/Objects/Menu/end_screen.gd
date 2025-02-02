extends CanvasLayer

const MenuTheme = preload("res://Objects/Menu/Sounds/DuckSlayer_MenuTheme_cut.wav")
const BUBBLE_BLOP = preload("res://Objects/Menu/Sounds/bubble_blop.wav")

signal restart_game

var block_input := false

@onready var restart_button = $VBoxContainer/HBoxContainer2/RestartButton

@onready var time_label_current = $VBoxContainer/HBoxContainer/VBoxContainer/TimeLabelCurrent
@onready var score_label_current = $VBoxContainer/HBoxContainer/VBoxContainer/ScoreLabelCurrent
@onready var time_label_high_score = $VBoxContainer/HBoxContainer/VBoxContainer2/TimeLabelHighScore
@onready var score_label_high_score = $VBoxContainer/HBoxContainer/VBoxContainer2/ScoreLabelHighScore


func _ready():
	self.visible = false


func show_end_screen():
	self.visible = true
	self.block_input = false
	self.restart_button.grab_focus()
	
	self.time_label_current.text = "Time: " + PlayerStats.trasform_time_to_string(PlayerStats.current_time)
	self.score_label_current.text = "Score: " + str(PlayerStats.current_score)
	
	self.time_label_high_score.text = "Time: " + PlayerStats.trasform_time_to_string(PlayerStats.highscore_time)
	self.score_label_high_score.text = "Score: " + str(PlayerStats.highscore_clean)
	AudioHandler.set_bgm(self.MenuTheme)


func _on_quit_button_pressed():
	if not self.block_input: self.get_tree().quit()


func _on_restart_button_pressed():
	AudioHandler.add_sound_everwhere(self.BUBBLE_BLOP)
	if not self.block_input:
		self.block_input = true
		self.visible = false
		self.emit_signal("restart_game")
