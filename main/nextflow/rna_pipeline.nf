output_dir = params.output_dir
sample_csv = params.output_dir + "/" + params.sample_csv
fusion_csv = params.output_dir + "/" + params.fusion_csv
htseq_csv = params.output_dir + "/" + params.htseq_csv
deseq2_csv = params.output_dir + "/" + params.deseq2_csv

params.each({key, value -> println "$key = $value"})

Channel
   .fromPath(fusion_csv)
   .splitCsv(header: true, sep: ",")
   .set { fusion_names }

Channel
   .fromPath(htseq_csv)
   .splitCsv(header: true, sep: ",")
   .set { htseq_names }

Channel
   .fromPath(deseq2_csv)
   .splitCsv(header: true, sep: " ")
   .set { deseq2_names }

Channel
   .fromPath(params.fastqc_csv)
   .splitCsv(header: true, sep: ",")   
   .into {fastq_files_fastqc}

Channel
   .fromPath(sample_csv)
   .splitCsv(header: true, sep: ",")
   .into { fastq_files_star }

Channel
   .of(1)
   .set {fastqc_list}

    
process fastqc_check{

    input:
    val  fastq from fastq_files_fastqc

    output:
    val "${fastq}" into fastq
    file "check.completed.txt"
    
    when:
    params.fastqc_enable
"""
output_dir=$params.output_dir
fastq=$fastq.fastq_file
sample_name="$fastq.sample_name"_"$fastq.fastq_number"
fastqc_option="$params.fastqc_option"
sleep_time=$params.sleep_time
fastqc_img=${params.img_dir}/$params.fastqc_img
source ${params.job_script}/fastqc.sh
echo -n > check.completed.txt
"""
}        

process make_fastqc_list{

    input:
    val  dummy from fastq.collect()
    output:
    val "fastqc_list" into fastqc_list_file
    file "check.completed.txt"

"""
output_dir=$params.output_dir
per_page=$params.per_page
fastqc_script_dir=$params.fastqc_script_dir
sleep_time=$params.sleep_time
source ${params.job_script}/fastqc_list.sh
echo -n > check.completed.txt
"""
} 

process star{

    input:
    val  fastq from fastq_files_star
 
    output:
    val "${fastq.sample_name}.Aligned.sortedByCoord.out.bam" into bam_files_fusion, bam_files_htseq
    file "check.completed.txt"

    """
    dict="$fastq"
    sleep_time=$params.sleep_time
    output_dir=$params.output_dir
    STAR_img=${params.img_dir}/${params.STAR_img}
    genome_lib_dir=${params.genome_lib_dir} 
    star_option="$params.star_option"
    source ${params.job_script}/star.sh
    echo -n > check.completed.txt
    """
}

process star_fusion{
    
    input:
    each sample_name_chimeric_out_junction_file from fusion_names
    val dummy  from params.star_enable ? bam_files_fusion.collect() : Channel.of(1)
    output:
    file "check.completed.txt"
    when:
    params.star_fusion_enable

    """
    chimeric_out_junction_file=$sample_name_chimeric_out_junction_file.chimeric_out_junction_file
    output_dir=${params.output_dir}
    sample_name=$sample_name_chimeric_out_junction_file.sample_name
    genome_lib_dir=${params.genome_lib_dir}
    STAR_img=${params.img_dir}/${params.STAR_img}
    sleep_time=$params.sleep_time
    source ${params.job_script}/star_fusion.sh
    echo -n > check.completed.txt
    """
}

process htseq{

    input:
    each sample_name from htseq_names
    val dummy  from params.star_enable ? bam_files_htseq.collect() : Channel.of(1)

    output:
    val "${sample_name}.count.txt" into count_files
    file "check.completed.txt"
"""
deseq2_img=${params.img_dir}/$params.deseq2_img
sample_name=$sample_name.sample_name
output_dir=$params.output_dir
gtf_file=$params.gtf_file
sleep_time=$params.sleep_time
source ${params.job_script}/htseq.sh
echo -n > check.completed.txt
"""
}

process deseq2{

    input:
    val deseq2_name from deseq2_names
    val dummy  from count_files.collect()
    output:
    file "check.completed.txt"
    
"""
deseq2_img=${params.img_dir}/$params.deseq2_img
tumor_name=${deseq2_name.tumor_panel_name}
normal_name=${deseq2_name.normal_panel_name}
tumor_list=${deseq2_name.tumor_file_list}
normal_list=${deseq2_name.normal_file_list}
output_dir=$params.output_dir
geneset=${params.geneset}
pseudo_count=${params.pseudo_count}
R_SCRIPT=${params.R_SCRIPT}
sleep_time=$params.sleep_time
source ${params.job_script}/deseq2.sh
echo -n > check.completed.txt
"""
}

