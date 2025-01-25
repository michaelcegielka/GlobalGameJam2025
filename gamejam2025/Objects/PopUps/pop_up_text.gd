extends Node3D

const StringList = ["Clean", "Spotless!", "Polished", "Pristine!", "Fresh!", 
					"Popping Off", "Shiny"]

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var label_3d : Label3D = $Label3D

var rand_idx = 0

func _ready():
	PlayerStats.connect("show_pop_up", self.show_pop_up)


func show_pop_up():
	if not self.animation_player.is_playing():
		self.label_3d.text = self.StringList[self.rand_idx]
		self.animation_player.play("PopUp")
		self.rand_idx = randi_range(0, len(self.StringList))
