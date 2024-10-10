sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
set -e

if [ -e $output_dir/manta/$analysis_type/${tumor_name}_${normal_name} ]; then
    rm -r $output_dir/manta/$analysis_type/${tumor_name}_${normal_name} 
fi

mkdir -p  $output_dir/manta/$analysis_type/${tumor_name}_${normal_name}

if [ ! $normal_bam = None ] ;then
   normal_option="--normalBam=$normal_bam"
else
   normal_option=
fi

if [ $analysis_type = somatic ]; then
    $container_bin exec --no-mount tmp $manta_img configManta.py \
           $normal_option \
           --tumorBam=${tumor_bam} \
           --referenceFasta=$ref_fa \
           --runDir=$output_dir/manta/$analysis_type/${tumor_name}_${normal_name}
else 
    $container_bin exec --no-mount tmp $manta_img configManta.py \
           --bam=${tumor_bam} \
           --referenceFasta=$ref_fa \
           --runDir=$output_dir/manta/$analysis_type/${tumor_name}_${normal_name}
fi

$container_bin exec --no-mount tmp $manta_img python2 $output_dir/manta/$analysis_type/${tumor_name}_${normal_name}/runWorkflow.py $manta_option        
