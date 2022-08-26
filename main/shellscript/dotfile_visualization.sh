
work_dir=$1

for i in `ls $work_dir`
do
    dir1=$work_dir/$i
    for j in `ls $dir1`
    do
        dir2=$dir1/$j
        for k in `ls -aF $dir2 | grep -v /`
        do

            file_before=$dir2/$k
            file_after=$dir2/${k#*.}

            # .command.log -> command.log  
            mv $file_before $file_after

            if [ ${k#*.} = command.run ]; then
                sed -i -e "s/\.command/command/g" $file_after
                sed -i -e "s/\.exitcode/exitcode/g" $file_after
            fi
        done
    done
done
