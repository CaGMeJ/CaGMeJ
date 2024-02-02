sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
set -e
output_dir=${output_dir}/facets/$tumor_name

echo "Chromosome,Position,Ref,Alt,File1R,File1A,File1E,File1D,File2R,File2A,File2E,File2D" > $output_dir/${tumor_name}.csv
for chr in `echo "$facets_chr_list" | sed -e 's/\,\|\[\|]//g'`
do
    gzip -dc $output_dir/${tumor_name}.${chr}.csv.gz | awk 'NR>1{print $0}' >> $output_dir/${tumor_name}.csv
done

gzip -f $output_dir/${tumor_name}.csv

export R_LIBS_USER='-'
singularity exec  $facets_img R --vanilla --args $output_dir/${tumor_name}.csv.gz  $output_dir/${tumor_name}.out < $R_script/facets/facets0.6.2.R

if [ ! -s ${output_dir}/${tumor_name}.out.fit.tsv ]; then
    exit 1
fi
if [ ! -s ${output_dir}/${tumor_name}.out.purity.tsv ]; then
    exit 1
fi
if [ ! -s ${output_dir}/${tumor_name}.out.logR.tsv ]; then
    exit 1
fi

purity=`awk -F "," 'NR>1{print $2}' ${output_dir}/${tumor_name}.out.purity.tsv`
if [ $purity = NA ]; then
    echo "false" > ${tumor_name}
else
    echo "true" > ${tumor_name}
fi
