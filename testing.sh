#!/bin/bash
DIR_LPD=/home/intern24005/code/ml-test-suite/ml_old/testing_folder/test_files/level-O0-llfiles
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/intern24005/onnxruntime-linux-x64-1.16.3/lib/
export LIBRARY_PATH=$LIBRARY_PATH:/home/intern24005/onnxruntime-linux-x64-1.16.3/lib/



framework="$1"
model_runner="$2"


function test_grpc_pipes_lpd() {
    mkdir -p testing/$1/grpc-pipes-lpd
    cnt=0
    pushd testing
    for file in "$DIR_LPD"/tsvc_*.ll;
    do
        filename=$(echo $file | rev | cut -d "/" -f 1 | rev)
        basename=$(basename "$filename" | cut -d. -f1)
        /home/intern24005/code/ml-test-suite/ml-llvm-project/build/bin/opt -S \
                                 -custom_loop_distribution \
                                 -cld-server-address=0.0.0.0:50075 \
                                 $file \
                                 -ml-config-path=/home/intern24005/code/ml-test-suite/config \
                                 -o $filename 
        mv test-raw.txt testing/$1/grpc-pipes-lpd/"$basename"
        rm test-raw.txt
        rm -r *.dot
        rm -r *.txt
        rm -r *.log
        rm $filename
        echo $cnt
        cnt=$((cnt+1))
    done
    popd
    echo "files processed : $cnt"
}

function test_onnx_lpd {
    mkdir -p testing/$1/onnx-lpd/
    cnt=0
    pushd testing
    for file in "$DIR_LPD"/tsvc_-*.ll;
    do
        filename=$(echo $file | rev | cut -d "/" -f 1 | rev)
        basename=$(basename "$filename" | cut -d. -f1)
        /home/intern24005/code/ml-test-suite/ml-llvm-project/build/bin/opt -S \
                                -custom_loop_distribution \
                                -cld-use-onnx \
                                $file \
                                -ml-config-path=/home/intern24005/code/ml-test-suite/config/  \
                                -o $filename
        mv test-raw.txt testing/$1/onnx-lpd/"$basename"
        rm test-raw.txt
        rm -r *.dot
        rm -r *.txt
        rm -r *.log
        rm $filename
        echo $cnt
        cnt=$((cnt+1))
    done
    popd
    echo "files processed : $cnt"
}

function help_message {
    echo "Usage: $0 <framework : test / oracle> <model_runner : grpc_and_pipes / onnx>"
}


# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    help_message
    exit 1
fi


# Switch case to select which framework and model runner to run
case $framework in
    "test")
        case $model_runner in
            "grpc_and_pipes")
                test_grpc_pipes_lpd test
                ;;
            "onnx")
                test_onnx_lpd test
                ;;
            *)
                echo "Unknown argument: $argument"
                ;;
        esac
        ;;
    "oracle")
            case $model_runner in
            "grpc_and_pipes")
                test_grpc_pipes_lpd oracle
                ;;
            "onnx")
                test_onnx_lpd oracle
                ;;
            *)
                echo "second argument should be : onnx or grpc_and_pipes"
                ;;
        esac
        ;;
    "--help")
            help_message
        ;;
    *)
        echo "first argument should be : test or oracle"
        ;;
esac




