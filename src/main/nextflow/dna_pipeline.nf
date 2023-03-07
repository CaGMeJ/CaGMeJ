nextflow_parabricks_conf = params.nextflow_parabricks_conf 
nextflow_dir = params.nextflow_dir
output_dir = params.output_dir
python_dir = params.python_dir
sample_csv = params.output_dir + '/' + params.sample_csv
mutation_csv = params.output_dir + '/' + params.mutation_csv
deepvariant_csv = params.output_dir + '/' + params.deepvariant_csv
sv_csv = params.output_dir + '/' + params.sv_csv
manta_csv = params.output_dir + '/' + params.manta_csv
msi_csv = params.output_dir + '/' + params.msi_csv
bam_csv = params.output_dir + '/' + params.bam_csv
haplotype_csv = params.output_dir + '/' + params.haplotype_csv
facets_csv = params.output_dir + '/' + params.facets_csv
gridss_csv = params.output_dir + '/' + params.gridss_csv
cnvkit_compare_csv = params.output_dir + '/' + params.cnvkit_csv
mimcall_csv = params.output_dir + '/' + params.mimcall_csv
chord_csv = params.output_dir + '/' + params.chord_csv
fastqc_csv = params.output_dir + '/' + params.fastqc_csv

genomon_conf = params.genomon_conf
genomon_sample_conf = params.genomon_sample_conf

sleep_time = params.sleep_time

conda_dir = params.conda_dir
parabricks_version = params.parabricks_version
job_script = params.job_script
monitoring_enable = params.monitoring_enable
monitoring_script = params.monitoring_script
ref_fa = params.ref_fa_copy_enable ? params.my_ref_fa : params.ref_fa
interval_list = params.interval_list
R_script = params.R_script

fastqc_script_dir = params.fastqc_script_dir
fastqc_img = params.img_dir + '/' + params.fastqc_img
fastqc_option = params.fastqc_option
per_page = params.per_page

bwa_options = params.bwa_options
fq2bam_option = params.fq2bam_option

haplotype_option_list = params.haplotype_option_list

samtools_img = params.img_dir + '/' + params.samtools_img
tabix_img = params.img_dir + '/' + params.tabix_img

manta_img = params.img_dir + '/' + params.manta_img
manta_option = params.manta_option

gridss_img = params.img_dir + '/' + params.gridss_img
pondir = params.pondir
gridss_option = params.gridss_option
ref_type = params.ref_type

itd_img = params.img_dir + '/' + params.itd_img
exon_only = params.exon_only
exon_bed_file = params.exon_bed_file
phrap = params.phrap
bdir = params.bdir
annotation_bed_file = params.annotation_bed_file
cluster_bins_c = params.cluster_bins_c
cluster_bins_pkmer = params.cluster_bins_pkmer
iterate_on_bins_min_bin = params.iterate_on_bins_min_bin
iterate_on_bins_max_bin = params.iterate_on_bins_max_bin
iterate_on_bins_kmer = params.iterate_on_bins_kmer
iterate_on_bins_cov_cut_min = params.iterate_on_bins_cov_cut_min
iterate_on_bins_cov_cut_max = params.iterate_on_bins_cov_cut_max
post_processing_cutoff = params.post_processing_cutoff
post_processing_min_bin = params.post_processing_min_bin
post_processing_max_bin = params.post_processing_max_bin

msisensor_img = params.img_dir + '/' + params.msisensor_img
baseline_configure = params.baseline_configure

sequenza_R_img = params.img_dir + '/' + params.sequenza_R_img
sequenza_utils_img = params.img_dir + '/' + params.sequenza_utils_img
window_size = params.window_size
gc_file = params.gc_file
non_matching_normal_file = params.non_matching_normal_file
bam2seqz_option = params.bam2seqz_option
chain_file = params.chain_file
sequenza_ref_fa = params.sequenza_ref_fa
samtools_cpu = params.samtools_cpu
crossmap_option = params.crossmap_option


grep_option = params.grep_option
cnvkit_export_option = params.cnvkit_export_option

annovar_enable = params.annovar_enable
annovar = params.annovar
humandb = params.humandb
annovar_param = params.annovar_param
build_version = params.build_version

genomon_img = params.img_dir + '/' + params.genomon_img
genomon_ruffus_option = params.genomon_ruffus_option

params.each({key, value -> println "$key = $value"})
iterate_on_bins_range=Channel.of((iterate_on_bins_min_bin + 1 )..iterate_on_bins_max_bin)

Channel
   .fromPath(fastqc_csv)
   .splitCsv(header: true, sep: ",")   
   .into {fastq_files_fastqc}

Channel
   .value( params.chr_list )
   .into { chr_list_human; chr_list_human2 }

if ( params.non_matching_normal_enable ) {
   println "Check index file of non_matching_normal_file"
   file(non_matching_normal_file + ".bai", checkIfExists: true)
   println "OK"
   Channel
      .fromPath(mutation_csv)
      .splitCsv(header: true, sep: ",")
      .map{ it -> ["tumor": it.normal, "normal": "non_matching_normal", "tumor_bam": it.normal_bam, "normal_bam": "non_matching_normal" ]}
      .filter { it.tumor != "None" }
      .into { tumor_normal_names_bam2seqz_normal; tumor_normal_names_merge_normal }
}
else {
   Channel
      .empty()
      .into { tumor_normal_names_bam2seqz_normal; tumor_normal_names_merge_normal }
}

Channel
      .fromPath(mutation_csv)
      .splitCsv(header: true, sep: ",")
      .map{ it -> ["tumor": it.normal, "normal": "non_matching_normal", "tumor_bam": it.normal_bam, "normal_bam": "non_matching_normal" ]}
      .filter { it.tumor != "None" }
      .into { tumor_normal_names_crossmap_normal; tumor_normal_names_crossmap_merge_normal }

Channel
   .fromPath(mutation_csv)
   .splitCsv(header: true, sep: ",")
   .filter { it.normal != "None" }
   .into { tumor_normal_names_bam2seqz; tumor_normal_names_merge; tumor_normal_names_crossmap; tumor_normal_names_crossmap_merge }

Channel
   .fromPath(bam_csv)
   .splitCsv(header: true, sep: ",")
   .into{ sample_name_bam_file_bammetrics; sample_name_bam_file_CollectMultipleMetrics; sample_name_bam_file_CollectWgsMetrics; sample_name_bam_file_virus_count }


Channel
   .fromPath(haplotype_csv)
   .splitCsv(header: true, sep: ",")
   .set { sample_names_haplotypecaller }

Channel
   .fromPath(mutation_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_cnvkit }

Channel
   .fromPath(sv_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_ITD_cluster_bins; tumor_normal_names_ITD_iterate_on_bins; tumor_normal_names_ITD_post_processing }

Channel
   .fromPath(gridss_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_gridss; tumor_normal_names_gridss_former; tumor_normal_names_gridss_assembly; tumor_normal_names_gridss_latter }

gridss_node_index_range=Channel.of(0..(params.gridss_assembly_node-1))

Channel
   .fromPath(manta_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_manta }

Channel
   .fromPath(sample_csv)
   .splitCsv(header: true, sep: ",")
   .into { fastq_files_align }

Channel
   .fromPath(msi_csv)
   .splitCsv(header: true, sep: ",")
   .set { tumor_normal_names_msisensor }

Channel
   .fromPath(mutation_csv)
   .splitCsv(header: true, sep: ",")
   .filter { it.normal != "None" }
   .into { tumor_normal_names_mutect }

Channel
   .fromPath(deepvariant_csv)
   .splitCsv(header: true, sep: ",")
   .into { sample_names_deepvariant }
Channel
   .fromPath(params.bam_csv)
   .splitCsv(header: true, sep: ",")
   .into { sample_name_bam_file_ngscheckmate }

Channel
   .fromPath(params.facets_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_facets_pileup;  tumor_normal_names_facets_R }

Channel
   .value( params.facets_chr_list )
   .into { facets_chr_list }
Channel.fromPath(mimcall_csv)
       .splitCsv(header: true, sep: ",")
       .into{tumor_normal_names_mimcall}

Channel.fromPath(cnvkit_compare_csv)
       .splitCsv(header: true, sep: ",")
       .into{tumor_normal_names_cnvkit_compare; tumor_normal_names_cnvkit_compare_purity}
Channel
   .fromPath(chord_csv)
   .splitCsv(header: true, sep: ",")
   .set { sample_names_chord }
Channel
   .fromPath(params.interval_list)
   .splitText()
   .into { split_interval_list_mutation }

Channel
   .fromPath(mutation_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_mutation; tumor_normal_names_mutation_merge }

Channel
   .fromPath(sv_csv)
   .splitCsv(header: true, sep: ",")
   .into { tumor_normal_names_sv }
process fastqc_check{

    input:
    val  fastq from fastq_files_fastqc

    output:
    val "${fastq}" into fastq, fastq_2
    file "check.completed.txt"
    
    when:
    params.fastqc_enable
"""
output_dir=$output_dir
fastq=$fastq.fastq_file
sample_name="$fastq.sample_name"_"$fastq.fastq_number"
fastqc_option="$fastqc_option"
sleep_time=$sleep_time
fastqc_img=$fastqc_img
source ${job_script}/fastqc.sh
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
output_dir=$output_dir
per_page=$per_page
fastqc_script_dir=$fastqc_script_dir
sleep_time=$sleep_time
source ${job_script}/fastqc_list.sh
echo -n > check.completed.txt
"""
}          



process parabricks_fq2bam{

    input:
    val  fastq from  fastq_files_align
    output:
    val "${fastq.sample_name}.markdup.bam" into   bam_files_bammetrics, bam_files_mutect, bam_files_deepvariant, bam_files_cnvkit,  bam_files_genomon_pipeline, bam_files_CollectMultipleMetrics, bam_files_manta, bam_files_gridss, bam_files_itd_assembler, bam_files_msisensor, bam_files_bam2seqz,  bam_files_haplotypecaller, bam_files_facets, bam_files_NCM, bam_files_mimcall, bam_files_cnvkit_compare, bam_files_cnvkit_compare_purity, bam_files_genomon_mutation, bam_files_genomon_sv, bam_files_gridss_parallel, bam_files_CollectWgsMetrics, bam_files_virus_count
    file "check.completed.txt"
    when:
    !params.fastqc_only
"""
output_dir=$output_dir
dict="$fastq"
ref_fa=${ref_fa}
fq2bam_option="$fq2bam_option"
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
bwa_options="${bwa_options}"
sleep_time=$sleep_time
source ${job_script}/parabricks_fq2bam.sh
echo -n > check.completed.txt
"""
}

process CollectMultipleMetrics{

    input:
    each sample_name_bam_file from sample_name_bam_file_CollectMultipleMetrics
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_CollectMultipleMetrics.collect() : Channel.of(1)
    output:
    val "metrics.txt" into metrics_files_1
    file "check.completed.txt"
    when:
    params.CollectMultipleMetrics_enable
    
"""
bam_file=$sample_name_bam_file.bam_file
sample_name=$sample_name_bam_file.sample_name
output_dir=$output_dir
ref_fa=$ref_fa
sleep_time=$sleep_time
picard_img=${params.img_dir}/${params.picard_img}
source ${job_script}/CollectMultipleMetrics.sh
echo -n > check.completed.txt
"""
}


process parabricks_bammetrics{

    input:
    each sample_name_bam_file from sample_name_bam_file_bammetrics
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_bammetrics.collect() : Channel.of(1)
    output:
    val "metrics.txt" into metrics_files_2
    file "check.completed.txt"
    when:
    params.parabricks_bammetrics_enable

"""
bam_file=$sample_name_bam_file.bam_file
sample_name=$sample_name_bam_file.sample_name
output_dir=$output_dir
ref_fa=$ref_fa
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
sleep_time=$sleep_time
source ${job_script}/parabricks_bammetrics.sh
echo -n > check.completed.txt
"""
}

process CollectWgsMetrics{

    input:
    each sample_name_bam_file from sample_name_bam_file_CollectWgsMetrics
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_CollectWgsMetrics.collect() : Channel.of(1)
    output:
    val "collect_wgs_metrics.txt" into metrics_files_3
    file "check.completed.txt"
    when:
    params.CollectWgsMetrics_enable

"""
bam_file=$sample_name_bam_file.bam_file
sample_name=$sample_name_bam_file.sample_name
output_dir=$output_dir
ref_fa=$ref_fa
sleep_time=$sleep_time
gatk_img=${params.img_dir}/${params.gatk_img}
source ${job_script}/CollectWgsMetrics.sh
echo -n > check.completed.txt
"""
}


process multiqc{

    input:
     val dummy  from ( params.parabricks_fq2bam_enable  && params.fastqc_enable) ? fastq_2.collect() : Channel.of(1)
    val dummy2  from params.CollectMultipleMetrics_enable ? metrics_files_1.collect() : Channel.of(1)
    val dummy3  from params.parabricks_bammetrics_enable ? metrics_files_2.collect() : params.CollectWgsMetrics_enable ? metrics_files_3.collect() : Channel.of(1)
    output:
    file "check.completed.txt"
    when:
    params.fastqc_enable || params.CollectMultipleMetrics_enable ||  params.parabricks_bammetrics_enable || params.CollectWgsMetrics_enable
"""
multiqc_img=${params.img_dir}/${params.multiqc_img}
output_dir=${params.output_dir}
sleep_time=${params.sleep_time}
source ${params.job_script}/multiqc.sh
echo -n > check.completed.txt
"""
}
process parabricks_mutect{

    input:
    each tumor_normal_name from tumor_normal_names_mutect
     val dummy  from params.parabricks_fq2bam_enable ? bam_files_mutect.collect() : Channel.of(1)

    output:
    val "${tumor_normal_name.tumor}"  into out_mutect
    val "${tumor_normal_name.tumor}"  into out_mutect_chord 
    file "check.completed.txt"
    when:
    params.parabricks_mutect_enable

"""
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
output_dir=$output_dir
ref_fa=$ref_fa
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
sleep_time=$sleep_time
samtools_img=$samtools_img
annovar_enable=$annovar_enable
tabix_img=$tabix_img
gatk_img=${params.img_dir}/${params.gatk_img}
source ${job_script}/parabricks_mutect.sh
echo -n > check.completed.txt
"""
} 

process mutect_annovar{

    input:
    each tumor_name from out_mutect.collect()

    output:
    val "${tumor_name}"  into out_mutect_annovar 
    file "check.completed.txt"
  
    when:
    params.annovar_enable

"""
annovar=$annovar
annovar_param="$annovar_param"
humandb="$humandb"
tumor_name=$tumor_name
output_dir=$output_dir
build_version=$build_version
sleep_time=$sleep_time
source ${job_script}/mutect_annovar.sh
echo -n > check.completed.txt
"""
}

process parabricks_deepvariant{

    input:
    each sample_name from sample_names_deepvariant
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_deepvariant.collect() : Channel.of(1)

    output:
    val "${sample_name.sample_name}"  into out_deepvariant
    file "check.completed.txt"
 
    when:
    params.parabricks_deepvariant_enable

"""
sample_name=$sample_name.sample_name
bam_file=$sample_name.sample_bam
output_dir=$output_dir
ref_fa=$ref_fa
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
sleep_time=$sleep_time
annovar_enable=$annovar_enable
tabix_img=$tabix_img
source ${job_script}/parabricks_deepvariant.sh
echo -n > check.completed.txt
"""
} 

process deepvariant_annovar{

    input:
    each sample_name from out_deepvariant.collect()

    output:
    val "${sample_name}"  into out_deepvariant_annovar 
    file "check.completed.txt"
   
    when:
    params.annovar_enable

"""
annovar=$annovar
annovar_param="$annovar_param"
humandb="$humandb"
sample_name=$sample_name
output_dir=$output_dir
build_version=$build_version
sleep_time=$sleep_time
source ${job_script}/deepvariant_annovar.sh
echo -n > check.completed.txt
"""
}


process parabricks_haplotypecaller{

    input:
    each sample from sample_names_haplotypecaller
    val dummy from params.parabricks_fq2bam_enable ? bam_files_haplotypecaller.collect() : Channel.of(1)
    output:
    val "${sample.sample_name}"  into out_haplotypecaller
    file "check.completed.txt"
    when:
    params.parabricks_haplotypecaller_enable

"""
conda_dir=$conda_dir
sample_name=${sample.sample_name}
sample_bam=${sample.sample_bam}
output_dir=$output_dir
ref_fa=$ref_fa
haplotype_option_list="${haplotype_option_list}"
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
samtools_img=$samtools_img
tabix_img=$tabix_img
sleep_time=$sleep_time
source ${job_script}/parabricks_haplotypecaller.sh
echo -n > check.completed.txt
"""
}

process haplotype_annovar{

    input:
    each sample_name from out_haplotypecaller.collect()

    output:
    val "${sample_name}"  into out_haplotypecaller_annovar 
    file "check.completed.txt"
  
    when:
    params.haplotype_annovar_enable

"""
annovar=$annovar
annovar_param="$annovar_param"
humandb="$humandb"
haplotype_option_list="${haplotype_option_list}"
sample_name=$sample_name
output_dir=$output_dir
build_version=$build_version
sleep_time=$sleep_time
source ${job_script}/haplotype_annovar.sh
echo -n > check.completed.txt
"""
}

process parabricks_cnvkit{

    input:
    each tumor_normal_name from tumor_normal_names_cnvkit
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_cnvkit.collect() : Channel.of(1)
 
    output:
    val "${tumor_normal_name.tumor}" into out_cnvkit
    file "check.completed.txt"

    when:
    params.parabricks_cnvkit_enable
"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
output_dir=$output_dir
ref_fa=$ref_fa
parabricks_version=$parabricks_version
monitoring_enable=$monitoring_enable
monitoring_script=$monitoring_script
sleep_time=$sleep_time
source ${job_script}/parabricks_cnvkit.sh
echo -n > check.completed.txt
"""
}

process cnvkit_graphics{

    input:
    each tumor_name from out_cnvkit.collect()
    output:
    file "check.completed.txt"   
"""
cnvkit_img=${params.img_dir}/${params.cnvkit_img}
tumor_name=$tumor_name
output_dir=$output_dir
grep_option="$grep_option"
cnvkit_export_option="$cnvkit_export_option"
sleep_time=$sleep_time
source ${job_script}/cnvkit_graphics.sh
echo -n > check.completed.txt
"""
}
process sequenza_gc_wiggle{

    input:
    val dummy  from Channel.of(1)

    output:
    val "GRCh37.gc${params.window_size}Base.wig.gz"  into  out_sequenza_gc_wiggle
    file "check.completed.txt"

    when:
    params.sequenza_gc_wiggle_enable
"""
window_size=$window_size
ref_fa=$sequenza_ref_fa
output_dir=$output_dir
sleep_time=$sleep_time
sequenza_utils_img=$sequenza_utils_img
source ${job_script}/sequenza_gc_wiggle.sh
echo -n > check.completed.txt
"""
}

process sequenza_crossmap{

    input:
    each tumor_normal_name from tumor_normal_names_crossmap.mix(tumor_normal_names_crossmap_normal)
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_bam2seqz.collect() : Channel.of(1)
    val dummy2 from params.sequenza_gc_wiggle_enable ? out_sequenza_gc_wiggle.collect() : Channel.of(1)
    each chr from chr_list_human

    output:
    val "hg19_${tumor_normal_name.tumor}_${chr}.bam" into crossmap_bam
    file "check.completed.txt" 
   
    when:
    params.sequenza_bam2seqz_enable 
"""
chr=$chr
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
non_matching_normal_file=$non_matching_normal_file
output_dir=$output_dir
window_size=$window_size
gc_file=$gc_file
bam2seqz_option="$bam2seqz_option"
ref_fa=$sequenza_ref_fa
chain_file=$chain_file
sleep_time=$sleep_time
samtools_img=$samtools_img
sequenza_utils_img=$sequenza_utils_img
crossmap_option=$crossmap_option
source ${job_script}/sequenza_crossmap.sh
echo -n > check.completed.txt
"""
}

process sequenza_crossmap_merge{

    input:
    each tumor_normal_name from tumor_normal_names_crossmap_merge.mix(tumor_normal_names_crossmap_merge_normal)
    val dummy  from crossmap_bam.collect() 

    output:
    val "hg19_${tumor_normal_name.tumor}.bam" into crossmap_merge_bam
    file "check.completed.txt" 
    
"""
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
output_dir=$output_dir
samtools_cpu=$samtools_cpu
chr_list="$params.chr_list"
sleep_time=$sleep_time
samtools_img=$samtools_img
source ${job_script}/sequenza_crossmap_merge.sh
echo -n > check.completed.txt
"""
}

process sequenza_bam2seqz{

    input:
    each tumor_normal_name from tumor_normal_names_bam2seqz.mix(tumor_normal_names_bam2seqz_normal)
    val dummy  from crossmap_merge_bam.collect() 
    each chr from chr_list_human2

    output:
    val "${tumor_normal_name.tumor}_${chr}_out.seqz.gz" into seqz_gz_files
    file "check.completed.txt"
   
    when:
    params.sequenza_bam2seqz_enable 
"""
chr=$chr
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
non_matching_normal_file=$non_matching_normal_file
output_dir=$output_dir
window_size=$window_size
gc_file=$gc_file
bam2seqz_option="$bam2seqz_option"
ref_fa=$sequenza_ref_fa
chain_file=$chain_file
sleep_time=$sleep_time
sequenza_utils_img=$sequenza_utils_img
source ${job_script}/sequenza_bam2seqz.sh
echo -n > check.completed.txt
"""
}

process sequenza_merge{

    input:
    each tumor_normal_name from tumor_normal_names_merge.mix(tumor_normal_names_merge_normal)
    val dummy  from seqz_gz_files.collect()
    output:
    val "cellurarity_ploidy" into sequenza_output_files
    file "check.completed.txt"

"""
python_dir=$python_dir
tumor_name=$tumor_normal_name.tumor
output_dir=$output_dir
R_script=$R_script
chr_list="$params.chr_list"
sleep_time=$sleep_time
sequenza_R_img=$sequenza_R_img
tabix_img=$tabix_img
source ${job_script}/sequenza_merge.sh
echo -n > check.completed.txt
"""
}
process msisensor_pro{

    input:
    each tumor_normal_name from tumor_normal_names_msisensor 
    val dummy  from  params.parabricks_fq2bam_enable ? bam_files_msisensor.collect() : Channel.of(1)
    output:
    file "check.completed.txt"    
    when:
    params.msisensor_enable

"""
msisensor_img=$msisensor_img
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
output_dir=$output_dir
ref_fa=$ref_fa
baseline_configure=$baseline_configure
sleep_time=$sleep_time
source ${job_script}/msisensor-pro.sh > .out.txt
echo -n > check.completed.txt
"""
} 
process manta{

    input:
    each tumor_normal_name from tumor_normal_names_manta
    val dummy from params.parabricks_fq2bam_enable ? bam_files_manta.collect() : Channel.of(1)
    output:
    file "check.completed.txt"
    when:
    params.manta_enable
"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
normal_name=$tumor_normal_name.normal
normal_bam=$tumor_normal_name.normal_bam
analysis_type=$tumor_normal_name.analysis_type
output_dir=$output_dir
ref_fa=$ref_fa
manta_option="$manta_option"
manta_img=$manta_img
sleep_time=$sleep_time
source ${job_script}/manta.sh
echo -n > check.completed.txt
"""
}


process ITD_cluster_bins{

    input:
    each tumor_normal_name from tumor_normal_names_ITD_cluster_bins
    val dummy from params.parabricks_fq2bam_enable ? bam_files_itd_assembler.collect() : Channel.of(1)

    output:
    val "ITD_cluster_bins" into out_ITD_cluster_bins
    file "check.completed.txt"

    when:
    params.itd_assembler_enable
"""
itd_img=$itd_img
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
annotation_bed_file=$annotation_bed_file
exon_only=$exon_only
exon_bed_file=$exon_bed_file
output_dir=$output_dir
cluster_bins_c=$cluster_bins_c
cluster_bins_pkmer=$cluster_bins_pkmer
sleep_time=$sleep_time
source ${job_script}/ITD_cluster_bins.sh
echo -n > check.completed.txt
"""
}

process ITD_iterate_on_bins{

    input:
    each tumor_normal_name from tumor_normal_names_ITD_iterate_on_bins
    val dummy from out_ITD_cluster_bins.collect()
    each i from iterate_on_bins_range
    output: 
    val "ITD_iterate_on_bins" into out_ITD_iterate_on_bins
    file "check.completed.txt"

"""
itd_img=$itd_img
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
output_dir=$output_dir
python_dir=$python_dir
i=$i
iterate_on_bins_min_bin=$iterate_on_bins_min_bin
iterate_on_bins_max_bin=$iterate_on_bins_max_bin
iterate_on_bins_kmer=$iterate_on_bins_kmer
iterate_on_bins_cov_cut_min=$iterate_on_bins_cov_cut_min
iterate_on_bins_cov_cut_max=$iterate_on_bins_cov_cut_max
phrap=$phrap
sleep_time=$sleep_time
source ${job_script}/ITD_iterate_on_bins.sh
echo -n > check.completed.txt
"""
}

process ITD_post_processing{

    input:
    val tumor_normal_name from tumor_normal_names_ITD_post_processing
    val dummy from out_ITD_iterate_on_bins.collect()
    output:
    file "check.completed.txt"
"""
itd_img=$itd_img
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
output_dir=$output_dir
post_processing_cutoff=$post_processing_cutoff
post_processing_min_bin=$post_processing_min_bin
post_processing_max_bin=$post_processing_max_bin
annotation_bed_file=$annotation_bed_file
bdir=$bdir
sleep_time=$sleep_time
source ${job_script}/ITD_post_processing.sh
echo -n > check.completed.txt
"""
}
process gridss_former{

    input:
    each tumor_normal_name from tumor_normal_names_gridss_former
    val dummy from params.parabricks_fq2bam_enable ? bam_files_gridss_parallel.collect() : Channel.of(1)
    output:
    val "${tumor_normal_name.tumor}"  into out_gridss_assembly
    file "check.completed.txt"
    when:
    params.gridss_enable && params.gridss_assembly_node > 1
"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
normal_name=$tumor_normal_name.normal
normal_bam=$tumor_normal_name.normal_bam
pondir=$params.pondir
output_dir=$params.output_dir
gridss_option="$params.gridss_option"
gridss_img=${params.img_dir}/$params.gridss_img
R_script=$params.R_script
ref_fa=$ref_fa
ref_type=$params.ref_type
sleep_time=$params.sleep_time
source ${params.job_script}/gridss_former.sh
echo -n > check.completed.txt
"""
}

process gridss_assembly{

    input:
    each tumor_normal_name from tumor_normal_names_gridss_assembly
    each gridss_node_index from gridss_node_index_range
    val dummy from out_gridss_assembly.collect()
    output:
    val "${tumor_normal_name.tumor}"  into out_gridss_latter
    file "check.completed.txt"
"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
normal_name=$tumor_normal_name.normal
normal_bam=$tumor_normal_name.normal_bam
pondir=$params.pondir
output_dir=$params.output_dir
gridss_option="$params.gridss_option"
gridss_img=${params.img_dir}/$params.gridss_img
R_script=$params.R_script
ref_fa=$ref_fa
ref_type=$params.ref_type
sleep_time=$params.sleep_time
gridss_node_index=$gridss_node_index
gridss_assembly_node=$params.gridss_assembly_node
source ${params.job_script}/gridss_assembly.sh
echo -n > check.completed.txt
"""
}

process gridss_latter{

    input:
    each tumor_normal_name from tumor_normal_names_gridss_latter
    val dummy from out_gridss_latter.collect()
    output:
    val "${tumor_normal_name.tumor}"  into out_gridss_parallel_chord
    file "check.completed.txt"

"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
normal_name=$tumor_normal_name.normal
normal_bam=$tumor_normal_name.normal_bam
pondir=$params.pondir
output_dir=$params.output_dir
gridss_option="$params.gridss_option"
gridss_img=${params.img_dir}/$params.gridss_img
R_script=$params.R_script
ref_fa=$ref_fa
ref_type=$params.ref_type
sleep_time=$params.sleep_time
source ${params.job_script}/gridss_latter.sh
echo -n > check.completed.txt
"""
}

process gridss{

    input:
    each tumor_normal_name from tumor_normal_names_gridss
    val dummy from params.parabricks_fq2bam_enable ? bam_files_gridss.collect() : Channel.of(1)
    output:
    val "${tumor_normal_name.tumor}"  into out_gridss_chord
    file "check.completed.txt"
    when:
    params.gridss_enable && params.gridss_assembly_node == 1
"""
tumor_name=$tumor_normal_name.tumor
tumor_bam=$tumor_normal_name.tumor_bam
normal_name=$tumor_normal_name.normal
normal_bam=$tumor_normal_name.normal_bam
pondir=$params.pondir
output_dir=$params.output_dir
gridss_work_dir=$params.gridss_work_dir
gridss_work_dir_count_limit=$params.gridss_work_dir_count_limit
gridss_wait_time=$params.gridss_wait_time
gridss_option="$params.gridss_option"
gridss_img=${params.img_dir}/${params.gridss_img}
R_script=$params.R_script
ref_fa=$ref_fa
ref_type=$params.ref_type
sleep_time=$params.sleep_time
source ${params.job_script}/gridss.sh
echo -n > check.completed.txt
"""
}
process genomon_pipeline{

    input:
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_genomon_pipeline.collect() : Channel.of(1)
    output:
    val "paplot" into genomon_output_files
    file "check.completed.txt"
    when:
    params.genomon_pipeline_enable
"""
ruffus_option="$genomon_ruffus_option"
target_pipeline=dna
sample_conf=$genomon_sample_conf
project_dir=$output_dir
genomon_conf=$genomon_conf
sleep_time=$sleep_time
output_dir=$output_dir
source ${job_script}/genomon_pipeline.sh
echo -n > check.completed.txt
"""
}
process NCM_pileup{

    input:
    each sample_name from sample_name_bam_file_ngscheckmate
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_NCM.collect() : Channel.of(1)

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

process facets_pileup{
    input:
    each tumor_normal_name from tumor_normal_names_facets_pileup
    each chr from facets_chr_list
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_facets.collect() : Channel.of(1)
    output:
    file "check.completed.txt"
    val "${tumor_normal_name.tumor}" into out_facets_pileup
    when:
    params.facets_enable
"""
tumor_name=${tumor_normal_name.tumor}
tumor_bam=${tumor_normal_name.tumor_bam}
normal_name=${tumor_normal_name.normal}
normal_bam=${tumor_normal_name.normal_bam}
sleep_time=${params.sleep_time}
chr=$chr
facets_pileup_vcf=${params.facets_pileup_vcf}
facets_img=${params.img_dir}/${params.facets_img}
output_dir=${params.output_dir}
snp_pileup_option="${params.snp_pileup_option}"
source ${params.job_script}/facets_pileup.sh 
echo -n > check.completed.txt
"""
}


process facets_R{
   input:
   each tumor_normal_name from tumor_normal_names_facets_R
   val dummy from out_facets_pileup.collect()

   output:
   file "check.completed.txt"
   path "${tumor_normal_name.tumor}" into out_facets_R
   
"""
sleep_time=${params.sleep_time}
facets_img=${params.img_dir}/${params.facets_img}
output_dir=${params.output_dir}
tumor_name=${tumor_normal_name.tumor}
R_script=${params.R_script}
facets_chr_list="${params.facets_chr_list}"
source ${params.job_script}/facets_R.sh
echo -n > check.completed.txt
"""
}
process mimcall{
    input:
    each tumor_normal_name from tumor_normal_names_mimcall
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_mimcall.collect() : Channel.of(1)
   
    output:
    val "${tumor_normal_name.tumor}.MIMcall.txt " into out_mimcall
    file "check.completed.txt"
    when:
    params.mimcall_enable
"""
tumor_name=${tumor_normal_name.tumor}
tumor_bam=${tumor_normal_name.tumor_bam}
normal_name=${tumor_normal_name.normal}
normal_bam=${tumor_normal_name.normal_bam}
sleep_time=${params.sleep_time}
mimcall_img=${params.img_dir}/${params.mimcall_img}
output_dir=${params.output_dir}
mimcall_samtools_view_option="${params.mimcall_samtools_view_option}"
mimcall_region_db=${params.mimcall_region_db}
mimcall_db=${params.mimcall_db}
GPOS2RPOS_READ_F_option="${params.GPOS2RPOS_READ_F_option}"
GPOS2RPOS_BLOOD_READ_F_option="${params.GPOS2RPOS_BLOOD_READ_F_option}"
MIM_CALLER_option="${params.MIM_CALLER_option}"
source ${params.job_script}/mimcall.sh 
echo -n > check.completed.txt
"""
}

process mimcall_result{
    input:
    val dummy from out_mimcall.collect()

    output:
    file "check.completed.txt"
"""
sleep_time=${params.sleep_time}
mimcall_csv=${mimcall_csv}
output_dir=${params.output_dir}
source ${params.job_script}/mimcall_result.sh
echo -n > check.completed.txt
"""
}

process cnvkit_compare{
    input:
    each tumor_normal_name from tumor_normal_names_cnvkit_compare
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_cnvkit_compare.collect() : Channel.of(1)
   
    output:
    file "check.completed.txt"
    val "${tumor_normal_name.tumor}.markdup.cns" into out_cnvkit_compare
    when:
    params.cnvkit_compare_enable
"""
tumor_name=${tumor_normal_name.tumor}
tumor_bam=${tumor_normal_name.tumor_bam}
normal_name=${tumor_normal_name.normal}
normal_bam=${tumor_normal_name.normal_bam}
male_reference_flag=${tumor_normal_name.male_reference_flag}
sleep_time=${params.sleep_time}
cnvkit_img=${params.img_dir}/${params.cnvkit_img}
ref_fa=${params.ref_fa}
cnvkit_compare_option="${params.cnvkit_compare_option}"
cnvkit_export_option="${params.cnvkit_export_option}"
grep_option="${params.grep_option}"
output_dir=${params.output_dir}
source ${params.job_script}/cnvkit_compare.sh 
echo -n > check.completed.txt
"""
}

process cnvkit_compare_purity{
    input:
    each tumor_normal_name from tumor_normal_names_cnvkit_compare_purity
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_cnvkit_compare_purity.collect() : Channel.of(1)
    val dummy2  from out_cnvkit_compare.collect()
    each tumor from out_facets_R.filter{file(it).text == "true\n"}.map(path -> file(path).baseName).collect()
   
    output:
    file "check.completed.txt"
    when:
    params.facets_enable && params.cnvkit_compare_enable && params.cnvkit_compare_purity_enable && tumor_normal_name.tumor == tumor
"""
tumor_name=${tumor_normal_name.tumor}
tumor_bam=${tumor_normal_name.tumor_bam}
male_reference_flag=${tumor_normal_name.male_reference_flag}
sleep_time=${params.sleep_time}
cnvkit_img=${params.img_dir}/${params.cnvkit_img}
cnvkit_export_option="${params.cnvkit_export_option}"
grep_option="${params.grep_option}"
output_dir=${params.output_dir}
source ${params.job_script}/cnvkit_compare_purity.sh 
echo -n > check.completed.txt
"""
}

process chord{
    input:
    each sample_name from sample_names_chord
    val dummy  from out_mutect_chord.collect()
    val dummy2  from  params.gridss_assembly_node == 1 ? out_gridss_chord.collect() : out_gridss_parallel_chord.collect()

    output:
    val "${sample_name.sample_name}.txt" into out_chord
    file "check.completed.txt"
    when:
    params.chord_enable && params.gridss_enable && params.parabricks_mutect_enable
"""
sample_name=$sample_name.sample_name
bam_file=$sample_name.sample_bam
sleep_time=${params.sleep_time}
chord_img=${params.img_dir}/${params.chord_img}
chord_chr_list="${params.chord_chr_list}"
tabix_img=${tabix_img}
output_dir=${params.output_dir}
R_script=${params.R_script}
source ${params.job_script}/chord.sh 
echo -n > check.completed.txt
"""
}

process chord_summary{
    input:
    val dummy from out_chord.collect()
   
    output:
    file "check.completed.txt"

"""
sleep_time=${params.sleep_time}
output_dir=${params.output_dir}
python_dir=${params.python_dir}
chord_csv=${chord_csv}
source ${params.job_script}/chord_summary.sh 
echo -n > check.completed.txt
"""
}
process genomon_mutation{

    input:
    each tumor_normal_name from tumor_normal_names_mutation
    each interval from split_interval_list_mutation
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_genomon_mutation.collect() : Channel.of(1)

    output:
    val "${tumor_normal_name.tumor}_mutations_candidate.multianno.txt"  into  out_mutation
    file "check.completed.txt"

    when:
    params.genomon_mutation_enable
"""
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
sleep_time=${params.sleep_time}
genomon_img=${params.img_dir}/${params.genomon_img}
simple_repeat_db=${params.simple_repeat_db}
fisher_single_params='${params.fisher_single_params}'
fisher_pair_params='${params.fisher_pair_params}'
fisher_single_samtools_params="${params.fisher_single_samtools_params}"
fisher_pair_samtools_params="${params.fisher_pair_samtools_params}"
mutfilter_realignment_params='${params.mutfilter_realignment_params}'
mutfilter_indel_params='${params.mutfilter_indel_params}'
mutfilter_indel_samtools_params='${params.mutfilter_indel_samtools_params}'
mutfilter_breakpoint_params='${params.mutfilter_breakpoint_params}'
REGION=${interval}
ref_fa=${ref_fa}
output_dir=${params.output_dir}
source ${params.job_script}/genomon_mutation_call.sh
echo -n > check.completed.txt
"""
}

process genomon_mutation_merge{

    input:
    val dummy from out_mutation.collect()
    each tumor_normal_name from  tumor_normal_names_mutation_merge 

    output:
    val "${tumor_normal_name.tumor}.genomon_mutation.result.txt"  into  out_mutation_merge
    file "check.completed.txt"
"""
annovar_enable=${params.annovar_enable}
output_dir=${params.output_dir}
genomon_img=${params.img_dir}/${params.genomon_img}
build_version=${params.build_version}
interval_list=${params.interval_list}
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
sleep_time=${params.sleep_time}
mutil_single_params='${params.mutil_single_params}'
mutil_pair_params='${params.mutil_pair_params}'
annovar=${params.annovar}
build_version=${params.build_version}
humandb=${params.humandb}
annovar_enable=${params.annovar_enable}
annovar_param='${params.annovar_param}'
source ${params.job_script}/genomon_mutation_merge.sh
echo -n > check.completed.txt
"""
}


process genomon_sv{

    input:
    each tumor_normal_name from tumor_normal_names_sv
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_genomon_sv.collect() : Channel.of(1)
    output:
    val "${tumor_normal_name.tumor}.genomonSV.result.txt" into out_sv
    file "check.completed.txt"
    when:
    params.genomon_sv_enable

"""
output_dir=${params.output_dir}
ref_fa=${ref_fa}
tumor_name=$tumor_normal_name.tumor
normal_name=$tumor_normal_name.normal
tumor_bam=$tumor_normal_name.tumor_bam
normal_bam=$tumor_normal_name.normal_bam
build_version=${params.build_version}
interval_list=${params.interval_list}
sleep_time=${params.sleep_time}
genomon_img=${params.img_dir}/${params.genomon_img}
genomon_sv_parse_param='${params.genomon_sv_parse_param}'
genomon_sv_filt_param='${params.genomon_sv_filt_param}'
sv_utils_param='${params.sv_utils_param}'
source ${params.job_script}/genomon_sv.sh
echo -n > check.completed.txt
"""
}

process genomon_post_analysis_and_pmsignature{

    input:
    val dummy from out_mutation_merge.collect()
    val dummy2 from out_sv.collect()

    output:
    file "check.completed.txt"

    when:
    params.post_analysis_mutation_enable || params.post_analysis_sv_enable
"""
mutation_csv=$mutation_csv
sv_csv=$sv_csv
genomon_img=${params.img_dir}/${params.genomon_img}
genomon_r_img=${params.img_dir}/${params.genomon_r_img}
annovar_enable=${params.annovar_enable}
post_analysis_mutation_enable=${params.post_analysis_mutation_enable}
post_analysis_sv_enable=${params.post_analysis_sv_enable}
output_dir=${params.output_dir}
sample_csv=$sample_csv
pa_conf=${params.pa_conf}
sleep_time=${params.sleep_time}
pmsignature_full_enable=${params.pmsignature_full_enable}
pmsignature_full_signum_min=${params.pmsignature_full_signum_min}
pmsignature_full_signum_max=${params.pmsignature_full_signum_max}
pmsignature_full_trdirflag=${params.pmsignature_full_trdirflag}
pmsignature_full_trialnum=${params.pmsignature_full_trialnum}
pmsignature_full_bgflag=${params.pmsignature_full_bgflag}
pmsignature_full_bs_genome=${params.pmsignature_full_bs_genome}
pmsignature_full_txdb_transcript=${params.pmsignature_full_txdb_transcript}
pmsignature_ind_enable=${params.pmsignature_ind_enable}
pmsignature_ind_signum_min=${params.pmsignature_ind_signum_min}
pmsignature_ind_signum_max=${params.pmsignature_ind_signum_max}
pmsignature_ind_trdirflag=${params.pmsignature_ind_trdirflag}
pmsignature_ind_trialnum=${params.pmsignature_ind_trialnum}
pmsignature_ind_bgflag=${params.pmsignature_ind_bgflag}
pmsignature_ind_bs_genome=${params.pmsignature_ind_bs_genome}
pmsignature_ind_txdb_transcript=${params.pmsignature_ind_txdb_transcript}
paplot_enable=${params.paplot_enable}
paplot_conf=${params.paplot_conf}
python_dir=${params.python_dir}
job_script=${params.job_script}
source ${params.job_script}/post_analysis_and_pmsignature.sh
echo -n > check.completed.txt
"""
}

process virus_count{

    input:
    each sample_name_bam_file from sample_name_bam_file_virus_count
    val dummy  from params.parabricks_fq2bam_enable ? bam_files_virus_count.collect() : Channel.of(1)
    output:
    val "virus_count.txt" into virus_count_files
    file "check.completed.txt"
    when:
    params.virus_count_enable

"""
bam_file=$sample_name_bam_file.bam_file
sample_name=$sample_name_bam_file.sample_name
output_dir=$output_dir
bowtie_ref=$params.bowtie_ref
sleep_time=$sleep_time
python_dir=${params.python_dir}
virus_count_img=${params.img_dir}/${params.virus_count_img}
source ${job_script}/virus_count.sh
echo -n > check.completed.txt
"""
}
