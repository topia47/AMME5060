Results obtained are stored here

#Check Resources - Interactive session
echo $I 

#Edit resources
qsub -I -l select=1:ncpus=4:mpiprocs=4:mem=6G,walltime=01:00:00 -P RDS-FEI-ComputNano-RW

#Run using specified processors
mpirun -np $PBS_NCPUS JabMol>out_Simple_LJ_T100

#Project folder - Results obtained are stored here
cd $P

#Replace command in the input file
:%s/string/newstring/g

#Send file for compute (Artemis)
qsub script_ComputNano

#Check status
qstat -u sval6712


#Things to each for iteration
1) Parameter
2) input_Simple_LJ_T### file
2.1) Change &files_data to input_Simple_LJ_T###
2.2) Change &allocate_data to pArraySize(np)
2.3) Change &properties_averages_data to stepLimit= #####
3) script_ComputNano
3.1) Change all instace of input_Simple_LJ_T###_old to input_Simple_LJ_T###_new
3.2) Change number of CPU ???

