extends Control

@onready var dash_texture_bar : TextureProgressBar = $CanvasLayer/VBoxContainer/HBoxContainer2/TextureProgressBar



func _ready():
	self.dash_texture_bar.value = PlayerStats.soap_amount / PlayerStats.MaxDashMeter

func _physics_process(delta):
	self.dash_texture_bar.value = lerp(
		self.dash_texture_bar.value,
		PlayerStats.soap_amount / PlayerStats.MaxDashMeter, 
		2.0*delta
	)
