#prepare dna.cfg for test
sed -e "s/v100=2/v100=1/g" \
    -e "s/cpus = 21/cpus = 1/g" \
    -e "s/s_vmem=47G/s_vmem=500G/g" \
    -e "s/cpus = 22/cpus = 1/g" \
    -e "s/s_vmem=45G/s_vmem=500G/g" \
    -e "s/cpus = 17/cpus = 1/g" \
    -e "s/s_vmem=58G/s_vmem=500G/g" \
    -e "s/cpus = 26/cpus = 1/g" \
    -e "s/s_vmem=39G/s_vmem=500G/g" \
    -e "s/cpus = 12/cpus = 1/g" \
    -e "s/s_vmem=21G/s_vmem=500G/g" \
    -e "s@/work/gridss@/work/gridss_hello@g" SCRIPT_DIR/build/main/config/dna.cfg > dna.cfg

bash  SCRIPT_DIR/build/main/CaGMeJ.sh  \
                   --analysis_type  dna \
                   --sample_conf    SRC_DIR/data/dna/test.csv \
                   --output_dir     test_dna \
                   --nextflow_conf  dna.cfg

exit 0
echo "Cleaning up..."
for node_number in {1..9}
do
    echo "sdomec.q@cc0${node_number}i"
    ssh -o StrictHostKeyChecking=no cc0${node_number}i "ls -l /work/ | grep $USER | awk '{print \$9}' | xargs -r -I @ rm -r -v  \"/work/@\" "
done
echo "Finished"
