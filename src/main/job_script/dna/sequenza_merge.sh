sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
chr_list=`echo "$chr_list" | sed -e 's/\,\|\[\|]//g'`
output_dir=${output_dir}/sequenza/${tumor_name}

if [ ! -e $output_dir/seqz ]; then
 mkdir -p  $output_dir/seqz
fi

if [ ! -e $output_dir/sequenza ]; then
 mkdir -p  $output_dir/sequenza
fi

tmp_chr=`echo "$chr_list" | awk '{print $1}'`

zcat ${output_dir}/seqz/${tumor_name}_${tmp_chr}_out.seqz.gz | head -1  >  ${output_dir}/seqz/${tumor_name}_all_out.seqz
zcat ${output_dir}/seqz/${tumor_name}_${tmp_chr}__small_out.seqz.gz | head -1 >  ${output_dir}/seqz/${tumor_name}_all_small_out.seqz 

for chr in $chr_list
do
    zcat ${output_dir}/seqz/${tumor_name}_${chr}_out.seqz.gz | sed -e '1d' >>  ${output_dir}/seqz/${tumor_name}_all_out.seqz 
    zcat ${output_dir}/seqz/${tumor_name}_${chr}_small_out.seqz.gz | sed -e '1d' >>  ${output_dir}/seqz/${tumor_name}_all_small_out.seqz 
done

singularity exec $tabix_img bgzip -f ${output_dir}/seqz/${tumor_name}_all_out.seqz
singularity exec $tabix_img bgzip -f ${output_dir}/seqz/${tumor_name}_all_small_out.seqz

singularity exec $tabix_img tabix -f -s 1 -b 2 -e 2 -S 1   ${output_dir}/seqz/${tumor_name}_all_out.seqz.gz
singularity exec $tabix_img tabix -f -s 1 -b 2 -e 2 -S 1   ${output_dir}/seqz/${tumor_name}_all_small_out.seqz.gz


if [ `zcat  ${output_dir}/seqz/${tumor_name}_all_small_out.seqz.gz  | head -2 | wc -l` = 1 ]; then
    echo "empty seqz file with only the header"
    return
fi

singularity exec $sequenza_R_img R --vanilla --args \
            ${output_dir}/seqz/${tumor_name}_all_small_out.seqz.gz \
            ${output_dir}/sequenza \
            < ${R_script}/sequenza.R


python $python_dir/calc_hrd_loh.py ${output_dir}/sequenza/${tumor_name}_all_small_out.seqz.gz_seq_tab.tsv > ${output_dir}/sequenza/${tumor_name}_all_small_out.seqz.gz_hrd_loh.txt 

     
