import os
import sys
from parser import sample_csv

sample_conf = sys.argv[1]
output_dir = sys.argv[2]

sc = sample_csv()
sc.read(sample_conf)

config_dir = output_dir + "/config"

sc.sample_conf_csv(output_dir)
sc.fastqc_conf_csv(output_dir)
htseq_list = sc.expression_conf(output_dir)
fusion_list = sc.fusion

fastq_list = sc.fastq_list
star_dir = output_dir + "/star"
markdup_files = list(map(lambda sample_name: star_dir + "/" + sample_name + "/" + sample_name + ".Aligned.sortedByCoord.out.bam", fastq_list.keys()))
sc.bam_csv(output_dir, markdup_files)
star_enable = "true" if len(sc.fastq_list) else "false"

file_path_fusion = config_dir  + "/fusion.csv"

with open(file_path_fusion, mode = "w") as file:
    check_sample_name = set(list(sc.bam_list.keys()) +  list(sc.fastq_list.keys()))
    file.write("sample_name,chimeric_out_junction_file\n")
    for sample_name in fusion_list:
         chimeric_out_junction = "None"
 
         assert sample_name in check_sample_name, sample_name + " is not defined."
         if sample_name in sc.bam_list:
             sample_bam = sc.bam_list[sample_name]
             input_dir = os.path.dirname(sample_bam)
      
             chimeric_out_junction = input_dir + "/" + os.path.basename(sample_bam).split(".")[0] + ".Chimeric.out.junction"
             err_msg = "See " + input_dir + ". " + chimeric_out_junction + " does not exit"
             assert os.path.exists(chimeric_out_junction), err_msg 
         file.write(sample_name + "," + chimeric_out_junction  +"\n")

file_path = config_dir  + "/nextflow_conf.cfg"

with open(file_path, mode = "w") as file:
               file.write("params {\n")
               file.write("     star_enable = " + star_enable  + "\n")
               file.write("}")
