extends Control

@onready var dash_texture_bar : TextureProgressBar = $CanvasLayer/VBoxContainer/HBoxContainer2/TextureProgressBar
@onready var time_label = $CanvasLayer/VBoxContainer/HBoxContainer3/TimeLabel



func _ready():
	self.dash_texture_bar.value = PlayerStats.soap_amount / PlayerStats.MaxDashMeter

func _physics_process(delta):
	self.dash_texture_bar.value = lerp(
		self.dash_texture_bar.value,
		PlayerStats.soap_amount / PlayerStats.MaxDashMeter, 
		10.0*delta
	)

	var minutes = PlayerStats.current_time / 60 # seconds variable should be an int
	var hours = PlayerStats.current_time / 3600
	var leftover_seconds = fmod(PlayerStats.current_time, 60.0)
	self.time_label.set_text("( %02d:%02d:%02d )" % [hours, minutes, leftover_seconds])
