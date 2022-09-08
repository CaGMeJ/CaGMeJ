library("sequenza")

args           <- commandArgs(TRUE)
seqz_file      <- args[ 1 ]
output_dir     <- args[ 2 ]



seqz_file
output_dir

seqz_basename = basename( seqz_file )
seqz_data <- sequenza.extract( seqz_file )

CP.data <- sequenza.fit( seqz_data )

avg.depth.ratio <- seqz_data$avg.depth.ratio

cint <- get.ci(CP.data)
cellularity <- cint$max.cellularity
cellularity

write( paste("cellularity", cellularity, sep="="),
       file = paste(output_dir, "/", seqz_basename, "_cellularity.txt", sep="" )
    )

pdf(file=paste( output_dir, '/', seqz_basename, "_cellularity.pdf", sep='' ) )
plot(cint$values.cellularity, ylab = "Cellularity", xlab = "posterior probability" )
dev.off()


ploidy <- cint$max.ploidy
ploidy

write( paste("ploidy", ploidy, sep="="),
       file = paste(output_dir, "/", seqz_basename, "_ploidy.txt", sep="" )
    )

seg.tab <- na.exclude(do.call(rbind, seqz_data$segments))
cn.alleles <- baf.bayes(Bf = seg.tab$Bf, depth.ratio = seg.tab$depth.ratio,
                                           cellularity = cellularity, ploidy = ploidy,
                                           avg.depth.ratio = avg.depth.ratio)

seg.tab <- cbind(seg.tab, cn.alleles)
write.table( seg.tab, file = paste(output_dir, "/", seqz_basename, "_seq_tab.tsv", sep="" ), sep="\t", quote=FALSE )
pdf(file=paste( output_dir, '/', seqz_basename, "_cnv_all.pdf", sep='' ) )
sequenza:::genome.view(
        seg.cn = seg.tab,
        info.type = "CNt")
legend( "bottomright",
        bty="n",
        c("Tumor copy number"),
        col = c("red"),
        inset = c(0, -0.4),
        pch=15,
        xpd = TRUE)
dev.off()

pdf(file=paste( output_dir, '/', seqz_basename, "_ab_all.pdf", sep='' ) )
sequenza:::genome.view(
        seg.cn = seg.tab,
        info.type = "AB")
legend( "bottomright",
        bty="n",
        c("A-allele", "B-allele"),
        col = c("red", "blue"),
        inset = c(0, -0.45),
        pch=15,
        xpd = TRUE)
dev.off()

chr_list <- unique(as.vector(seg.tab$chromosome))
chr_list

for(i in c(1:length(chr_list))){

  pdf(file=paste( output_dir, '/', seqz_basename, "_baf_chr",chr_list[[i]],".pdf",sep="") )
  chromosome.view(mut.tab = seqz_data$mutations[[i]], baf.windows = seqz_data$BAF[[i]],
                  ratio.windows = seqz_data$ratio[[i]],  min.N.ratio = 1,
                  segments = seg.tab[seg.tab$chromosome == chr_list[[i]],],
                  main = chr_list[[i]],
                  cellularity = cellularity, ploidy = ploidy,
                  avg.depth.ratio = avg.depth.ratio
  )
  dev.off()
}


for( i in c( 1:length( chr_list ) ) ) {
    
    pdf(file=paste( output_dir, '/', seqz_basename, "_cnv_chr", chr_list[[i]],".pdf",sep="") )
    sequenza:::genome.view(
            seg.cn = seg.tab[seg.tab$chromosome == chr_list[[i]],],
            info.type = "CNt")
    legend( "bottomright",
            bty="n",
            c("Tumor copy number"),
            col = c("red"),
            inset = c(0, -0.4),
            pch=15,
            xpd = TRUE)
    dev.off()
}

for( i in c( 1:length( chr_list ) ) ) {

    pdf(file=paste( output_dir, '/', seqz_basename, "_ab_chr",chr_list[[i]],".pdf",sep="") )
    sequenza:::genome.view(
            seg.cn = seg.tab[seg.tab$chromosome == chr_list[[i]],],
            info.type = "AB")
    legend( "bottomright",
            bty="n",
            c("A-allele", "B-allele" ),
            col = c("red", "blue"),
            inset = c(0, -0.45),
            pch=15,
            xpd = TRUE)
    dev.off()
}

