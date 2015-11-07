--Copyright 2015 Nathan Beals
local container , ply , env = ...
local netc = container:GetNetworker()

if WireLib and SERVER then
	WireLib = WireLib

	Wire = {}

	function Wire.CreateInputs( names , types )

		return WireLib.CreateSpecialInputs( env.Entity , names , types )
	end

	function Wire.CreateOutputs( names , types )
		print("creatoutput")
		print(env.Entity)
		print("tagble?!?")
		return WireLib.CreateSpecialOutputs( env.Entity , names , types )
	end

end
