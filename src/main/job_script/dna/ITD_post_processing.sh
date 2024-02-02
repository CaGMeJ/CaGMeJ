sleep $sleep_time
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

output_dir=$output_dir/ITD/$tumor_name
results_dir_name=post_processing
annotation_bed_file=$annotation_bed_file
cutoff=$post_processing_cutoff
min_bin=$post_processing_min_bin
max_bin=$post_processing_max_bin
bdir=$bdir

set -xv
set +e
if [ ! -e $output_dir/$results_dir_name ]; then
    mkdir -p $output_dir/$results_dir_name
fi

echo -n > $output_dir/$results_dir_name/all_contigs.txt

for i in `seq $min_bin $max_bin`
do
    ls $output_dir/${i}_cluster/*.contigs >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        continue
    else
        cat $output_dir/${i}_cluster/*.contigs >> $output_dir/$results_dir_name/all_contigs.txt
    fi
done

singularity exec $itd_img make_results_line_2 $output_dir/$results_dir_name/all_contigs.txt  $output_dir/$results_dir_name/pre_l_results.fa.contigs || exit $?

singularity exec $itd_img blastn -db $bdir -query $output_dir/$results_dir_name/pre_l_results.fa.contigs -out $output_dir/$results_dir_name/f_original_contigs.fa -outfmt 6 -max_target_seqs 1 || exit $?

singularity exec $itd_img rem_ref_contigs $output_dir/$results_dir_name/f_original_contigs.fa $output_dir/$results_dir_name/f_l_results.fa.contigs || exit $?

singularity exec $itd_img make_results_line $output_dir/$results_dir_name/all_contigs.txt $output_dir/$results_dir_name/l_results.fa.contigs || exit $?

singularity exec $itd_img dup_rem_first $output_dir/$results_dir_name/l_results.fa.contigs $output_dir/$results_dir_name/f_l_results.fa || exit $?

singularity exec $itd_img cat /ITD-Assembler-master/empty.txt >> $output_dir/$results_dir_name/f_l_results.fa || exit $?

singularity exec $itd_img blastn -db $bdir -query $output_dir/$results_dir_name/f_l_results.fa -out  $output_dir/$results_dir_name/blast_f_l_results.fa -outfmt 6 -max_target_seqs 1 || exit $?

singularity exec $itd_img filter_frm_blast $output_dir/$results_dir_name/blast_f_l_results.fa $output_dir/$results_dir_name/f_results.bed $cutoff || exit $?

sed -i -e "s/^chrchr/chr/g" $output_dir/$results_dir_name/f_results.bed || exit $?

singularity exec $itd_img intersectBed -a  $output_dir/$results_dir_name/f_results.bed -b $annotation_bed_file -wa -wb >  $output_dir/$results_dir_name/pre_f_results.bed || exit $?

singularity exec $itd_img python /ITD-Assembler-master/bin/filter_frm_bed.py $output_dir/$results_dir_name $max_bin || exit $?


