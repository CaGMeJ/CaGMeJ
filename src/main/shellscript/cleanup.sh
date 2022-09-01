echo "Cleaning up..."
for node_number in {1..8}
do
    echo "gpuv.q@gcg0${node_number}i"
    ssh -o StrictHostKeyChecking=no gcg0${node_number}i "ls -l /work/ | grep $USER | awk '{print \$9}' | xargs -r -I @ rm -r -v  \"/work/@\" "
done
echo "Finished"
