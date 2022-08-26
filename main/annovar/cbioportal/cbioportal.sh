set -e
python cbioportal_unsorted.py
cat hg19_cBioPortal_all_mutation_annovar_unsorted.txt | sort -V > hg19_cBioPortal_all_mutation_annovar_sorted.txt
python cbioportal_merge.py
