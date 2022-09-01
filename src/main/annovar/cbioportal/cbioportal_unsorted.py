import glob

hg38 = open("hg38_cBioPortal_all_mutation_annovar_unsorted.txt", mode="w")
hg19 = open("hg19_cBioPortal_all_mutation_annovar_unsorted.txt", mode="w")
other = open("other_cBioPortal_all_mutation_annovar_unsorted.txt", mode="w")


for file_path in glob.glob('public/*mutations.txt'):
    study_id = file_path[7:-4]
    dic = {}
    with open(file_path) as lines:
        for line in lines:
          if line[0] == "#":
              continue
          if line[:11] == "Hugo_Symbol":
              tmp = line.rstrip("\n").split("\t")
              dic = {tmp[i].lower() :i for i in range(len(tmp))}
              continue
          try:
            tmp = line.rstrip("\n").split("\t")
            Chr = tmp[dic["chromosome"]]
            Start = tmp[dic["start_position"]]
            if tmp[dic["tumor_seq_allele1"]] == "":
                continue
            End = str(int(Start) + len(tmp[dic["tumor_seq_allele1"]]) - 1)
            gene = tmp[dic["hugo_symbol"]] 
            Ref = tmp[dic["reference_allele"]]
            Alt = tmp[dic["tumor_seq_allele2"]]
            Mutation_type = tmp[dic["variant_classification"]]
            Variant_type = tmp[dic["variant_type"]]
            t_ref_count = tmp[dic["t_ref_count"]] if "t_ref_count" in dic else "."
            t_alt_count = tmp[dic["t_alt_count"]] if "t_alt_count" in dic else "."
            n_ref_count = tmp[dic["n_ref_count"]] if "n_ref_count" in dic else "."
            n_alt_count = tmp[dic["n_alt_count"]] if "n_alt_count" in dic else "."
            sample_id = tmp[dic["tumor_sample_barcode"]] 

            if Alt == "" or sample_id == "":
                continue  
            if Chr == "X": Chr = "23"
            if Chr == "Y": Chr = "24"
            #print("\t".join([Chr, Start, End, gene, Ref, Alt, Mutation_type, Variant_type, t_ref_count, t_alt_count, n_ref_count, n_alt_count]))
            info = "\t".join([Chr, Start, End, Ref, Alt, ",".join([gene, Mutation_type, Variant_type, t_ref_count, t_alt_count, n_ref_count, n_alt_count, study_id, sample_id])])
            if tmp[3] == "GRCh37": 
                hg19.write(info + "\n")
            elif tmp[3] == "GRCh38":
                hg38.write(info + "\n")
            else:
                other.write(info + "\n")
          except Exception as e:
            print(file_path, tmp)
            print(e)
            import sys
            sys.exit()



