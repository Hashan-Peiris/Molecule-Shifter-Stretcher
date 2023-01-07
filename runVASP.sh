#!/bin/bash
#SBATCH --job-name=2P_00.00
#SBATCH  -p compute  #shared			#compute
##SBATCH -w compute159 			#or --nodelist=node0xx Assigns the said node 	##40 for 143/144 162/162 166/167 ##32 for 164/165 and SmeuC
#SBATCH --constraint="lustre"
##SBATCH --dependency=afterany:17556818 	# MUST CHANGE EACH TIME!
##SBATCH  --exclude=compute[013,026]
##SBATCH  --exclusive		
#SBATCH  -t 48:00:00
#SBATCH   -N 1 
#SBATCH   -n 256 
##SBATCH --mem=246G
##SBATCH  --mem-per-cpu=1024M  
#SBATCH  --contiguous
#SBATCH --account=sbi121
#SBATCH -o slurm-%j.out

#SBATCH  --mail-user=mpeiris1@binghamton.edu
##SBATCH --mail-type=begin  # email me when the job starts
#SBATCH  --mail-type=end     # email me when the job finishes

export OMP_NUM_THREADS=1
mypath="$(pwd)"

path=$mypath                       # path without last part
basename='target'                       # last part

targets=( $path/${basename}* )          # all dirs in an array
lastdir=${targets[@]: (-1):1}           # select path from last entry
echo $lastdir
lastdir=${lastdir##*/}                  # select filename
lastnumber=${lastdir/$basename/}        # remove 'target'
lastnumber=00$(( 10#$lastnumber + 1 ))  # increment number (base 10), add leading zeros

mkdir $path/$basename${lastnumber: -3}  # make dir; last 3 chars from lastnumber

cp $path/$lastdir/CONTCAR 		$path/$basename${lastnumber: -3}/POSCAR
cp $path/$lastdir/KPOINTS		$path/$basename${lastnumber: -3}/KPOINTS
cp $path/$lastdir/POTCAR		$path/$basename${lastnumber: -3}/POTCAR
cp $path/$lastdir/INCAR		$path/$basename${lastnumber: -3}/INCAR
cp $path/$lastdir/CHGCAR		$path/$basename${lastnumber: -3}/CHGCAR
#cp $path/$lastdir/OUTCAR		$path/$basename${lastnumber: -3}/OUTCAR 
#cp $path/$lastdir/CONTCAR 		$path/$basename${lastnumber: -3}/CONTCAR
 
cd $path/$basename${lastnumber: -3}

################
################
# Setting up a global variable to be used in BJ simulations to create incremented folders
folder_num=18.00
export folder_num 
prev_folder_num=10.00
export prev_folder_num 
################
################

#############################################################################################
echo "--------------------------------------------------------------------" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
START_TIME=$(date +%s)
echo "Starting on $(date)" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "Starting: $SLURM_JOB_ID, $SLURM_JOB_NAME, $SLURM_SUBMIT_DIR" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "STATing: SPART = $SLURM_JOB_PARTITION, SNODES = $SLURM_JOB_NODELIST", SNODES = $SLURM_JOB_NUM_NODES, SNT = $SLURM_NTASKS, CPU-NODE = $SLURM_CPUS_ON_NODE, T-N = $SLURM_TASKS_PER_NODE | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "--------------------------------------------------------------------" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "	" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
#############################################################################################
#sleep 10 
#openblas/0.3.10-openmp
module load gcc/9.2.0 openmpi/3.1.6 vasp/5.4.4-openblas


if [ -f POSCAR ]		#if POSCAR exists..
then
  if [ -s POSCAR ] 	#if POSCAR is non-zero..
  then
	#cp	CONTCAR			$mypath/"$dir_name"/"$i"/POSCAR		## Move CONTCAR to POSCAR
	timeout -s SIGTERM --kill-after=47.9h 47.8h   mpirun  --mca btl_openib_if_include "mlx5_2:1" --mca btl openib,self,vader --display-map  --report-bindings vasp_gam
	sleep 15
	SearchString="reached required accuracy - stopping structural energy minimisation"
	file="OUTCAR"

	if grep -Fq "$SearchString" $file
  	 then
  	         echo "Convergence statement found in $file ; Terminating future runs....! "   	>> $mypath/RESTARTING_PROCESS_LOG.txt
		if [ $? -eq 0 ]
		then
			echo "$i $j			POSCAR existed; is non-zero ; JOB ran ; Convergence Achieved ; Everything completed ; TERMINATING SUCCESSFULLY!!" 		>> $mypath/RESTARTING_PROCESS_LOG.txt
			mv   $mypath/RESTARTING_PROCESS_LOG.txt      $mypath/TERMINATING_SUCCESSFULLY.txt
			cd $mypath/
			#copy.sh 

			E=$(grep "energy without entropy" OUTCAR | tail -1);
			T=$(grep "Total CPU time used (sec)" OUTCAR | tail -1);
			L=$(grep "free  energy   TOTEN  =" OUTCAR | tail -1);
			M=$(grep "Maximum memory used (kb)" OUTCAR | tail -1);

			echo "$E" >> KP_Ag.xls
			echo "$T" >> Time_Ag.xls
			echo "$M" >> MxMemory_Ag.xls
			

			# This part deals with creating a new Z scan directory and launching new job when the prev jobs has terminated successfully. USE ONLY for BJ sims.
			cd $mypath/../
		         . ./counter3.sh   		#sources (by first .) 
			echo $prev_folder_num $folder_num 
			echo "$prev_folder_num $folder_num" >> $mypath/../COUNTER_TRACKER.txt
			
			mkdir $mypath/../$folder_num/target000
			cp $path/$basename${lastnumber: -3}/CONTCAR 		$mypath/../$folder_num/target000/CONTCAR
			cp $path/$basename${lastnumber: -3}/KPOINTS 		$mypath/../$folder_num/target000/KPOINTS
			cp $path/$basename${lastnumber: -3}/POTCAR 		$mypath/../$folder_num/target000/POTCAR 			
			cp $path/$basename${lastnumber: -3}/INCAR 		$mypath/../$folder_num/target000/INCAR			
			#cp $path/$basename${lastnumber: -3}/CHGCAR 		$mypath/../$folder_num/target000/CHGCAR

			cp $mypath/../$prev_folder_num/runVASP.sh		$mypath/../$folder_num/runVASP.sh
			cp $mypath/../$prev_folder_num/BJ_Scan2.py		$mypath/../$folder_num/target000/BJ_Scan2.py
			cp $mypath/../$prev_folder_num/BJ_Scan2.py		$mypath/../$folder_num/BJ_Scan2.py ; sleep 2

			cd $mypath/../$folder_num/target000/
			python     ~/bin/dir2car_v2.py ./CONTCAR ; mv -v ./CONTCAR  ./CONTCAR_D ; echo " "  ; mv -v ./CONTCAR_C   ./CONTCAR ; echo " " 
			python $mypath/../$folder_num/target000/BJ_Scan2.py
			cp $mypath/../$folder_num/target000/POSCAR_2 	$mypath/../$folder_num/target000/CONTCAR 

			echo "BJ Scan python code ran" 	>> $mypath/../COUNTER_TRACKER.txt
			echo " " 			>> $mypath/../COUNTER_TRACKER.txt

			cd $mypath/../
			awk '/#SBATCH --job-name/{sub("'"2P_$prev_folder_num"'", "'"2P_$folder_num"'"); print; next} {print}' $mypath/../$folder_num/runVASP.sh   > temp && mv temp $mypath/../$folder_num/runVASP.sh
 	
		else
			echo "$i $j			POSCAR existed; is non-zero ; JOB ran ; Convergence Not found; TERMINATING    UN-SUCCESSFULLY!!" 		>> $mypath/RESTARTING_PROCESS_LOG.txt
			mv   $mypath/RESTARTING_PROCESS_LOG.txt      $mypath/TERMINATING_BAD.txt
		fi
  	 else
 	         echo "Convergence statement NOT found in $file ; Resubmitting a new job....! " 	>> $mypath/RESTARTING_PROCESS_LOG.txt
		cd $SLURM_SUBMIT_DIR/
		sbatch runVASP.sh
			if [ $? -eq 0 ]
			then
				echo "$i $j		POSCAR existed; is non-zero ; JOB ran ; Convergence Not Yet Achieved; RESUBMITTING SUCCESSFULLY!!" 		>> $mypath/RESTARTING_PROCESS_LOG.txt
			else
				echo "$i $j		POSCAR existed; is non-zero ; JOB ran ; Convergence Not Yet Achieved; RESUBMITTING WENT BAD!!" 			>> $mypath/TERMINATED_TERMINATED_TERMINATED_TERMINATED_TERMINATED.txt
			fi
	fi
  else
	echo "$i $j			POSCAR exists; is ZERO ; movement not done! ; Calculation is terminating! " 	>> $mypath/TERMINATED_TERMINATED_TERMINATED_TERMINATED_TERMINATED.txt
  fi
else
  echo "$i $j 		POSCAR does not exist ; movement not done! --- **** " 		>> $mypath/TERMINATED_TERMINATED_TERMINATED_TERMINATED_TERMINATED.txt
fi 


#############################################################################################
echo "--------------------------------------------------------------------" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "Finishing on $(date)" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "Finishing: $SLURM_JOB_ID, $SLURM_JOB_NAME, $SLURM_SUBMIT_DIR" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "STATing: SPART = $SLURM_JOB_PARTITION, SNODES = $SLURM_JOB_NODELIST", SNODES = $SLURM_JOB_NUM_NODES, SNT = $SLURM_NTASKS, CPU-NODE = $SLURM_CPUS_ON_NODE, T-N = $SLURM_TASKS_PER_NODE | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "Total Time Elapsed: $(date -ud "@$(($(date +%s) - $START_TIME))" +%T) (HH:MM:SS)" |tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "--------------------------------------------------------------------" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
echo "	" | tee -a /home/mpeiris1/JOB.txt $mypath/JOB.txt
#############################################################################################
