--Copyright 2014 Nathan Beals

print(self,"TESTETESTS\n globals loaded \n \n gfdgdf\n \n \nfsdgfsfg\n\n\nfgd\n")
print = print

CLIENT = CLIENT
SERVER = SERVER

testees = 1


-- and library that does anything special (I.E hooking) can have an unload method for nicely removing anything added.
function UnLoadf()
	testees = 0
	print(testees)
end