sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export OMP_NUM_THREADS=1
export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx10g -Xms32m"
set -xv

tumor_name=$TUMOURNAME

if [ "$IS_MALE" = N ]; then
    IS_MALE=F
    if [ `cat $output_dir/cnvkit_compare/$tumor_name/is_male_reference.txt` = True ]; then
        IS_MALE=T
    fi
fi

out_dir=${output_dir}/battenberg/${tumor_name} 

if [ ! -e ${out_dir} ]; then
 mkdir -p  ${out_dir}
fi


RUN_DIR=${out_dir}

$container_bin exec $battenberg_img bash -c "R -q --vanilla --args \
        $TUMOURNAME \
        $NORMALNAME \
        $NORMALBAM \
        $TUMOURBAM \
        $IS_MALE \
        $RUN_DIR \
        $NTHREADS \
        $BEAGLE_BASEDIR \
        $CHROM_COORD_FILE \
        $beaglemaxmem \
        $beaglecpu  < ${R_SCRIPT}/battenberg.R" 
