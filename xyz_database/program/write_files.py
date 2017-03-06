skip = False
c = 0 # line number for molecule counter
n = 0 # number of files made counter
ac = 0 #number of atoms in molecule counter
w_contents = ''
filename = 'blah.txt'

f = open("organic_compounds_coordinates.txt","r")
for line in f.readlines():
	#parts = line.split()
	if '0   H' in line or line[0] == '0' or '--link1--' in line or line in ['\n', '\r\n']:
		skip = True

	if c == 2: 
		filename = str(line.strip()) + ".xyz"
	
	if c >= 4:
		ac = ac+1

	if "#n functional/basis-set nmr=method" in line:
		# write xyz data to new file then move to next by clearing w_contents var
		c = 0
		name = str(filename)
		newfile = open(filename,"w")
		newfile.write(str(ac - 5) + "\n") # write # of atoms first
		newfile.write(w_contents)
		newfile.close()
		w_contents = '' # clear var for new molecule file
		n = n+1 # increase file count by 1
		ac = 0 # number of atoms back to zero

	else:
		if skip == False:
			w_contents = w_contents + line
	skip = False


	c = c + 1
f.close()
print "number of files made: " + str(n)
