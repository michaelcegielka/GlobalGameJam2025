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
	self.time_label.set_text(PlayerStats.trasform_time_to_string(PlayerStats.current_time))
