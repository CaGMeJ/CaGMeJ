sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file 
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
out_dir=$output_dir/hyperclust/$tumor_name

set -e
set -xv
cwd=`pwd`
if [ ! -e $out_dir/scarhrd ]; then
    mkdir -p  $out_dir/scarhrd
fi
id=`$container_bin exec $samtools_img samtools view -H $tumor_bam  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq `
cd $out_dir/scarhrd
if [  -e  $out_dir/ascatngs/${id}.copynumber.caveman.csv ]; then
    echo -e "SampleID\tChromosome\tStart_position\tEnd_position\ttotal_cn\tA_cn\tB_cn\tploidy" > $out_dir/scarhrd/${tumor_name}.ascat.scarHRD.input.txt
    ploidy=`cat $out_dir/ascatngs/${id}.samplestatistics.txt | grep psi | awk '{print $2}'`
    cat $out_dir/ascatngs/${id}.copynumber.caveman.csv | cut -d "," -f2- | sed -e "s/^/chr/g" | awk -F ',' '{print "'$tumor_name'\t"$1"\t"$2"\t"$3"\t"$6+$7"\t"$6"\t"$7"\t'$ploidy'"}' >> $out_dir/scarhrd/${tumor_name}.ascat.scarHRD.input.txt
    $container_bin exec $scarhrd_img R -e '
    library("scarHRD");
    hrd.score.dat <- scar_score("'$out_dir/scarhrd/${tumor_name}.ascat.scarHRD.input.txt'",reference = "grch38", seqz=FALSE);
    write.table(hrd.score.dat, file="'$out_dir/scarhrd/${tumor_name}.ascat.scarHRD.result.txt'", sep = "\t", quote=F, row.names=F)
   '
    rm $out_dir/scarhrd/${tumor_name}_HRDresults.txt
fi

if [ -e $output_dir/facets/$tumor_name/${tumor_name}.out.fit.tsv ]; then
    ploidy=`head -n 3 $output_dir/facets/$tumor_name/${tumor_name}.out.fit.tsv | tail -n 1 | cut -d "," -f2`
    echo -e "SampleID\tChromosome\tStart_position\tEnd_position\ttotal_cn\tA_cn\tB_cn\tploidy" > $out_dir/scarhrd/${tumor_name}.facets.scarHRD.input.txt
    sed -e "s/\"//g" $output_dir/facets/$tumor_name/${tumor_name}.out.fit.tsv | awk -F ',' 'NR>4{if( $14 ~ /^[0-9]+$/ && $15 != "NA" && 1 <= $2 && $2 <= 22 ){ print "'$tumor_name'\tchr"$2"\t"$11"\t"$12"\t"$14"\t"$14-$15"\t"$15"\t'$ploidy'"}}' >> $out_dir/scarhrd/${tumor_name}.facets.scarHRD.input.txt
    $container_bin exec $scarhrd_img R -e '
    library("scarHRD");
    hrd.score.dat <- scar_score("'$out_dir/scarhrd/${tumor_name}.facets.scarHRD.input.txt'",reference = "grch38", seqz=FALSE);
    write.table(hrd.score.dat, file="'$out_dir/scarhrd/${tumor_name}.facets.scarHRD.result.txt'", sep = "\t", quote=F, row.names=F)
   '
   rm $out_dir/scarhrd/${tumor_name}_HRDresults.txt
fi

cd $cwd
