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

signal got_soap
