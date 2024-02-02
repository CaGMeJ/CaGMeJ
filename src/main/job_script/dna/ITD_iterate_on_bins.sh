sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

output_dir=$output_dir/ITD/$tumor_name
kmer=$iterate_on_bins_kmer
cov_cut_min=$iterate_on_bins_cov_cut_min
cov_cut_max=$iterate_on_bins_cov_cut_max
phrap=$phrap
workdir=`pwd`

set -xv
set +e

i=$i 
    if [ ! -e $output_dir/${i}_cluster ]; then
        mkdir -p $output_dir/${i}_cluster
    fi
    cat $output_dir/global/cluster_N_fq_reads.txt | grep ^${i} > $output_dir/${i}_cluster/${i}_reads.txt
    if [ ! -s $output_dir/${i}_cluster/${i}_reads.txt ]; then
        cd $workdir
        return
    fi
    cd $output_dir/${i}_cluster
    singularity exec $itd_img make_fq $output_dir/${i}_cluster/${i}_reads.txt $output_dir/${i}_cluster/${i}_reads.fq || exit $?
    singularity exec $itd_img all_complement $output_dir/${i}_cluster/${i}_reads.fq $output_dir/${i}_cluster/both_reads.txt || exit $?
    singularity exec $itd_img python $python_dir/itdassembler/find_kmers_2_latest.py  $output_dir/${i}_cluster/both_reads.txt $kmer  $output_dir/${i}_cluster $cov_cut_min $cov_cut_max || exit $?
    cat adjacency_matrix.txt |grep -v "Nothing"|awk '{print $2" "$4}' >adjacency_matrix_1.txt || exit $?
    tmp=`cat filter_sorted_kmer_frequency.txt | wc -l` 
    if [ $tmp =  0 ]; then
        cd $workdir
        return
    fi
    singularity exec $itd_img compute_cycles adjacency_matrix_1.txt $tmp out_run.txt $i > first_run.txt || exit $?
    singularity exec $itd_img extract_kmers_latest $output_dir/${i}_cluster/filter_sorted_kmer_frequency.txt $output_dir/${i}_cluster/out_run.txt $output_dir/${i}_cluster/in_hap_pipeline.txt || exit $?
    singularity exec $itd_img fastq_line_2 $output_dir/${i}_cluster/${i}_reads.fq $output_dir/${i}_cluster/lined_reads.fq || exit $?
    singularity exec $itd_img grep_reads $output_dir/${i}_cluster/lined_reads.fq $output_dir/${i}_cluster/in_hap_pipeline.txt $output_dir/${i}_cluster/out_phrap_reads.txt || exit $?
    if [ ! -s $output_dir/${i}_cluster/out_phrap_reads.txt ]; then
        cd $workdir
        return
    fi
    sort $output_dir/${i}_cluster/out_phrap_reads.txt -o $output_dir/${i}_cluster/s_out_phrap_reads.txt || exit $?
    singularity exec $itd_img make_unique $output_dir/${i}_cluster/s_out_phrap_reads.txt $output_dir/${i}_cluster/u_out_phrap_reads.txt || exit $?
    singularity exec $itd_img make_fq_pipeline $output_dir/${i}_cluster/u_out_phrap_reads.txt $output_dir/${i}_cluster/u_out_phrap_reads.fq || exit $?
    $phrap -ace $output_dir/${i}_cluster/u_out_phrap_reads.fq || exit $?

    cd $workdir
