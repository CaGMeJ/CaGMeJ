write_usage() {
  echo ""
  echo "Usage: `basename $0` "
  echo ""
  echo "-a, --analysis_type   <analysis_type [dna,rna]>"
  echo "-s, --sample_conf     <path to the sample conf>"
  echo "-n, --nextflow_conf   <path to the nextflow conf>"
  echo "-g, --genomon_conf    <path to the genomon conf>"
  echo "-o, --output_dir      <path to the output directory>"
  echo "-q, --qsub_option     <qsub option of job which run nextflow>"
  echo "-d, --del_tmp_dir     <delete tmp file which remain in /work directory>"
  echo "-v, --visualization   <dotfile in work directory  visualization disable>"
  echo "-p, --heap_size       <set environment variable NXF_OPTS>"
  echo "-h, --help            <print help>"
  echo ""
}

flag_analysis=false
flag_sample=false
flag_genomon=false
flag_nextflow=false
flag_output=false
flag_qsub=false
flag_del_tmp_dir=false
flag_visual=false
flag_heap=false

genomon_conf=None

heap_size="-XX:+UseSerialGC -Xmx8g -Xms32m"

skip_flag=false
for OPT in "$@"
do
   if $skip_flag ; then
       skip_flag=false
       continue
   fi
   case $OPT in
        -h | --help)
            write_usage
            exit 0
            ;;
        -a | --analysis_type)
            flag_analysis=true
            analysis_type=$2
            skip_flag=true
            shift 2
            ;;

        -o | --output_dir)
            flag_output=true
            output_dir=$2
            skip_flag=true
            shift 2
            ;;

        -s | --sample_conf)
            flag_sample=true
            sample_conf=$2
            skip_flag=true
            shift 2
            ;;

        -g | --genomon_conf)
            flag_genomon=true
            genomon_conf=$2
            skip_flag=true
            shift 2
            ;;

        -n | --nextflow_conf)
            flag_nextflow=true
            nextflow_conf=$2
            skip_flag=true
            shift 2
            ;;

        -q | --qsub_option)
            flag_qsub=true
            qsub_option="$2"
            skip_flag=true
            shift 2
            ;;

 
        -d | --del_tmp_dir)
            flag_del_tmp_dir=true
            shift 1
            ;;

        -v | --visualization)
            flag_visual=true
            shift 1
            ;;

        -p | --heap_size)
            flag_heap=true
            heap_size="$2"
            skip_flag=true
            shift 2
            ;;

        * )
            echo "unknown option:$1"
            exit 1
    esac
    
done

if ! $flag_analysis ; then
    echo "-a/--analysis_type is required"
    exit 1
fi

if ! $flag_output ; then
    echo "-o/--output_dir is required"
    exit 1
fi

if ! $flag_sample ; then
    echo "-s/--sample_conf is required"
    exit 1
fi

if ! $flag_nextflow ; then
    echo "-n/--nextflow_conf is required"
    exit 1
fi

if $flag_analysis &&  \
   [ ! ${analysis_type} = dna ] && \
   [ ! ${analysis_type} = rna ]  ; then
      echo "analysis_type: you set ${analysis_type}, but analysis_type must be dna or rna."
      exit 1
fi

if $flag_sample ; then
    if [ ! -f ${sample_conf} ]; then
        echo "sample_conf: ${sample_conf} does not exist."
        exit 1
    else
        sample_conf=$(cd `dirname ${sample_conf}`; pwd)/`basename ${sample_conf}`
    fi
fi

if $flag_genomon ; then
    if  [ ! -f ${genomon_conf} ]; then
        echo "genomon_conf: ${genomon_conf} does not exist."
        exit 1
    else
        genomon_conf=$(cd `dirname ${genomon_conf}`; pwd)/`basename ${genomon_conf}`
    fi
fi

if $flag_nextflow ; then
    if  [ ! -f ${nextflow_conf} ]; then
         echo "nextflow_conf: ${nextflow_conf} does not exist."
         exit 1
    else
         nextflow_conf=$(cd `dirname ${nextflow_conf}`; pwd)/`basename ${nextflow_conf}`
    fi
fi
