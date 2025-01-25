extends Node

const DashCost = 1.0
const WalkCost = 0.05

const MaxDashMeter = 1000.0
const SoapIncrease = 200.0

const Trick360AirSoap = 25.0 

var soap_amount := MaxDashMeter:
	set(value):
		if value > soap_amount:
			self.emit_signal("got_soap")
		soap_amount = min(MaxDashMeter, value)

var highscore_clean := 0.0
var highscore_time := 0.0

var current_time := 0.0

@warning_ignore("unused_signal")
signal got_soap
@warning_ignore("unused_signal")
signal player_died

func reset():
	self.soap_amount = MaxDashMeter
	
	self.highscore_time = max(self.highscore_time, self.current_time)
	self.current_time = 0.0
