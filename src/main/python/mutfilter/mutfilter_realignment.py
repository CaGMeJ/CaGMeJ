#GenomonMutationFilter(Version 0.3.1) modified
#https://github.com/Genomon-Project/GenomonMutationFilter/blob/devel/genomon_mutation_filter/realignment_filter.py
import sys
import pysam
import edlib
from scipy.stats import fisher_exact as fisher
import math
in_mutation_file = sys.argv[1]
in_tumor_bam = sys.argv[2]
in_normal_bam = sys.argv[3]
reference_genome =  sys.argv[4]
read_length = int(sys.argv[5])
bamfile_T = pysam.AlignmentFile(in_tumor_bam, "rb")
bamfile_N = pysam.AlignmentFile(in_normal_bam, "rb")
tmp = -100
window = int(sys.argv[6])
exclude_sam_flags = int(sys.argv[7]) 

interval_list = []
with open(in_mutation_file) as lines:
    for line in lines:
        columns = line.rstrip("\n").split("\t")
        Chr, s, e, Ref, Alt = columns[:5]
        Other = columns[5:]
        Start = int(s) - 1
        End = int(e)
        if Start < tmp + read_length:
             interval_list[-1][3].append((Chr, Start, End, Ref, Alt, Other))
             interval_list[-1][2] = max(interval_list[-1][2], End)
        else:
             interval_list.append([Chr, Start, End, [(Chr, Start, End, Ref, Alt, Other)]])
        tmp = End

for Chr, Start, End, mutation in interval_list:
    interval = Chr + ":" + str(int(Start) - window + 1) +"-"+ str(int(End) + window)
    target = ""
    for item in pysam.faidx(reference_genome, interval).split("\n")[1:-1]:
        target += item
    tumor = [[set(),set(),set()] for _ in range(len(mutation)+1)]
    normal = [[set(),set(),set()] for _ in range(len(mutation)+1)]
    for bamfile, memo in zip([bamfile_T, bamfile_N], [tumor, normal]):
        query_set = {}
        for read in bamfile.fetch(Chr, Start, End):
            read_flag = int(read.flag)
            if 0 != int(bin(exclude_sam_flags & read_flag),2): continue
            query = read.seq
            qname = read.qname
            rstart = read.reference_start
            rend = read.reference_end
            if (query, rstart, rend) in query_set:
                query_set[(query, rstart, rend)].add(qname)
            else:
                query_set[(query, rstart, rend)] = {qname}

        for (query, rstart, rend), v in query_set.items():
            for i, (c, s, e, r, a, o) in enumerate(mutation):
                if a == "-":
                    bias = len(r)
                else:
                    bias = 1 
                if not ((rstart - bias) < s and s < rend):
                    continue
                ref = target[s-Start:len(target)-(End-e)]
                if r == "-":   alt = ref[0:(window + 1)] + a + ref[-window:]
                elif a == "-": alt = ref[0:window] + ref[-window:]
                else:          alt = ref[0:window] + a + ref[-window:]
                ref_nm = edlib.align(query, ref, mode="HW", task="path")['editDistance'] + 1
                alt_nm = edlib.align(query, alt, mode="HW", task="path")['editDistance'] + 1
                memo[i][min((ref_nm//alt_nm) + (ref_nm > alt_nm), 2)] |= v

    for i, (c, s, e, r, a, o) in enumerate(mutation):
        tumor_ref, tumor_other, tumor_alt = [len(v) for v in tumor[i]]
        normal_ref, normal_other, normal_alt = [len(v) for v in normal[i]]
        odds_ratio, fisher_pvalue = fisher(( (tumor_ref,normal_ref), (tumor_alt,normal_alt) ), alternative='two-sided')
        if fisher_pvalue < 10**(-60):
            log10_fisher_pvalue = '60.0'
        elif fisher_pvalue  > 1.0 - 10**(-10):
            log10_fisher_pvalue = '0.0'
        else:
            log10_fisher_pvalue = '{0:.3f}'.format(float(-math.log( fisher_pvalue, 10 )))
        print("\t".join([c, str(s+1), str(e), r, a, *o, str(tumor_ref), str(tumor_alt), str(tumor_other), str(normal_ref), str(normal_alt), str(normal_other), str(log10_fisher_pvalue)])) 
