set -e
set -xv
python $python_dir/chord/chord_summary.py \
    $chord_csv \
    $output_dir/chord \
    >  $output_dir/chord/results.tsv

if [ ! -s $output_dir/chord/results.tsv ]; then
    exit 1
fi
