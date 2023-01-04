def should_modify(i):
    # Modify this function to specify the set of atoms you want to modify
    return i in [286,285,284,283]   

# The value to be added to the Z value of atoms being shifted
change_z=10.0

# Read in the POSCAR file
with open('POSCAR_1', 'r') as f:
    lines = f.readlines()
    print(lines)
    print(" ")
# Parse the header information
header = lines[:8]
print("This POSCAR has" %i "lines..." %(len(lines)))
#print(header)
#print(" ")
num_atoms = [int(x) for x in header[6].split()]
#print(num_atoms)
total_atoms = sum(num_atoms)
print("Total Atoms:" total_atoms)
print(" ")

# Parse the selective dynamics information
selective_dynamics = [x.split() for x in lines[8:]]
#print(selective_dynamics)

# Modify the atomic coordinates
for i, coord in enumerate(selective_dynamics):
    #print(i,coord)
    #print("this")
    # Check if the atom has selective dynamics turned on
    sd = selective_dynamics[i]
    if len(sd) == 6:
        x, y, z, sx, sy, sz = sd
        #print(sd)
        if should_modify(i):
            coord[2] = str(float(coord[2]) + change_z)
            #selective_dynamics[i+1][2] =  str(float(coord[2]) + change_z)
    elif len(sd) == 3:
        print("This file seems to have no SD info; I was not expecting this!")
        
#print(selective_dynamics)

# Write the modified POSCAR to a new file
with open('POSCAR_2', 'w') as f:
    # Write the header without the newline characters
    for line in header:
        f.write(line.strip() + '\n')
    #for line in selective_dynamics + coordinates:
    for line in selective_dynamics:
        f.write(' '.join(line) + '\n')
