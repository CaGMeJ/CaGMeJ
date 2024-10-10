tumor_normal_controlpanel=
tumor_normal_None=
tumor_None_controlpanel=
tumor_None_None=
prefix=
case_list=( `python $python_dir/pa_conf.py ${pa_type} $input_csv sample_name "$prefix"` )

if [ ${case_list[0]} != None ]; then
    tumor_normal_None=${case_list[0]}
fi

if [ ${case_list[1]} != None ]; then
    tumor_None_None=${case_list[1]}
fi
$container_bin exec $genomon_img genomon_pa ${pa_type} \
    ${pa_output_dir} ${output_dir}  ${sample_csv} \
    --config_file ${pa_conf} \
    --samtools /usr/local/bin/samtools --bedtools /usr/local/bin/bedtools \
    --input_file_case1 "${tumor_normal_controlpanel}" \
    --input_file_case2 "${tumor_normal_None}" \
    --input_file_case3 "${tumor_None_controlpanel}" \
    --input_file_case4 "${tumor_None_None}"
