library('CHORD')
library('BSgenome' )
library('BSgenome.Hsapiens.UCSC.hg38')

args <- commandArgs(trailingOnly = TRUE)
    sample <- args[1]
    mutect <- args[2]
    gridss <- args[3]
    output_dir <- args[4]


sample
mutect
gridss


output_sample_dir <- paste( output_dir, sample, sep="/" )
dir.create( output_sample_dir )
output_sample_file <- paste( paste( output_sample_dir, sample, sep="/" ), "txt", sep="." )


contexts <- extractSigsChord(
          vcf.snv = mutect,
          vcf.sv = gridss,
          sv.caller = 'gridss',
          sample.name=sample,
          ref.genome = BSgenome.Hsapiens.UCSC.hg38,
          verbose=T
        )

chord_output <- chordPredict(contexts, verbose=F)
write.table( chord_output, output_sample_file )

