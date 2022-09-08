pmsignature_output_dir=${output_dir}/pmsignature/`basename $sample_csv`
pmsignature_output_dir=${pmsignature_output_dir%.csv}
if [ ! -e $pmsignature_output_dir ]; then
       mkdir -p $pmsignature_output_dir
fi
echo -n >  ${pmsignature_output_dir}/mutation.cut.txt 
prefix=
for file_name in `python $python_dir/pa_conf.py mutation $mutation_csv file_name "$prefix" | sed -e "s/,/ /g" `;
   do
       input_file=${pa_output_dir}/${file_name}

       if [ -s $input_file ]; then
           #skip 4 lines to remove header(AnalysisDate, User, Version, id)
           #extract 5 columns(id,Chr,Start,Ref,Alt)
           tail -n +5 $input_file | cut -f 1,2,3,5,6 >> ${pmsignature_output_dir}/mutation.cut.txt      
       fi
done

