#!/bin/sh
# compute_coghi_bhigher.sh
#Torque script to run Matlab program

#Torque directives
#PBS -N compute_coghi_bhigher
#PBS -W group_list=hpcsscc
#PBS -l nodes=1,walltime=06:00:00
#PBS -M mmd2172@columbia.edu
#PBS -m abe
#PBS -V

#set output and error directories (SSCC example here)
#PBS -o localhost:/hpc/sscc/work/users/mmd2172/
#PBS -e localhost:/hpc/sscc/work/users/mmd2172/

#define parameter lambda

#Command to execute Matlab code
matlab -nosplash -nodisplay -nodesktop -r "compute_coghi_bhigher" > matoutfile6

#Command below is to execute Matlab code for Job Array (Example 4) so that each part writes own output
#matlab -nosplash -nodisplay -nodesktop -r "simPoissGLM($LAMBDA)" > matoutfile.$PBS_ARRAYID

#End of script