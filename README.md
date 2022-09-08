CaGMeJ
=======

CaGMeJ(Cancer Genomic Medicine in Japan)はWGS解析パイプラインです。  
Parabricksを使うことでGPUによる高速なゲノム解析を可能とします。  
Parabricksについては https://docs.nvidia.com/clara/parabricks/v3.5/index.html を参考にしてください。  

Install
========

install.shを修正してインストールしてください。

```
qsub install.sh
```

Test
=====

```
bash build/test_dna.sh
bash build/test_rna.sh
```

Usage
=====

DNA

```
bash  build/main/CaGMeJ.sh  \
                   --analysis_type  dna \
                   --sample_conf    {DNAサンプル設定ファイル} \
                   --output_dir     {出力先ディレクトリ} \
                   --nextflow_conf  {DNAパイプライン設定ファイル}
```

RNA

```
bash  build/main/CaGMeJ.sh  \
                   --analysis_type  rna \
                   --sample_conf    {RNAサンプル設定ファイル} \
                   --output_dir     {出力先ディレクトリ} \
                   --nextflow_conf  {RNAパイプライン設定ファイル}
```
