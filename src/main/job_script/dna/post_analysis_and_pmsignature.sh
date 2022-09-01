sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

set -xv

pa_output_dir=${output_dir}/post_analysis/`basename $sample_csv`
pa_output_dir=${pa_output_dir%.csv}

if [ ! -e $pa_output_dir ]; then
    mkdir -p $pa_output_dir
fi

if $post_analysis_mutation_enable ; then
    input_csv=$mutation_csv
    pa_type=mutation
    source ${job_script}/post_analysis.sh
fi

if $post_analysis_sv_enable ; then
    input_csv=$sv_csv
    pa_type=sv
    source ${job_script}/post_analysis.sh
fi

if $pmsignature_full_enable ||  $pmsignature_ind_enable; then

  source ${job_script}/pre_pmsignature.sh

  if $pmsignature_ind_enable ; then
      pmsignature_type=ind
      trdirflag=$pmsignature_ind_trdirflag
      trialnum=$pmsignature_ind_trialnum
      bgflag=${pmsignature_ind_bgflag}
      bs_genome=${pmsignature_ind_bs_genome}
      txdb_transcript=${pmsignature_ind_txdb_transcript}
      for sig_num in `seq $pmsignature_ind_signum_min $pmsignature_ind_signum_max`
      do
          source ${job_script}/pmsignature.sh
      done
  fi

  if $pmsignature_full_enable ; then
      pmsignature_type=full
      trdirflag=$pmsignature_full_trdirflag
      trialnum=$pmsignature_full_trialnum
      bgflag=${pmsignature_full_bgflag}
      bs_genome=${pmsignature_full_bs_genome}
      txdb_transcript=${pmsignature_full_txdb_transcript}
      for sig_num in `seq $pmsignature_full_signum_min $pmsignature_full_signum_max`
      do
          source ${job_script}/pmsignature.sh
      done
  fi 
fi

if $paplot_enable ; then
    source ${job_script}/paplot.sh
fi
