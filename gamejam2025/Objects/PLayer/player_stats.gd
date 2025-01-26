extends Node

const DashCost = 120.0
const WalkCost = 0.2
const JumpCost = 25.0

const HitCost = 150.0
const HitKnockBack = 25.0

const MaxDashMeter = 1000.0
const SoapIncrease = 100.0

const Trick360AirSoap = 8.0 

var current_enemy_limit := 12.0
var current_ducks := 0

var soap_amount := MaxDashMeter:
	set(value):
		if value > soap_amount:
			self.emit_signal("got_soap")
		soap_amount = min(MaxDashMeter, value)

var highscore_clean := 0.0
var highscore_time := 0.0

var current_time := 0.0
var current_score := 0

var sound_on := true

@warning_ignore("unused_signal")
signal got_soap
@warning_ignore("unused_signal")
signal player_died
@warning_ignore("unused_signal")
signal compute_score
@warning_ignore("unused_signal")
signal show_pop_up
@warning_ignore("unused_signal")
signal show_combo_trick

func reset():
	self.soap_amount = MaxDashMeter
	
	self.highscore_time = max(self.highscore_time, self.current_time)
	self.highscore_clean = max(self.highscore_clean, self.current_score)
	self.current_time = 0.0
	self.current_score = 0
	self.current_ducks = 0

func trasform_time_to_string(time_in_seconds):
	var minutes = time_in_seconds / 60 # seconds variable should be an int
	var hours = time_in_seconds / 3600
	var leftover_seconds = fmod(time_in_seconds, 60.0)
	return "( %02d:%02d:%02d )" % [hours, minutes, leftover_seconds]
