#!/bin/bash

rm -rf logs
mkdir logs

make clean
make synthesis/nangate45
make pt/generate_gsf


make compile_sbst > logs/compile_log 2>&1
make questa/compile-timing >> logs/compile_log 2>&1
make questa/lsim/gate-timing/shell >> logs/compile_log 2>&1
make zoix/compile-timing >> logs/compile_log 2>&1
for ((i=2; i<=20; i+=1)); do
    # Use K as the result  f i multiplied by 0.25
    K=$(bc <<< "scale=1; $i * 0.25")
    # Your code here using the variable K
    echo "Iteration $i: K = $K"
    make zoix/fgen/sdd K=$K > ./logs/log_$K 2>&1
    make zoix/lsim-timing > logs/mismatch_$K 2>&1
    cat logs/mismatch_$K | grep 'mismatch'
    make zoix/fsim FAULT_LIST=run/zoix_timing/cv32e40p_top_sdd_K$K.rpt > logs/fault_coverage_$K 2>&1
    cat logs/fault_coverage_$K | grep -i 'test coverage'
done
