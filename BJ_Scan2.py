
import math

# PARAMETERS:
#############################################################################################################
# The numbers id the atoms starting from 1 (2,3,...)
Au_Probe_Atoms=[144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286]
Mol_Atoms=[287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320]
# Defines the tips of the 1.bottom 2.top probes (in that order)
Tips=[143,144]
# Defines the top to bottom length of the molecule (C-C or S-S)
Stretch_Endpoints=[319,320]
# The value to be added to the Z value of atoms being shifted
change_z=0.25
# The reference atom ID for stretching (usually tip of base probe)
base_probe_id=143
#############################################################################################################

# Warnings
print("\nWARNING:\nThis script intentionally! does not check if the atoms move beyond boundaries!\n")

def Au_Atoms(i):
    # Modify this function to specify the set of atoms you want to modify
    return i in Au_Probe_Atoms  

def Molecule_atoms(i):
    # Modify this function to specify the set of atoms you want to modify
    return i in Mol_Atoms

# Read in the POSCAR file
with open('POSCAR_1', 'r') as f:
    lines = f.readlines()
    
# Parse the header information
header = lines[:8]
num_atoms = [int(x) for x in header[6].split()]
total_atoms = sum(num_atoms)

# Parse the selective dynamics information
selective_dynamics = [x.split() for x in lines[8:]]

# Get the distance for two points
def distance(points):
    point1, point2 = points
    print('These are the edge points of the molecule:\n',point1,'\n',point2)
    x1, y1, z1 = map(float, point1)
    x2, y2, z2 = map(float, point2)
    return math.sqrt((x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2)

# Get the distance for Stretch_Endpoints
Epoints=[selective_dynamics[Stretch_Endpoints[0]][0:3],selective_dynamics[Stretch_Endpoints[1]][0:3]]
E2E_Distance=distance(Epoints)
print('Therefore, the edge to edge distance: {:.4f}'.format(E2E_Distance), 'Ang.\n')

# Get the Tip-Tip distance
Tpoints=[selective_dynamics[Tips[0]][0:3],selective_dynamics[Tips[1]][0:3]]
T2T_Distance=distance(Tpoints)
print('Therefore, the Tip-Tip distance: {:.4f}'.format(T2T_Distance), 'Ang.\n')

# Cordinates of point 1 (for stretching work)
base_Z=float(selective_dynamics[Tips[0]][2])

# Modify the atomic coordinates for PROBE LIFTING:
for i, coord in enumerate(selective_dynamics):
    # Check if the atom has selective dynamics turned on
    sd = selective_dynamics[i]
    if len(sd) == 6:
        x, y, z, sx, sy, sz = sd
        #print(sd)
        if Au_Atoms(i):
            coord[2] = str(float(coord[2]) + float(change_z))
    elif len(sd) == 3:
        print("This file seems to have weird SD info; I was not expecting this!")

# Modify the atomic coordinates for STRETCHING the molecule:
for i, coord in enumerate(selective_dynamics):
    # Check if the atom has selective dynamics turned on
    sd = selective_dynamics[i]
    if len(sd) == 6:
        x, y, z, sx, sy, sz = sd
        #print(sd)
        if Molecule_atoms(i):
            new_z=float(coord[2])+(change_z*((float(coord[2])-base_Z)/E2E_Distance))
            Diff=float(z)-new_z
            print('Old Z: ', z, '    New Z: ', new_z, '         Diff: ', Diff)
            coord[2] = str(new_z)
            #coord[2] = str(float(coord[2]) + float(change_z))
    elif len(sd) == 3:
        print("This file seems to have weird SD info; I was not expecting this!")

# Write the modified POSCAR to a new file
with open('POSCAR_2', 'w') as f:
    # Write the header without the newline characters
    for line in header:
        f.write(line.strip() + '\n')
    #for line in selective_dynamics + coordinates:
    for line in selective_dynamics:
        f.write(' '.join(line) + '\n')
