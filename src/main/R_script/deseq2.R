# Load library
##DESeq2##
library( "DESeq2" )
library( "gplots" )
library( "ggplot2" )
library( "RColorBrewer" )
library( "genefilter" )
library( "stringr" )
#
# Get arguments
args <- commandArgs(trailingOnly = TRUE)
htseq_dir <- args[1]
deseq2_dir <- args[2]
geneset_dir <- args[3]
pseudo_count <- args[4]
tumor_list <- args[5]
normal_list <- args[6]

if(is.na(tumor_list)){                  
    tumor_list <- c()
}else{
    tumor_list <- strsplit( tumor_list, ',')
}
if(is.na(normal_list)){                 
    normal_list <- c()
}else{
    normal_list <- strsplit( normal_list, ',')
}

count_all <-c()


file_list <- c(tumor_list[[1]], normal_list[[1]])

for(file in file_list){
    count_tmp <- read.table(paste(htseq_dir, "/", file, "/", file, ".count.txt", sep = ""))
    if(length(count_all) == 0){
        count_all <- count_tmp[,2]
    }
    else{
        count_all <- cbind(count_all, count_tmp[,2])
    }

}

count_tmp <- read.table(paste(htseq_dir, "/", file_list[1], "/", file_list[1], ".count.txt", sep = ""))
rownames(count_all) <- count_tmp[,1]
colnames(count_all) <- file_list
count_file <- paste(deseq2_dir, "/count_all.txt", sep = "")
write.table(count_all, count_file,  sep = "\t", quote=F)

#
# Read data
#
all_count <- read.table( count_file, header=T, sep="\t", row.names=1 )
all_count <- all_count[-which (rownames(all_count) %in% c("__no_feature", "__ambiguous", "__too_low_aQual", "__not_aligned", "__alignment_not_unique")),]

#pseudo_count
pseudo_count_config <- strsplit( pseudo_count, ',')
if(pseudo_count_config[[1]][1] == "True"){
    all_count <- all_count + 1
    keep <- rowMeans(all_count) > as.integer(pseudo_count_config[[1]][2])
    all_count <- all_count[keep,]
    keep <- rowSums(all_count > as.integer(pseudo_count_config[[1]][3])) >= 1
    all_count <- all_count[keep,]
}

all_count<- as.matrix( all_count )

if(length(normal_list[[1]]) & length(tumor_list[[1]])){
    DATA_SINGLE_BOTH <- "both"

}else {
    DATA_SINGLE_BOTH <- "single"
}

data_type_list <- rep(c('T', 'N'), times = c(length(tumor_list[[1]]), length(normal_list[[1]])))
group <- data.frame(con=factor( data_type_list ) )


group

if(DATA_SINGLE_BOTH == "single"){
    dds <- DESeqDataSetFromMatrix(countData = all_count, colData = group, design = ~ 1)
    dds <- DESeq(dds)
    res <- results(dds)
    res_new <-res[which(res$baseMean != 0),]
    rld <- rlog( dds )
    ntd <- normTransform(dds)
}else {
    dds <- DESeqDataSetFromMatrix(countData = all_count, colData = group, design = ~ con)
    dds <- DESeq(dds, fitType='local')
    res <- results(dds)
    res_new <-res[which(res$baseMean != 0),]
    rld <- rlog( dds, fitType='local')
    ntd <- normTransform(dds)
}
res
#
# Plot
#
png(filename=paste( deseq2_dir, "maplot1.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plotMA(res[which(res$pvalue < 0.05),], main="M-A Plot:p < 0.05", ylim=c(-10,10))
dev.off()

png(filename=paste( deseq2_dir, "maplot2.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plotMA(res_new, alpha = 0.05, main="M-A Plot:p < 0.05", ylim=c(-10,10))
dev.off()

png(filename=paste( deseq2_dir, "DispEsts.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plotDispEsts( dds, ylim = c(1e-5, 1e1), main="DispEsts" )
dev.off()

png(filename=paste( deseq2_dir, "hist.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
hist( res_new$pvalue, breaks=20, col="grey", main="pval" )
dev.off()

#
#Independent filtering
#
# create bins using the quantile function
qs <- c( 0, quantile( res_new$baseMean[res_new$baseMean > 0], 1:10/10 ) )
# "cut" the genes into the bins
bins <- cut( res_new$baseMean[ res_new$baseMean > 0 ], qs )
# rename the levels of the bins using the middle point
levels(bins) <- paste0("~",round(.5*qs[-1] + .5*qs[-length(qs)]))
# calculate the ratio of £p£ values less than .01 for each bin
ratios <- tapply( res_new$pvalue, bins, function(p) mean( p < .01, na.rm=TRUE ) ) # plot these ratios

png(filename=paste( deseq2_dir, "barplot.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
barplot(ratios, xlab="mean normalized count", ylab="ratio of small $p$ values", main="ratio of small p value")
dev.off()

#print
write.csv( as.data.frame(res_new), file=paste( deseq2_dir, "all_results.csv", sep="/" ), row.names=T, col.names=T, sep="\t" )
write.csv( assay(rld), paste( deseq2_dir, 'all_rld.csv',sep="/"  ), quote=F )
write.csv( assay(ntd), paste( deseq2_dir, 'all_ntd.csv',sep="/"  ), quote=F )

#
# Scatter plot
#
png(filename=paste( deseq2_dir, "scatter1.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plot( log2( 1+counts(dds, normalized=TRUE)[, 1:2] ), col="#00000020", pch=20, cex=0.3, main="scatter plot")
dev.off()

png(filename=paste( deseq2_dir, "scatter2.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plot( assay(rld)[, 1:2], col="#00000020", pch=20, cex=0.3 )
dev.off()

#
#heatmap
#
sampleDists <- dist( t( assay(rld) ) )
sampleDistMatrix <- as.matrix( sampleDists )
colours = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
image_length <- nrow(sampleDistMatrix)
wi <- max(1280, 960 * image_length  / 10)
he <- max(1280, 960 * image_length  / 10)
png(filename=paste( deseq2_dir, "heatmap1.png", sep="/" ), width=wi, height=he )
heatmap.2( sampleDistMatrix, trace="none", col=colours,margins = c(40,40), cexCol = 2, cexRow=2, cex=2 )
dev.off()

#
#Principal components analysis (PCA)
#
pdf(NULL)
vsd <- varianceStabilizingTransformation(dds)
p <- plotPCA( vsd, intgroup=c("con"), returnData=TRUE )
percentVar <- round(100 * attr(p, "percentVar"))
ggplot(p,aes( PC1, PC2, label = name, color = con , shape = con )) +
geom_point(size=3) +
xlab(paste0("PC1: ",percentVar[1],"% variance")) +
ylab(paste0("PC2: ",percentVar[2],"% variance")) +
geom_text(color = "black",size = 3,vjust = 2 )
ggsave(file = paste( deseq2_dir, "pca1.png", sep="/" ), dpi = 100, width = 20, height = 20)

#sampleDistクラスター解析：prcomp
data.pca <- prcomp(t(assay(rld)))

png(filename=paste( deseq2_dir, "sample_dist.png", sep="/" ), width=1280, height=1280 )
par(mar=c(15,4,5,4))
plot(data.pca$sdev, type="h", main="PCA s.d.", cex=2 , cex.lab=2)
dev.off()


data.pca.sample <- t(assay(rld)) %*% data.pca$rotation[,1:2]#第一、二主成分を抽出
png(filename=paste( deseq2_dir, "pca2.png", sep="/" ), width=1280, height=1280 )
plot(data.pca.sample,  main="PCA", cex=3, col="red", pch=20 )
text(data.pca.sample, adj = c(0.5,2), colnames(assay(rld)),cex = 0.8 )
dev.off()

geneset_files <- Sys.glob( paste( geneset_dir, '*.txt', sep='/') )
genesets <- lapply( geneset_files, read.csv, header=FALSE, encoding="UTF-8", stringsAsFactors=FALSE )

for( i in 1:length( geneset_files ) ) {
    basename( geneset_files )[ i ]
    gene_set_size = length( genesets[[ i ]] )
    wi <- 960 * gene_set_size / 10 # max 32000
    he <- 960 * gene_set_size / 10 # max 32000
    if ( wi < 1280 ) {
        wi <- 1280
        he <- 1280
    }
    fn <- paste( paste( deseq2_dir, "geneset",  basename( geneset_files )[ i ], sep="/" ), 'png', sep='.' )
    png(filename=fn , width=wi, height=he, pointsize=12 )
    gene_list <- assay( rld[ rownames(rld) %in% as.character( genesets[[i]] ), ] )  
    #low expression gene is removed, so gene_list may be  less than 2.
    if ( nrow(gene_list) < 2 || ncol(gene_list) < 2 ) {
        print(paste("Skip:", geneset_files[i], ":heatmap must have at least 2 rows and 2 columns"))
        next
    }
    heatmap.2(      gene_list,
                    scale="row",
                    trace="none",
                    dendrogram="column",
                    col = colorRampPalette( rev(brewer.pal(9, "RdBu")) )(255),
                    main=basename( geneset_files )[ i ],
                    margins = c(15,15),
                    cexCol = 1,
                    cexRow=1,
                    cex=2 )
    dev.off()
}


#
#Gene clustering
#
topVarGenes <- head( order( rowVars( assay(rld) ), decreasing=TRUE ), 35 )
png(filename=paste( deseq2_dir, "gene_clustering.png", sep="/" ), width=960, height=1280 )
heatmap.2( assay(rld)[ topVarGenes, ], scale="row",
           trace="none", dendrogram="column",
           col = colorRampPalette( rev(brewer.pal(9, "RdBu")) )(255),
           main="gene clustering",margins = c(15,15),
           cexCol = 1, cexRow=1, cex=2 )
dev.off()

