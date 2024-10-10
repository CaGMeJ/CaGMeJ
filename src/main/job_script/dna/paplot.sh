prefix=${pa_output_dir}
pa_sv_txt=`python $python_dir/pa_conf.py sv $sv_csv file_name "$prefix"`
pa_mutation_txt=`python $python_dir/pa_conf.py mutation $mutation_csv file_name "$prefix"`

paplot_output_dir=$output_dir/paplot

if [ ! -e $paplot_output_dir ]; then
    mkdir -p $paplot_output_dir
fi

if $post_analysis_sv_enable ; then
    $container_bin exec $genomon_img paplot ca \
        $pa_sv_txt \
        $paplot_output_dir \
        CaGMeJ \
        --config_file $paplot_conf \
        --title 'SV graphs' \
        --overview 'Structural Variation.' \
        --ellipsis sv 
fi

if $post_analysis_mutation_enable ; then
    if $annovar_enable ; then
        $container_bin exec $genomon_img paplot mutation \
            $pa_mutation_txt \
            $paplot_output_dir \
            CaGMeJ \
            --config_file $paplot_conf \
            --title 'Mutation matrix' \
            --overview 'Gene-sample mutational profiles.' \
            --ellipsis mutation
    else
        echo 'paplot: [annotation] active_annovar_flag = False in genomon_conf_file, skip mutation-matrix.'
    fi
fi

if $pmsignature_ind_enable ; then
    for sig_num in `seq $pmsignature_ind_signum_min $pmsignature_ind_signum_max`
    do
        $container_bin exec $genomon_img paplot pmsignature \
            ${pmsignature_output_dir}/pmsignature.ind.result.${sig_num}.json \
            $paplot_output_dir \
            CaGMeJ \
            --config_file $paplot_conf \
            --title 'pmsignature' \
            --overview 'Pmsignature type=ind.' \
            --ellipsis ind
    done
fi

if $pmsignature_full_enable ; then
    for sig_num in `seq $pmsignature_full_signum_min $pmsignature_full_signum_max`
    do
        $container_bin exec $genomon_img paplot signature\
            ${pmsignature_output_dir}/pmsignature.full.result.${sig_num}.json \
            $paplot_output_dir \
            CaGMeJ \
            --config_file $paplot_conf \
            --title 'Mutational Signature' \
            --overview 'Pmsignature type=full.' \
            --ellipsis full
    done
fi

$container_bin exec $genomon_img paplot index \
    $paplot_output_dir \
    --config_file $paplot_conf \
    --remarks 'Data used in this report were generated using below software.<ul><li>CaGMeJ</li><li>GenomonSV-0.6.1b1(modified)</li><li>sv_utils-0.5.1(modified)</li><li>GenomonFisher 0.2.0</li><li>GenomonMutationFilter-0.2.1(modified)</li><li>GenomonMutationAnnotation-0.1.0</li><li>MutationUtil-0.5.0</li></ul>'
 
