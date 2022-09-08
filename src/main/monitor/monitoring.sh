while ps -p $! > /dev/null
do
        nvidia-smi >> $output_dir/nvidia-smi.txt
        top -n 1 -b  >> $output_dir/top.txt
        iostat -x >> $output_dir/iostat.txt
        sleep 1m
done
