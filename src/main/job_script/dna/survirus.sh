sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0 
export SINGULARITY_BINDPATH=/cshare1,/home,/share
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
singularity exec $survirus_img python2 /SurVirus-master/surveyor.py \
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
