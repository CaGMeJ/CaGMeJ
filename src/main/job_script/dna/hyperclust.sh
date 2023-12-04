sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load singularity/3.7.0 
export SINGULARITY_BINDPATH=/cshare1,/home,/share
tumor_name=$id
out_dir=$output_dir/hyperclust/$tumor_name
set -e
set -xv
cwd=`pwd`
if [ ! -e $out_dir ]; then
    mkdir -p  $out_dir
fi
id=`singularity exec $samtools_img samtools view -H $tumor_bam  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq `
if [  -e  $out_dir/ascatngs/${id}.copynumber.caveman.csv ]; then
    cd $out_dir
    echo -e "chromosome\tstart\tend\ttotal_cn\tmajor_cn\tminor_cn\tstar" > cna.txt
    cat $out_dir/ascatngs/${id}.copynumber.caveman.csv | cut -d "," -f2- | sed -e "s/^/chr/g" | awk -F ',' '{print $1"\t"$2"\t"$3"\t"$6+$7"\t"$6"\t"$7"\tdummy"}'  >> cna.txt
    vcf=$output_dir/mutect/$tumor_name/${tumor_name}.mutect.vcf.gz
    purity=`cat $out_dir/ascatngs/${id}.samplestatistics.txt | grep rho | awk '{print $2}'`

    #formatVCF
    script=/hyperclust-master/bin
    singularity exec $hyperclust_img \
        bcftools view -m2 -M2 -v snps -O z -o ${id}_snp.vcf.gz ${vcf}
        singularity exec $hyperclust_img \
        bash -c "bcftools query -i 'TYPE=\"snp\"'\
                   -s $id \
                   -f '%CHROM:%POS:%REF:%ALT{0},%REF,%ALT{0},[%AD]\n' \
                   ${id}_snp.vcf.gz | $script/parse_query_hartwig.awk" > ${id}.tmpFile
    singularity exec $hyperclust_img \
        bash -c "R --vanilla --args ${id}_snp.vcf.gz \
                           cna.txt \
                           ${id}.tmpFile \
                           sanger_pcawg \
                           $id < <(cat $script/annotate_cna.R | sed -e \"s/1:22/lapply(1:22, function(k) paste('chr', k, sep=''))/g\")"

    #formatRND
    cut -f 1 ${id}_pyclone_format.tsv \
       | tail -n +2 \
       |   awk 'BEGIN {FS=":";OFS="\t"} {print($1,$2,$2,$3,$4,1,"'$id'")}'\
       >   ${id}_rndFormat.tsv

    #computeStratification
    script=/hyperclust-master/bin
    singularity exec $hyperclust_img \
       Rscript $script/clonality_single_sample.R \
           -Pv -i ${id}_pyclone_format.tsv -p $purity -s $id

    #rmdup
    egrep -f $available ${id}_rndFormat.tsv \
       | sort -k7,7 -k1,1 -k2n,2 -k5,5  | uniq > ${id}_rndFormat_rmdup.tsv

    #randomize
    singularity exec $hyperclust_img \
        randommut -M randomize -g ${genome} \
            -m ${id}_rndFormat_rmdup.tsv -a ${assembly} \
            -o ${id}_w${ws}.randomized.tsv -t ${times} -w ${ws} -b ${intraBS}

    #clusterCallingBoost
    boostingPath=clonality_results/${id}_mutations_strand_clonality.txt
    samplePath=${id}_w${ws}.randomized.tsv
    script=/usr/local/lib/R/library/clustMut/exec
    singularity exec $hyperclust_img \
        Rscript $script/clustmut_distance.R \
             -i . \
             --glob "*${samplePath}" \
             --recursive     \
             -o ${id}_strandClonality \
             -N 1    \
             -b ${boostingPath}  \
             -Vlv
fi
cd $cwd
