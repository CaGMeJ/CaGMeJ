import re
import os

class sample_csv:
     def read(self, file_path):

          with open(file_path) as file:
               mode = ""
               self.genomon_qc = set()
               self.sample_conf = {}

               lines = file.readlines()
               for line in lines:
                    config = re.sub("[\s\n\t]", "", line)
                    if config.startswith('#'):
                         continue 
                    if config.startswith('['):
                         mode = re.search("(?<=\[)(.+?)(?=\])",config).group()
                         self.sample_conf[mode] = []
                         continue
                    if len(config) and mode != "":
                         self.sample_conf[mode].append(config)
          assert  "fastq" in self.sample_conf.keys() or "bam_import" in self.sample_conf.keys(), file_path + ' must contain [fastq] or [bam_import]' 
          self.sample_csv_path = file_path
          self.parser()                    
   
     def parser(self):
          self.bam_list = {}
          self.fastq_list = {}
          self.fastq_max = 0
          self.expression = []
          self.fusion = []
          self.tumorpanel = {}
          self.controlpanel = {}
          self.controlpanel["None"] = []
          self.tumorpanel["None"] = []

          if "fastq" in self.sample_conf.keys():
               count = 0
               for config in self.sample_conf["fastq"]:
                    tmp = config.split(",")
                    if len(tmp) == 1:
                        sample_name = tmp[0]
                        assert not sample_name in self.fastq_list, 'sample name is duplicated.'
                        self.fastq_list[sample_name] = []
                        self.fastq_max = max(self.fastq_max, count)
                        count = 0
                    else:
                        assert  len(tmp) == 3, 'You must set "fastq1,fastq2,RG".'
                        fastq1, fastq2, RG = tmp
                        self.fastq_list[sample_name].append((fastq1, fastq2, RG))
                        count += 1
               self.fastq_max = max(self.fastq_max, count)

          if "bam_import" in self.sample_conf.keys():
               for config in self.sample_conf["bam_import"]:
                    sample_name, bam_file = config.split(",")
                    assert os.path.exists(bam_file + ".bai"), bam_file + ".bai soes not exist"
                    self.bam_list[sample_name] = bam_file

          if "expression" in self.sample_conf.keys():
               for config in self.sample_conf[ "expression"]:
                    self.expression.append(config.split(","))

          if "fusion" in self.sample_conf.keys():
               for config in self.sample_conf[ "fusion"]:
                   self.fusion.append(config)    

          if "controlpanel" in self.sample_conf.keys():
               for config in self.sample_conf[ "controlpanel"]:
                    controlpanel_tmp  = config.split(",")
                    controlpanel_name = controlpanel_tmp[0]
                    controlpanel_sample_name = controlpanel_tmp[1:]
                    self.controlpanel[controlpanel_name] = controlpanel_sample_name

          if "tumorpanel" in self.sample_conf.keys():
               for config in self.sample_conf[ "tumorpanel"]:
                    tumorpanel_tmp  = config.split(",")
                    tumorpanel_name = tumorpanel_tmp[0]
                    tumorpanel_sample_name = tumorpanel_tmp[1:]
                    self.tumorpanel[tumorpanel_name] = tumorpanel_sample_name
          
         

     def bamimport_csv(self, output_dir, sample_conf_name, markdup_bam_files):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          bamimport_file = output_dir + "/config/" + sample_conf_name + ".bamimport.csv"
          with open(bamimport_file, mode = "w") as file:
               file.write("[bam_import]" + "\n")
               for markdup_bam_file in markdup_bam_files:
                    sample_name = os.path.basename(markdup_bam_file).split('.')[0] 
                    file.write(sample_name + "," + markdup_bam_file + "\n")
               for sample_name, bam_file in self.bam_list.items():
                    file.write(sample_name + "," + bam_file + "\n")

               for mode in self.sample_conf.keys():
                    if mode in { "mutation_call", "sv_detection"}:
                        file.write("[" + mode + "]" + "\n")
                        for config in self.sample_conf[mode]:
                            file.write(config + "\n")
          return bamimport_file

     def bam_csv(self, output_dir, markdup_bam_files):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          bam_csv = output_dir + "/config/bam_conf.csv"  

          with open(bam_csv, mode = "w") as file:
               file.write("sample_name,bam_file" + "\n")
               for markdup_bam_file in markdup_bam_files:
                    sample_name = os.path.basename(markdup_bam_file).split('.')[0]
                    file.write(sample_name + "," + markdup_bam_file + "\n")
               for sample_name, bam_file in self.bam_list.items():
                    file.write(sample_name + "," + bam_file + "\n")

     def sample_conf_csv(self, output_dir):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/sample_conf.csv"
          with open(file_path, mode = "w") as file:
               header = "sample_name"
               for num in range(1, (self.fastq_max*2)+1):
                   header += ",fastq" + str(num)
               for num in range(self.fastq_max):
                   header += ",RG{}_{}".format(num+1,num+1+self.fastq_max)
               file.write(header + "\n")

               for sample_name, fastq_list in self.fastq_list.items():
                    fastq_list_tmp = ["None" for _ in range(self.fastq_max*2)]
                    rg_tmp = ["None" for _ in range(self.fastq_max)]
                    for index, (fastq1, fastq2, RG) in enumerate(fastq_list):
                        err_msg = "See " + self.sample_csv_path + ". {} does not exit"
                        assert os.path.exists(fastq1), err_msg.format(fastq1)
                        assert os.path.exists(fastq2), err_msg.format(fastq2)
                        fastq_list_tmp[index] = fastq1
                        fastq_list_tmp[index+self.fastq_max] = fastq2
                        rg_tmp[index] = RG

                    file.write(",".join([sample_name] + fastq_list_tmp + rg_tmp ) + "\n")
     def fastqc_conf_csv(self, output_dir):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/fastqc_conf.csv"
          with open(file_path, mode = "w") as file:
               header = "sample_name,fastq_number,fastq_file"
               file.write(header + "\n")

               for sample_name, fastq_list in self.fastq_list.items():
                    fastq_list_tmp = ["None" for _ in range(self.fastq_max*2)]
                    for index, (fastq1, fastq2, RG) in enumerate(fastq_list):
                        err_msg = "See " + self.sample_csv_path + ". {} does not exit"
                        assert os.path.exists(fastq1), err_msg.format(fastq1)
                        assert os.path.exists(fastq2), err_msg.format(fastq2)
                        fastq_list_tmp[index] = fastq1
                        fastq_list_tmp[index+self.fastq_max] = fastq2
                    for index, fastq in enumerate(fastq_list_tmp):
                        file.write("{},{},{}\n".format(sample_name, index+1, fastq))

                    
     def compare_conf_csv(self, output_dir, config_type, enable):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/" + config_type + "_conf.csv"
          check_sample_name = set(list(self.bam_list.keys()) +  list(self.fastq_list.keys()) + ["None"])

          with open(file_path, mode = "w") as file:
               file.write("tumor,normal,tumor_bam,normal_bam\n")
               if enable:
                   assert config_type in self.sample_conf.keys(), config_type + " is not defined in csv file."
                   assert len(self.sample_conf[config_type]), config_type + " is not defined in csv file."
               else:
                   return 0 
               for config in self.sample_conf[config_type]:
                    tumor_name, normal_name = config.split(",")
                    tumor_bam = output_dir \
                                + "/bam/" \
                                + tumor_name \
                                + "/" \
                                + tumor_name \
                                + ".markdup.bam"

                    normal_bam = output_dir \
                                + "/bam/" \
                                + normal_name \
                                + "/" \
                                + normal_name \
                                + ".markdup.bam"

                    if normal_name == "None":
                        normal_bam = "None"

                    assert tumor_name in check_sample_name, tumor_name + " is not defined."
                    assert normal_name in check_sample_name, normal_name + " is not defined."
                    if tumor_name in self.bam_list:
                        tumor_bam = self.bam_list[tumor_name]
                    if normal_name in self.bam_list:
                        normal_bam = self.bam_list[normal_name]
                    file.write(",".join([tumor_name, normal_name] + [tumor_bam, normal_bam]) + "\n")  

     def single_conf_csv(self, output_dir, config_type, enable):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/" + config_type + "_conf.csv"
          check_sample_name = set(list(self.bam_list.keys()) +  list(self.fastq_list.keys()) + ["None"])
          with open(file_path, mode = "w") as file:
               file.write("sample_name,sample_bam\n")
               if enable:
                   assert config_type in self.sample_conf.keys(), config_type + " is not defined in csv file."
                   assert len(self.sample_conf[config_type]), config_type + " is not defined in csv file."
               else:
                   return 0
               for config in self.sample_conf[config_type]:
                    sample_name = config
                    sample_bam = output_dir \
                                + "/bam/" \
                                + sample_name \
                                + "/" \
                                + sample_name \
                                + ".markdup.bam"

                    assert sample_name in check_sample_name, sample_name + " is not defined."

                    if sample_name in self.bam_list:
                        sample_bam = self.bam_list[sample_name]
                    file.write(",".join([sample_name, sample_bam]) + "\n")

     def compare_conf_plus_csv(self, output_dir, config_type, plus, enable):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/" + config_type + "_conf.csv"
          check_sample_name = set(list(self.bam_list.keys()) +  list(self.fastq_list.keys()) + ["None"])
          with open(file_path, mode = "w") as file:
               file.write("tumor,normal,tumor_bam,normal_bam," + plus + "\n")
               if enable:
                   assert config_type in self.sample_conf.keys(), config_type + " is not defined in csv file."
                   assert len(self.sample_conf[config_type]), config_type + " is not defined in csv file."
               else:
                   return 0
               for config in self.sample_conf[config_type]:
                    tumor_name, normal_name, plus = config.split(",")
                    tumor_bam = output_dir \
                                + "/bam/" \
                                + tumor_name \
                                + "/" \
                                + tumor_name \
                                + ".markdup.bam"

                    normal_bam = output_dir \
                                + "/bam/" \
                                + normal_name \
                                + "/" \
                                + normal_name \
                                + ".markdup.bam"

                    if normal_name == "None":
                        normal_bam = "None"

                    assert tumor_name in check_sample_name, tumor_name + " is not defined."
                    assert normal_name in check_sample_name, normal_name + " is not defined."
                    if tumor_name in self.bam_list:
                        tumor_bam = self.bam_list[tumor_name]
                    if normal_name in self.bam_list:
                        normal_bam = self.bam_list[normal_name]
                    file.write(",".join([tumor_name, normal_name] + [tumor_bam, normal_bam] + [plus]) + "\n")  
     
     def expression_conf(self, output_dir):
          config_dir = output_dir + "/config/"
          os.makedirs(config_dir, exist_ok=True)
          file_path = config_dir  + "/deseq2.csv"
          htseq_list = set()
          with open(file_path, mode = "w") as file:
               file.write("tumor_panel_name tumor_file_list normal_panel_name normal_file_list\n")
               for index, (tumorpanel_name, controlpanel_name) in enumerate(self.expression):

                    err_msg = "See " + self.sample_csv_path + ". " + tumorpanel_name + " is not set in tumorpanel."
                    assert tumorpanel_name in self.tumorpanel.keys(), err_msg

                   
                    err_msg = "See " + self.sample_csv_path + ". " + controlpanel_name + " is not set in controlpanel."
                    assert  controlpanel_name in self.controlpanel.keys(), err_msg

                    tumor_list = self.tumorpanel[tumorpanel_name]
                    htseq_list |= set(tumor_list)
                    file.write(tumorpanel_name + " ")
                    file.write(",".join(tumor_list))
                    file.write(" ")
                    normal_list = self.controlpanel[controlpanel_name]
                    htseq_list |= set(normal_list)
                    file.write(controlpanel_name + " ")
                    file.write(",".join(normal_list))
                    file.write("\n")

               
                    err_msg = "See " + self.sample_csv_path + ". " + "expression requires at least 2 replicates"
                    assert len(tumor_list) + len(normal_list) > 1, err_msg

          return htseq_list    
