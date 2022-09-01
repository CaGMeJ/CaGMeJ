SCRIPT_DIR=`pwd`
ANNOVAR=
HUMANDB=
SRC_DIR=
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
            src/main/config/dna.cfg > build/main/config/dna.cfg
