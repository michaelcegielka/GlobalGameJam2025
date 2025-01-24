extends Control

@onready var health_icons = [
	$CanvasLayer/VBoxContainer/HBoxContainer/TextureRect,
	$CanvasLayer/VBoxContainer/HBoxContainer/TextureRect2, 
	$CanvasLayer/VBoxContainer/HBoxContainer/TextureRect3, 
	$CanvasLayer/VBoxContainer/HBoxContainer/TextureRect4
]

@onready var dash_texture_bar : TextureProgressBar = $CanvasLayer/VBoxContainer/HBoxContainer2/TextureProgressBar

func _ready():
	self.dash_texture_bar.value = PlayerStats.soap_amount / PlayerStats.MaxDashMeter

func _physics_process(delta):
	for i in range(PlayerStats.MaxHealth):
		if i+1 <= PlayerStats.health:
			self.health_icons[i].modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			self.health_icons[i].modulate = Color(0.0, 0.0, 0.0, 1.0)
			
	self.dash_texture_bar.value = PlayerStats.soap_amount / PlayerStats.MaxDashMeter
