import gzip
import sys

vcf = sys.argv[1]

with gzip.open(vcf, mode = "rt") as lines:
    for line in lines:
        if line[0] == "#":
            if line[:15] == "##FORMAT=<ID=DP":
                print('##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">')
            print(line.rstrip("\n"))
            continue
        else:
           CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT, NORMAL, TUMOR = line.rstrip("\n").split("\t")

           FORMAT = "GT:" + FORMAT
           NORMAL = "0/0:" + NORMAL
           TUMOR = "0/1:" + TUMOR
           print("\t".join([CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO, FORMAT, NORMAL, TUMOR]))
