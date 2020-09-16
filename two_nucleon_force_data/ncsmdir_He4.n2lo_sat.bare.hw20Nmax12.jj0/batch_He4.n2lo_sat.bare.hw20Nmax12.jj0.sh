#!/bin/bash 
export SNIC_TMP=/scratch.local1/f2bcf/research/ncsm/rundirs
# MACHINE SPECS
export CORES_PER_NODE=$(grep "cpu cores" /proc/cpuinfo |sort -u |cut -d":" -f2) 
export OMP_NUM_THREADS=$(grep "cpu cores" /proc/cpuinfo |sort -u |cut -d":" -f2) 
export MEM_FOR_ANT=$(awk '{printf "%.0f", $2/1024-4000; exit}' /proc/meminfo) 

# Report various information
echo "Starting at `date`"
echo "Current working directory is $PWD"
echo "Scratch run directory is: $SNIC_TMP"
 
# Create the scratch run directory and copy files.
# --- 
mkdir -p $SNIC_TMP 
cp -r /net/home/f2bcf/research/ncsm/rundirs/a4/ncsmdir_He4.n2lo_sat.bare.hw20Nmax12.jj0 $SNIC_TMP/. 
cd $SNIC_TMP/ncsmdir_He4.n2lo_sat.bare.hw20Nmax12.jj0 
echo "Moved to scratch directory:"
pwd
echo "Free space:"
df -h . 

# Copy executables to the scratch run directory.
# --- 
cp /net/home/f2bcf/research/codes/bin/get_potential getpot.x 
cp /net/home/f2bcf/research/codes/bin/ncsmpnv2beff_x86_64_ifort_openmp.x ncsmeff.x 
cp /net/home/f2bcf/research/codes/bin/antoine_Linux_g77_openmp pantoine.x 
cp /net/home/f2bcf/research/codes/ncsm/mfrtd/mfr mfr.x 

# Create folder structure for the antoine run. 
# --- 
mkdir -p cdm 
mkdir -p amat 
mkdir -p amat0 
mkdir -p amat1 
mkdir -p amat2 
mkdir -p amat3 
mkdir -p amat4 
mkdir -p amat5 
mkdir -p vec 
mkdir -p res 
mkdir -p res1 
mkdir -p res2 

# Interaction and CM matrix elements 
# --- 
cat /net/data2/f2bcf/ncsm/TBME/chiral-potentials/n2lo_sat.ini /net/data2/f2bcf/ncsm/TBME/chiral-potentials/get_potential-common.ini > v2brel.ini 
time ./getpot.x v2brel.ini +HO.omega=20.000000 >> vrel.pot 
if [ -s "vrel.pot" ]; then
    echo "Vrel.pot created!"
 else
  echo "vrel.pot not created successfully"
    exit
fi
cp vrel.pot /net/data2/f2bcf/ncsm/TBME/vrel/vn2lo_sat_Nmax60_jrelmax10_hw20.dat & 
cp ncsmpneff_hw=20_Nm=0_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.90 
cp ncsmpneff_hw=20_Nm=2_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.91 
cp ncsmpneff_hw=20_Nm=4_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.92 
cp ncsmpneff_hw=20_Nm=6_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.93 
cp ncsmpneff_hw=20_Nm=8_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.94 
cp ncsmpneff_hw=20_Nm=10_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.95 
cp ncsmpneff_hw=20_Nm=12_N1=0.nml ./ncsmpneff.nml 
time ./ncsmeff.x 
if [ -s "TBME.intbin" ]; then
    echo TBME.intbin created!
 else
  echo "TBME.intbin not created successfully"
    exit
fi
mv TBME.intbin fort.96 

echo "All interactions generated"
echo "--------------------------"
ls -ltr 

# Run pAntoine 
# --- 
./pantoine.x -s $MEM_FOR_ANT < ant_He4.n2lo_sat.bare.hw20Nmax12.jj0.in 2> /net/home/f2bcf/research/ncsm/rundirs/a4/ncsmdir_He4.n2lo_sat.bare.hw20Nmax12.jj0/ant_He4.n2lo_sat.bare.hw20Nmax12.jj0.out 
echo "Program finished with exit code $? at: `date`" 

# Copy and clean files 
# --- 
pwd 
df -h . 
cp /net/home/f2bcf/research/ncsm/rundirs/a4/ncsmdir_He4.n2lo_sat.bare.hw20Nmax12.jj0/ant_He4.n2lo_sat.bare.hw20Nmax12.jj0.out ant_He4.n2lo_sat.bare.hw20Nmax12.jj0.in /net/home/f2bcf/research/ncsm/runs/a4/. 
# Antoine output written to /net/home/f2bcf/research/ncsm/rundirs/a4/ncsmdir_He4.n2lo_sat.bare.hw20Nmax12.jj0 and /net/home/f2bcf/research/ncsm/runs/a4/ 

# TODO: clean scratch dir 
cp -u cdm/CDM_*_* /net/data1/f2bcf/ncsm/cdm & 
