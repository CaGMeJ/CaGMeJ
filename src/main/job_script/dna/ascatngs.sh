sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=/cshare1,/home,/share
set -xv
set -e

if [ "$gender" = L ]; then
    gender="XX"
    if [ `cat $output_dir/cnvkit_compare/$tumor_name/is_male_reference.txt` = True ]; then
        gender="XY"
    fi
fi

out_dir=$output_dir/hyperclust/$tumor_name/ascatngs

if [ -e $out_dir ]; then
    rm -r  $out_dir
fi
mkdir -p $out_dir

#cnvkitのgenderを使う
# female: -gender XX
# male: -gender XY
# -genderChr Y or -genderChr chrY
set +e
singularity exec $ascatngs_img ascat.pl \
  -outdir $out_dir \
  -tumour $tumor_bam \
  -normal $normal_bam \
  -reference $ref_fa \
  -gender $gender \
  $ascatngs_option
set -e
tumor_name=`singularity exec $samtools_img samtools view -H $tumor_bam  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq `
if [ ! -e  $out_dir/${tumor_name}.copynumber.caveman.csv ]; then
    error=`grep "Error in ghs\[\[sample\]\] : subscript out of bounds" $out_dir/tmpAscat/logs/Sanger_CGP_Ascat_Implement_ascat.0.err`
    if [ ! "$error" ]; then
        exit 1
    fi
fi
