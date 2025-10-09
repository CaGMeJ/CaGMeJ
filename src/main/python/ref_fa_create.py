import os
import sys
import shutil
from parser import sample_csv
from nf_cfg_parser import Parser
import configparser as cp

sample_conf = sys.argv[1]
output_dir = sys.argv[2]
nf_cfg = sys.argv[3]

with open(nf_cfg) as f:
    S = f.read()
    p = Parser(S)    
    t,i = p.scan(-1, None)
    container_bin = t["params"]["container_bin"][1:-1]
    container_module_file = t["params"]["container_module_file"][1:-1]
    ref_fa = t["params"]["ref_fa"][1:-1]
    ref_fa_create_enable = t["params"]["ref_fa_copy_enable"]
    fastqc_enable = True if t["params"]["fastqc_enable"] == "true" else False
    parabricks_bammetrics_enable = True if t["params"]["parabricks_bammetrics_enable"] == "true" else False
    CollectWgsMetrics_enable = True if t["params"]["CollectWgsMetrics_enable"] == "true" else False
    CollectMultipleMetrics_enable = True if t["params"]["CollectMultipleMetrics_enable"] == "true" else False
    parabricks_mutect_enable = True if t["params"]["parabricks_mutect_enable"] == "true" else False
    parabricks_haplotypecaller_enable = True if t["params"]["parabricks_haplotypecaller_enable"] == "true" else False
    parabricks_deepvariant_enable = True if t["params"]["parabricks_deepvariant_enable"] == "true" else False
    parabricks_cnvkit_enable = True if t["params"]["parabricks_cnvkit_enable"] == "true" else False
    parabricks_strelka_enable = True if t["params"]["parabricks_strelka_enable"] == "true" else False
    cnvkit_compare_enable = True if t["params"]["cnvkit_compare_enable"] == "true" else False
    manta_enable = True if t["params"]["manta_enable"] == "true" else False
    gridss_enable = True if t["params"]["gridss_enable"] == "true" else False
    itd_assembler_enable = True if t["params"]["itd_assembler_enable"] == "true" else False
    msisensor_enable = True if t["params"]["msisensor_enable"] == "true" else False
    sequenza_bam2seqz_enable = True if t["params"]["sequenza_bam2seqz_enable"] == "true" else False
    ngscheckmate_enable = True if t["params"]["ngscheckmate_enable"] == "true" else False
    facets_enable = True if t["params"]["facets_enable"] == "true" else False
    mimcall_enable = True if t["params"]["mimcall_enable"] == "true" else False
    chord_enable = True if t["params"]["chord_enable"] == "true" else False
    genomon_mutation_enable = True if t["params"]["genomon_mutation_enable"] == "true" else False
    genomon_sv_enable = True if t["params"]["genomon_sv_enable"] == "true" else False
    post_analysis_mutation_enable = True if t["params"]["post_analysis_mutation_enable"] == "true" else False
    post_analysis_sv_enable = True if t["params"]["post_analysis_sv_enable"] == "true" else False
    pmsignature_full_enable = True if t["params"]["pmsignature_full_enable"] == "true" else False
    pmsignature_ind_enable = True if t["params"]["pmsignature_ind_enable"] == "true" else False
    paplot_enable = True if t["params"]["paplot_enable"] == "true" else False
    survirus_enable = True if t["params"]["survirus_enable"] == "true" else False
    ascatngs_enable = True if t["params"]["ascatngs_enable"] == "true" else False
    battenberg_enable = True if t["params"]["battenberg_enable"] == "true" else False
    cram2bam_enable = True if t["params"]["cram2bam_enable"] == "true" else False
    strelka_enable = True if t["params"]["strelka_enable"] == "true" else False
    pindel_enable = True if t["params"]["cgpPindel_enable"] == "true" else False

#####################
#
#   sample_conf
#   
######################
sc = sample_csv()
sc.read(sample_conf)
fastq_list = sc.fastq_list
cram_list = sc.cram_list

bam_dir = output_dir + "/bam"

markdup_files = list(map(lambda sample_name: bam_dir + "/" + sample_name + "/" + sample_name + ".markdup.bam", fastq_list.keys()))
markdup_decoded_files = list(map(lambda sample_name: bam_dir + "/" + sample_name + "/" + sample_name + ".markdup.decoded.bam", cram_list.keys()))

assert container_bin.replace(" ", "") in ["singularity", "apptainer"] , "container_bin is set to '" +container_bin+ "'. other than singularity or apptainer is not supported !"
assert container_module_file.split("/")[0].replace(" ", "") in ["singularity", "apptainer"] , "container_module_file is set to '" +container_module_file+ "'. other than singularity or apptainer is not supported !"

if fastqc_enable:
    assert len(fastq_list), "fastqc_enable is set to true, but fastq is not defined in csv file"
if CollectMultipleMetrics_enable | parabricks_bammetrics_enable:
    assert len(fastq_list) + len(sc.bam_list) + len(sc.cram_list), "set fastq, bam_import or cram_import in csv file" 

assert not (CollectWgsMetrics_enable and parabricks_bammetrics_enable), "Can not select both CollectWgsMetrics_enable and parabricks_bammetrics_enable"
assert not (strelka_enable and parabricks_strelka_enable), "Can not select both strelka_enable and parabricks_strelka_enable"
   
sample_conf_name = os.path.splitext(os.path.basename(sample_conf))[0]
bamimport_csv = sc.bamimport_csv(output_dir, sample_conf_name, markdup_files)
sc.bam_csv(output_dir, markdup_files)
if cram2bam_enable:
    sc.cram_csv(output_dir, markdup_decoded_files)
    sc.bam_csv(output_dir, markdup_decoded_files)
else:
    sc.bam_csv(output_dir, markdup_files)
sc.sample_conf_csv(output_dir)
sc.fastqc_conf_csv(output_dir)
sc.compare_conf_plus_csv(output_dir, "mutation_call", "control_panel", genomon_mutation_enable | parabricks_cnvkit_enable | parabricks_mutect_enable | sequenza_bam2seqz_enable | pindel_enable)
sc.single_conf_csv(output_dir, "deepvariant", parabricks_deepvariant_enable, "dna")
sc.compare_conf_plus_csv(output_dir, "sv_detection", "control_panel", genomon_sv_enable | itd_assembler_enable)
sc.compare_conf_csv(output_dir, "MSI", msisensor_enable)
sc.compare_conf_csv(output_dir, "facets", facets_enable)
sc.single_conf_csv(output_dir, "haplotype", parabricks_haplotypecaller_enable, "dna")
sc.compare_conf_plus_csv(output_dir, "manta", "analysis_type", manta_enable)
sc.compare_conf_plus_csv(output_dir, "cnvkit_compare", "male_reference_flag", cnvkit_compare_enable)
sc.compare_conf_csv(output_dir, "gridss", gridss_enable)
sc.compare_conf_csv(output_dir, "mimcall", mimcall_enable)
sc.single_conf_csv(output_dir, "chord", chord_enable, "dna")
sc.single_conf_csv(output_dir, "survirus", survirus_enable, "dna")
sc.compare_conf_plus_csv(output_dir, "ascatngs", "gender", ascatngs_enable)
sc.compare_conf_plus_csv(output_dir, "battenberg", "is_male", battenberg_enable)

parabricks_fq2bam_enable = "true" if len(sc.fastq_list) else "false"

#######################
#
#  ref_fa_create
#
#######################

ref_fa_dir = os.path.dirname(ref_fa) 
my_ref_fa = output_dir + "/" + "/".join(ref_fa.split("/")[-2:])
my_ref_fa_dir = output_dir + "/" + os.path.basename(ref_fa_dir)
if ref_fa_create_enable == "true":
    if not os.path.isdir(my_ref_fa_dir):
        shutil.copytree(ref_fa_dir, my_ref_fa_dir)
    else:
        print("skip ref_fa copy if os.path.isdir(my_ref_fa_dir) == true")

config_dir = output_dir + "/config/"
os.makedirs(config_dir, exist_ok=True)
file_path = config_dir  + "/nextflow_conf.cfg"

with open(file_path, mode = "w") as file:
               file.write("params {\n")
               file.write("     my_ref_fa = '" + my_ref_fa  + "'\n")
               file.write("     parabricks_fq2bam_enable = " + parabricks_fq2bam_enable  + "\n") 
               file.write("}")

print(my_ref_fa)
if ref_fa_create_enable == "true":
    os.utime(path=my_ref_fa+".fai")
else:
    os.utime(path=ref_fa+".fai")
