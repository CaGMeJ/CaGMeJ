sleep $sleep_time
set -xv
set +e
echo -e "sample\tMicrosatelite\tMut-microsatelite" > $output_dir/mimcall/result.txt
for tumor_name in `awk 'BEGIN{FS=","}NR>1{print $1}' $mimcall_csv`
do
   LOW=`grep -v LOW $output_dir/mimcall/${tumor_name}/${tumor_name}.MIMcall.txt  | wc -l`
   MUT=`grep Mut $output_dir/mimcall/${tumor_name}/${tumor_name}.MIMcall.txt  | wc -l`
   echo -e "${tumor_name}\t$LOW\t$MUT" >> $output_dir/mimcall/result.txt 
done
set -e
