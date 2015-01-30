--Copyright 2014 Nathan Beals
local test = {...}
print(self,"globals loaded",test[1])
print = print

CLIENT = CLIENT
SERVER = SERVER

testees = 1


-- any library that does anything special (I.E hooking) can have an unload method for nicely removing anything added.
function UnLoadf()
	testees = 0
	print(testees)
end

hook=hook