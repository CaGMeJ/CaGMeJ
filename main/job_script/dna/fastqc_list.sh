sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load python/3.6


fastqc_dir=${output_dir}/qc/fastqc/fastqc
output_dir=${output_dir}/fastqc
per_page=${per_page}

if [ ! -e $output_dir ];then
    mkdir -p $output_dir
fi

python -B ${fastqc_script_dir}/make_html.py ${fastqc_dir}  ${output_dir} ${fastqc_script_dir} ${per_page}

