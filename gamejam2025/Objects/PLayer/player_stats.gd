extends Node

const DashCost = 0.1
const MaxDashMeter = 100.0
const SoapIncrease = 50.0

const MaxHealth = 4

var soap_amount := MaxDashMeter:
	set(value):
		soap_amount = min(MaxDashMeter, value)

var health := MaxHealth
