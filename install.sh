#$ -cwd
#$ -l s_vmem=20G
set -xv
set -e
SCRIPT_DIR=`pwd`
ANNOVAR=
HUMANDB=
SRC_DIR=
if [ ! -d src ]; then
    echo "Not found src directory!"
    exit 1
fi
if [ ! -d build ]; then
    cp -r src build
else
    echo "Delete build directory!"
    exit 1
fi
sed -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" src/main/qsub_CaGMeJ.sh >  build/main/qsub_CaGMeJ.sh
sed  -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" src/main/CaGMeJ.sh > build/main/CaGMeJ.sh

sed  -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" \
     -e "s@SRC_DIR@$SRC_DIR@g" \
     -e "s@ANNOVAR@$ANNOVAR@g" \
     -e "s@HUMANDB@$HUMANDB@g" src/main/config/dna.cfg > build/main/config/dna.cfg

sed  -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" \
     -e "s@SRC_DIR@$SRC_DIR@g" src/main/config/rna.cfg > build/main/config/rna.cfg

sed  -e "s@SRC_DIR@$SRC_DIR@g" src/main/config/img_and_csv.cfg > build/main/config/img_and_csv.cfg
sed  -e "s@SRC_DIR@$SRC_DIR@g" src/main/config/img_and_csv_rna.cfg > build/main/config/img_and_csv_rna.cfg

sed  -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" \
     -e "s@SRC_DIR@$SRC_DIR@g" src/test_dna.sh > build/test_dna.sh

sed  -e "s@SCRIPT_DIR@$SCRIPT_DIR@g" \
     -e "s@SRC_DIR@$SRC_DIR@g" src/test_rna.sh > build/test_rna.sh

if [ ! -e Miniconda3-latest-Linux-x86_64.sh ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
fi

if [ -e $SCRIPT_DIR/build/miniconda3 ]; then
    echo "$SCRIPT_DIR/build/miniconda3 exists. Please delete  ~/miniconda3"
    exit 1
fi

expect -c "
set timeout 600
spawn bash  Miniconda3-latest-Linux-x86_64.sh
expect \">>>\"
send -- \"\n\"
expect \":\"
send -- \"            \"
expect \">>>\"
send -- \"yes\n\"
expect \">>>\"
send -- \"$SCRIPT_DIR/build/miniconda3\"
expect \">>>\"
send -- \"\n\"
expect \"$\"
exit 0
"
eval "$($SCRIPT_DIR/build/miniconda3/bin/conda shell.bash hook)"
conda config --add channels bioconda
conda config --add channels conda-forge
conda create -n CaGMeJ
conda activate CaGMeJ
conda install nextflow=21.04.0=h4a94de4_0
conda deactivate
