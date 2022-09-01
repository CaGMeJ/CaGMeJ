sleep $sleep_time
set -xv
set +e
echo -e "sample\tMicrosatelite\tMut-microsatelite\t%" > $output_dir/mimcall/result.txt
for tumor_name in `awk 'BEGIN{FS=","}NR>1{print $1}' $mimcall_csv`
do
   ALL=`grep -v LOW $output_dir/mimcall/${tumor_name}/${tumor_name}.MIMcall.txt  | wc -l`
   MUT=`grep Mut $output_dir/mimcall/${tumor_name}/${tumor_name}.MIMcall.txt  | wc -l`
   Mut_rate=`python -c "print($Mut / $ALL)"`
   echo -e "${tumor_name}\t$ALL\t$MUT\t$Mut_rate" >> $output_dir/mimcall/result.txt 
done
set -e
