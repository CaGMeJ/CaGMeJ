sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
set -e
output_dir=${output_dir}/mimcall/$tumor_name 

if [ ! -e  ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi

if [ ! -f ${tumor_bam} ] || [ ! -f ${tumor_bam}.bai ] || [ ! -f ${normal_bam} ] || [ ! -f ${normal_bam}.bai ]; then
    sleep 1m
    exit 1
fi

singularity exec $mimcall_img  samtools view $mimcall_samtools_view_option --region-file $mimcall_region_db  $tumor_bam > $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam

if [ ! -s $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam ]; then
    exit 1
fi

singularity exec $mimcall_img  samtools view $mimcall_samtools_view_option --region-file $mimcall_region_db $normal_bam > $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam

if [ ! -s $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam ]; then
    exit 1
fi

singularity exec $mimcall_img python3 /MIMcall2/bin/assign_reads.all_chr.py $mimcall_db $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam > $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam2

if [ ! -s $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam2 ]; then
    exit 1
fi

singularity exec $mimcall_img python3 /MIMcall2/bin/assign_reads.all_chr.py $mimcall_db  $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam > $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam2

if [ ! -s $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam2 ]; then
    exit 1
fi

singularity exec $mimcall_img perl /MIMcall2/bin/GPOS2RPOS_READ_F.pl $GPOS2RPOS_READ_F_option -I $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam2  > $output_dir/${tumor_name}.MIMcall.txt.CANCER

if [ ! -s $output_dir/${tumor_name}.MIMcall.txt.CANCER ]; then
    exit 1
fi

singularity exec $mimcall_img perl /MIMcall2/bin/GPOS2RPOS.BLOOD.READ_F.pl $GPOS2RPOS_BLOOD_READ_F_option -I $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam2  > $output_dir/${normal_name}.MIMcall.txt.NORMAL

if [ ! -s $output_dir/${normal_name}.MIMcall.txt.NORMAL ]; then
    exit 1
fi

singularity exec $mimcall_img python3 /MIMcall2/bin/MERGE_MS.py  $output_dir/${tumor_name}.MIMcall.txt.CANCER $output_dir/${normal_name}.MIMcall.txt.NORMAL > $output_dir/${tumor_name}.MIMcall.txt.merged

if [ ! -s $output_dir/${tumor_name}.MIMcall.txt.merged ]; then
    exit 1
fi

singularity exec $mimcall_img perl /MIMcall2/bin/MIM_CALLER.pl -I $output_dir/${tumor_name}.MIMcall.txt.merged $MIM_CALLER_option > $output_dir/${tumor_name}.MIMcall.txt

if [ ! -s $output_dir/${tumor_name}.MIMcall.txt ]; then
    exit 1
fi
