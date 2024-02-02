library(Battenberg)

args <- commandArgs(trailingOnly = TRUE)

TUMOURNAME = args[1]
NORMALNAME = args[2]
NORMALBAM = args[3]
TUMOURBAM = args[4]
IS.MALE = args[5]
RUN_DIR = args[6]
SKIP_ALLELECOUNTING = FALSE
SKIP_PREPROCESSING = FALSE
SKIP_PHASING = FALSE
NTHREADS = args[7]
PRIOR_BREAKPOINTS_FILE = NULL

analysis = "paired"

JAVAJRE = "java"
ALLELECOUNTER = "alleleCounter"
IMPUTE_EXE = "impute2"

GENOMEBUILD = "hg38"
USEBEAGLE = T

# General static
	
	BEAGLE_BASEDIR = args[8]
	GENOMEBUILD = "hg38"
	IMPUTEINFOFILE = file.path(BEAGLE_BASEDIR, "impute_info.txt")
	G1000ALLELESPREFIX = file.path(BEAGLE_BASEDIR, "1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_allele_index_")
	G1000LOCIPREFIX = file.path(BEAGLE_BASEDIR, "1000G_loci_hg38/1kg.phase3.v5a_GRCh38nounref_loci_")
	GCCORRECTPREFIX = file.path(BEAGLE_BASEDIR, "GC_correction_hg38/1000G_GC_")
	REPLICCORRECTPREFIX = file.path(BEAGLE_BASEDIR, "RT_correction_hg38/1000G_RT_")
	PROBLEMLOCI = file.path(BEAGLE_BASEDIR, "probloci/probloci.txt.gz")
	
	BEAGLEREF.template = file.path(BEAGLE_BASEDIR, "beagle/CHROMNAME.1kg.phase3.v5a_GRCh38nounref.vcf.gz.vcf")
	BEAGLEPLINK.template = file.path(BEAGLE_BASEDIR, "beagle/plink.CHROMNAME.GRCh38.map")
	BEAGLEJAR = file.path(BEAGLE_BASEDIR, "beagle.22Jul22.46e.jar")

	CHROM_COORD_FILE = args[9]
 

PLATFORM_GAMMA = 1
PHASING_GAMMA = 1
SEGMENTATION_GAMMA = 10
SEGMENTATIIN_KMIN = 3
PHASING_KMIN = 1
CLONALITY_DIST_METRIC = 0
ASCAT_DIST_METRIC = 1
MIN_PLOIDY = 1.6
MAX_PLOIDY = 4.8
MIN_RHO = 0.1
MIN_GOODNESS_OF_FIT = 0.63
BALANCED_THRESHOLD = 0.51
MIN_NORMAL_DEPTH = 10
MIN_BASE_QUAL = 20
MIN_MAP_QUAL = 35
CALC_SEG_BAF_OPTION = 1


# Change to work directory and load the chromosome information
setwd(RUN_DIR)

if ( IS.MALE == "T"){
    IS.MALE <- TRUE
} else if ( IS.MALE == "F"){
    IS.MALE <- FALSE
} else {
    stop(paste("unknown value in IS.MALE: ", IS.MALE))
}

battenberg(analysis=analysis,
	   tumourname=TUMOURNAME, 
           normalname=NORMALNAME, 
           tumour_data_file=TUMOURBAM, 
           normal_data_file=NORMALBAM, 
           ismale=IS.MALE, 
           imputeinfofile=IMPUTEINFOFILE, 
           g1000prefix=G1000LOCIPREFIX, 
           g1000allelesprefix=G1000ALLELESPREFIX, 
           gccorrectprefix=GCCORRECTPREFIX, 
           repliccorrectprefix=REPLICCORRECTPREFIX, 
           problemloci=PROBLEMLOCI, 
           data_type="wgs",
           impute_exe=IMPUTE_EXE,
           allelecounter_exe=ALLELECOUNTER,
	   usebeagle=USEBEAGLE,
	   beaglejar=BEAGLEJAR,
	   beagleref=BEAGLEREF.template,
	   beagleplink=BEAGLEPLINK.template,
	   beaglemaxmem=args[10],
           beaglecpu=args[11],
	   beaglenthreads=1,
	   beaglewindow=40,
	   beagleoverlap=4,
	   javajre=JAVAJRE,
           nthreads=NTHREADS,
           platform_gamma=PLATFORM_GAMMA,
           phasing_gamma=PHASING_GAMMA,
           segmentation_gamma=SEGMENTATION_GAMMA,
           segmentation_kmin=SEGMENTATIIN_KMIN,
           phasing_kmin=PHASING_KMIN,
           clonality_dist_metric=CLONALITY_DIST_METRIC,
           ascat_dist_metric=ASCAT_DIST_METRIC,
           min_ploidy=MIN_PLOIDY,
           max_ploidy=MAX_PLOIDY,
           min_rho=MIN_RHO,
           min_goodness=MIN_GOODNESS_OF_FIT,
           uninformative_BAF_threshold=BALANCED_THRESHOLD,
           min_normal_depth=MIN_NORMAL_DEPTH,
           min_base_qual=MIN_BASE_QUAL,
           min_map_qual=MIN_MAP_QUAL,
           calc_seg_baf_option=CALC_SEG_BAF_OPTION,
           skip_allele_counting=SKIP_ALLELECOUNTING,
           skip_preprocessing=SKIP_PREPROCESSING,
           skip_phasing=SKIP_PHASING,
           prior_breakpoints_file=PRIOR_BREAKPOINTS_FILE,
	   GENOMEBUILD=GENOMEBUILD,
	   chrom_coord_file=CHROM_COORD_FILE,
           parallel_type = 'FORK')

