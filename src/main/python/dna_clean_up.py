import os
import sys
import shutil
from nf_cfg_parser import Parser

output_dir = sys.argv[1]
nf_cfg1 = sys.argv[2]
nf_cfg2 = sys.argv[3]

def expr(S):
    flag = -1
    s = []

    for i in range(len(S)):
        if S[i] == "[":
           tmp = ""
        elif S[i] in {'"', "'"}:
           flag *= -1
        elif S[i] == " " and flag < 0:
           continue
        elif S[i] in {",", "]"}:
           s.append(tmp)
           tmp = ""
        else:
           tmp += S[i]
    return s


with open(nf_cfg1) as f:
    S = f.read()
    p = Parser(S)
    t,i = p.scan(-1, None)
    ref_fa = t["params"]["ref_fa"][1:-1]
    ref_fa_copy_enable = t["params"]["ref_fa_copy_enable"]
    sequenza_bam2seqz_enable = t["params"]["sequenza_bam2seqz_enable"]
    chr_list = t["params"]["chr_list"]
    facets_enable = t["params"]["facets_enable"]
    facets_chr_list = t["params"]["facets_chr_list"]
    genomon_mutation_enable = t["params"]["genomon_mutation_enable"]
    interval_list = t["params"]["interval_list"][1:-1]
    cram_enable = t["params"]["cram_enable"]

with open(nf_cfg2) as f:
    S = f.read()
    p = Parser(S)
    t,i = p.scan(-1, None)
    my_ref_fa = t["params"]["my_ref_fa"][1:-1]

sequenza_sample_list = []
genomon_mutation_sample_list = []

with open(output_dir + "/config/mutation_call_conf.csv") as f:
    for line in f:
        if line != "tumor,normal,tumor_bam,normal_bam\n":
            sequenza_sample_list.append(line.split(",")[0])
            genomon_mutation_sample_list.append(line.split(",")[0])

facets_sample_list = []

with open(output_dir + "/config/facets_conf.csv") as f:
    for line in f:
        if line != "tumor,normal,tumor_bam,normal_bam\n":
            facets_sample_list.append(line.split(",")[0])

bam_sample_list = []

with open(output_dir + "/config/bam_conf.csv") as f:
    for line in f:
        if line != "sample_name,bam_file\n":
            bam_sample_list.append(line.split(",")[0])

if ref_fa_copy_enable == "true":
    my_ref_fa_dir = os.path.dirname(my_ref_fa)
    if os.path.exists(my_ref_fa_dir):
        shutil.rmtree(my_ref_fa_dir)

if cram_enable == "true":
    for sample in  bam_sample_list:
               file_list = ["{}/bam/{}/{}.markdup.bam".format(output_dir, sample, sample),
                            "{}/bam/{}/{}.markdup.bam.bai".format(output_dir, sample, sample)]
    for f in file_list:
        if os.path.isfile(f):
            os.remove(f)

if  sequenza_bam2seqz_enable == "true":
    for Chr in expr(chr_list):
           for sample in  sequenza_sample_list:
               file_list = ["{}/sequenza/{}/seqz/{}_{}_out.seqz.gz".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}_out.seqz.gz.tbi".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}_small_out.seqz.gz".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}_small_out.seqz.gz.tbi".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}.hg19.bam".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}.hg19.sorted.bam".format(output_dir, sample, sample, Chr),
                            "{}/sequenza/{}/seqz/{}_{}.hg19.sorted.bam.bai".format(output_dir, sample, sample, Chr)]
               for f in file_list:
                   if os.path.isfile(f):
                       os.remove(f)

if facets_enable == "true":
    for Chr in expr(facets_chr_list):
        for sample in  facets_sample_list:
           file_list = ["{}/facets/{}/{}.{}.csv".format(output_dir, sample, sample, Chr),
                        "{}/facets/{}/{}.{}.csv.gz".format(output_dir, sample, sample, Chr)]
           for f in file_list:
                   if os.path.isfile(f):
                       os.remove(f)

if genomon_mutation_enable == "true":
    with open(interval_list) as lines:
        for line in lines:
            interval = line.rstrip("\n")
            for sample in  genomon_mutation_sample_list:
                file_list = ["{}/mutation/{}/{}.breakpoint_mutations.{}.txt".format(output_dir, sample, sample, interval),
                             "{}/mutation/{}/{}.fisher_mutations.{}.txt".format(output_dir, sample, sample, interval),
                             "{}/mutation/{}/{}.indel_mutations.{}.txt".format(output_dir, sample, sample, interval),
                             "{}/mutation/{}/{}.realignment_mutations.{}.txt".format(output_dir, sample, sample, interval),
                             "{}/mutation/{}/{}.simplerepeat_mutations.{}.txt".format(output_dir, sample, sample, interval),
                             "{}/mutation/{}/{}_mutations_candidate.{}.hg38_multianno.txt".format(output_dir, sample, sample, interval)]

                for f in file_list:
                   if os.path.isfile(f):
                       os.remove(f) 
