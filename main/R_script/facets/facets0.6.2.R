library(pctGCdata)
library(facets)

args <- commandArgs(trailingOnly = TRUE)
file_name <- args[1]
out_file_name <- args[2]

file_name
out_file_name

# 1)  chormosome
# 2)  position
# 3)  ref
# 4)  alt
# 5)  normal sample1 ref read depth
# 6)  normal sample alt allele count
# 7)  normal sample1 error
# 8)  normal sample deletion
# 9)  tumor ref read depth
# 10) tumor alt allele read count
# 11) tumor ref error
# 12) tumor alt deletion
set.seed(1234)
rcmat <- readSnpMatrix(file_name )
xx <- preProcSample(rcmat, gbuild="hg38")
# specify cval you like
oo <- procSample(xx, cval = 150)

oo$dipLogR

fit=emcncf(oo)

fit$purity

fit_file <- paste( out_file_name, "fit", "tsv", sep="." )

purity_file <- paste( out_file_name, "purity", "tsv", sep="." )

write.csv( fit$purity, purity_file )


ploidy_file <- paste( out_file_name, "ploidy", "tsv", sep="." )
logr_file <- paste( out_file_name, "logR", "tsv", sep="." )

logr_file

write.csv( oo$dipLogR, logr_file )

write.csv( rbind( fit$purity, fit$ploidy, fit$dipLogR, fit$cncf, fit$emflags ), fit_file )

png(filename=paste( out_file_name, "png", sep="." ) )
plotSample(x=oo,emfit=fit)
dev.off()
