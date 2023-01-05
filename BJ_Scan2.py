def should_modify(i):
    # Modify this function to specify the set of atoms you want to modify
    return i in [144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286]   # The numbers id the atoms starting from 1 (2,3,...)

# The value to be added to the Z value of atoms being shifted
change_z=10.0

# Warnings
print("\n\nWARNING:\nThis script intentionally! does not check if the atoms move beyond boundaries!")

# Read in the POSCAR file
with open('POSCAR_1', 'r') as f:
    lines = f.readlines()
    #print(lines)
    print(" ")
# Parse the header information
header = lines[:8]
#print("This POSCAR has %s lines...", %(len(lines)))
#print(header)
#print(" ")
num_atoms = [int(x) for x in header[6].split()]
#print(num_atoms)
total_atoms = sum(num_atoms)
 
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
