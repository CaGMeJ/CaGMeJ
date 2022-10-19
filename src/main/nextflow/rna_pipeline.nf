output_dir = params.output_dir
sample_csv = params.output_dir + "/" + params.sample_csv
fusion_csv = params.output_dir + "/" + params.fusion_csv
htseq_csv = params.output_dir + "/" + params.htseq_csv
deseq2_csv = params.output_dir + "/" + params.deseq2_csv
genomon_fusion_csv = params.output_dir + "/" + params.genomon_fusion_csv
genomon_expression_csv = params.output_dir + "/" + params.genomon_expression_csv

params.each({key, value -> println "$key = $value"})

Channel
   .fromPath(fusion_csv)
   .splitCsv(header: true, sep: ",")
   .set { fusion_names }

Channel
   .fromPath(htseq_csv)
   .splitCsv(header: true, sep: ",")
   .into { htseq_names; sample_name_bam_file_ngscheckmate }

Channel
   .fromPath(genomon_fusion_csv)
   .splitCsv(header: true, sep: ",")
   .into { sample_name_bam_file_genomon_fusion }

Channel
   .fromPath(genomon_expression_csv)
   .splitCsv(header: true, sep: ",")
   .into { sample_name_bam_file_genomon_expression }

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
    val "${fastq.sample_name}.Aligned.sortedByCoord.out.bam" into bam_files_fusion, bam_files_htseq, bam_files_NCM, bam_files_genomon_fusion, bam_files_genomon_expression
    file "check.completed.txt"

    """
    dict="$fastq"
    sleep_time=$params.sleep_time
    output_dir=$params.output_dir
    STAR_img=${params.img_dir}/${params.STAR_img}
    genome_lib_dir=${params.genome_lib_dir} 
    star_option="$params.star_option"
    picard_img=${params.img_dir}/${params.picard_img}
    source ${params.job_script}/star.sh
    echo -n > check.completed.txt
    """
}

process NCM_pileup{

    input:
    each sample_name from sample_name_bam_file_ngscheckmate
    val dummy  from params.star_enable ? bam_files_NCM.collect() : Channel.of(1)

    output:
    file "check.completed.txt"
    val "${sample_name.sample_name}.vcf" into out_NCM

    when:
    params.ngscheckmate_enable
"""
sleep_time="${params.sleep_time}"
ngscheckmate_enable="${params.ngscheckmate_enable}"
NCM_mpileup_option="${params.NCM_mpileup_option}"
NCM_bed="${params.NCM_bed}"
ref_fa="${params.ref_fa}"
ngscheckmate_img=${params.img_dir}/${params.ngscheckmate_img}
sample_name=$sample_name.sample_name
bam_file=$sample_name.bam_file
output_dir=${params.output_dir}
source ${params.job_script}/NCM_pileup.sh
echo -n > check.completed.txt
"""
}


process NCM_run{

    input:
    val dummy from out_NCM.collect()

    output:
    file "check.completed.txt"
"""
sleep_time="${params.sleep_time}"
NCM_mpileup_option="${params.NCM_mpileup_option}"
NCM_bed="${params.NCM_bed}"
ngscheckmate_img=${params.img_dir}/${params.ngscheckmate_img}
output_dir=${params.output_dir}
source ${params.job_script}/NCM_run.sh
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

     when:
     params.expression_analysis_enable
"""
deseq2_img=${params.img_dir}/$params.deseq2_img
sample_name=$sample_name.sample_name
output_dir=$params.output_dir
gtf_file=$params.gtf_file
sleep_time=$params.sleep_time
bam_file=$sample_name.bam_file
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


process genomon_fusion{

    input:
    each sample_name from sample_name_bam_file_genomon_fusion
    val dummy  from params.star_enable ? bam_files_genomon_fusion.collect() : Channel.of(1) 
    output:
    val "genomonFusion.result.filt.txt" into genomon_fusion_output_files
    file "check.completed.txt"
    when:
    params.genomon_fusion_enable
"""
ref_fa=$params.ref_fa
genomon_rna_img=${params.img_dir}/${params.genomon_rna_img}
sample_name=$sample_name.sample_name
bam_file=$sample_name.sample_bam
sleep_time=$params.sleep_time
output_dir=$params.output_dir
refGene_bed=$params.fusion_refGene_bed 
ensGene_bed=$params.fusion_ensGene_bed 
refExon_bed=$params.fusion_refExon_bed 
ensExon_bed=$params.fusion_ensExon_bed
fusionfusion_option="${params.fusionfusion_option}"
fusion_utils_filt_option="${params.fusion_utils_filt_option}"
source ${params.job_script}/genomon_fusion.sh
echo -n > check.completed.txt
"""
}

process genomon_expression{

    input:
    each sample_name from sample_name_bam_file_genomon_expression
    val dummy  from params.star_enable ? bam_files_genomon_expression.collect() : Channel.of(1)
    output:
    val "genomonExpression.result.txt" into genomon_expression_output_files
    file "check.completed.txt"
    when:
    params.genomon_expression_enable
"""
genomon_rna_img=${params.img_dir}/${params.genomon_rna_img}
sample_name=$sample_name.sample_name
bam_file=$sample_name.sample_bam
sleep_time=$params.sleep_time
output_dir=$params.output_dir
refExon_ex_bed=$params.expression_refExon_ex_bed
genomon_expression_option="${params.genomon_expression_option}"
source ${params.job_script}/genomon_expression.sh
echo -n > check.completed.txt
"""
}
