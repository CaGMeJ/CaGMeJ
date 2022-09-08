sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=/cshare1,/home,/share

set -xv
output_dir=${output_dir}/mimcall/$tumor_name 

if [ ! -e  ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi

singularity exec $mimcall_img  samtools view $mimcall_samtools_view_option --region-file $mimcall_region_db  $tumor_bam > $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam
singularity exec $mimcall_img  samtools view $mimcall_samtools_view_option --region-file $mimcall_region_db $normal_bam > $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam

singularity exec $mimcall_img python3 /MIMcall2/bin/assign_reads.all_chr.py $mimcall_db $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam > $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam2

singularity exec $mimcall_img python3 /MIMcall2/bin/assign_reads.all_chr.py $mimcall_db  $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam > $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam2

singularity exec $mimcall_img perl /MIMcall2/bin/GPOS2RPOS_READ_F.pl $GPOS2RPOS_READ_F_option -I $output_dir/${tumor_name}.MIMcall.txt.CANCER.sam2  > $output_dir/${tumor_name}.MIMcall.txt.CANCER

singularity exec $mimcall_img perl /MIMcall2/bin/GPOS2RPOS.BLOOD.READ_F.pl $GPOS2RPOS_BLOOD_READ_F_option -I $output_dir/${normal_name}.MIMcall.txt.NORMAL.sam2  > $output_dir/${normal_name}.MIMcall.txt.NORMAL

singularity exec $mimcall_img python3 /MIMcall2/bin/MERGE_MS.py  $output_dir/${tumor_name}.MIMcall.txt.CANCER $output_dir/${normal_name}.MIMcall.txt.NORMAL > $output_dir/${tumor_name}.MIMcall.txt.merged

singularity exec $mimcall_img perl /MIMcall2/bin/MIM_CALLER.pl -I $output_dir/${tumor_name}.MIMcall.txt.merged $MIM_CALLER_option > $output_dir/${tumor_name}.MIMcall.txt
