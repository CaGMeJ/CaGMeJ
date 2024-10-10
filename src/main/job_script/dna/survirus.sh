sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file 
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv
set -e
host=$ref_fa
host_type=`basename $host`
host_type=${host_type%.*}
virus=`ls $survirus_db_dir/$virus_type/${virus_type}* | grep '.*\(fa$\|fasta$\)'`
host_virus=`ls $survirus_db_dir/$virus_type/${host_type}_${virus_type}* | grep '.*\(fa$\|fasta$\)'`
work_dir=$output_dir/survirus/$sample_name/${virus_type}
if [ ! -e $work_dir ]; then
    mkdir -p  $work_dir
fi
$container_bin exec $survirus_img python2 /SurVirus-master/surveyor.py \
                --wgs \
                --threads $THREADS \
                --bwa bwa \
                --samtools samtools \
                --dust sdust \
                $bam_file \
                $work_dir \
                $host \
                $virus \
                $host_virus
