sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0 
export SINGULARITY_BINDPATH=/cshare1,/home,/share
set -xv
set -e
if [ ! -e $output_dir/virus_count/$sample_name ]; then
    mkdir -p  $output_dir/virus_count/$sample_name
fi
cwd=`pwd`
cd $output_dir/virus_count/$sample_name
singularity exec $virus_count_img python3  $python_dir/virus_count/bam_filter_single.py --input_bam $bam_file
bn=`basename $bam_file`
bn=${bn%.bam}
fastq=${bn}.fq
sam=${bn}.sam
singularity exec $virus_count_img bowtie2 \
                -x ${bowtie_ref} \
                -U ${fastq} \
                -S $sam

grep -v ^@ $sam | cut -f 3 | sort | uniq -c  > ${bn}.virus_count.txt
rm $fastq
cd $cwd 
