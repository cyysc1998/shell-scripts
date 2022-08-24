#!/bin/bash

log_file=./logs/R50/eval_per_epoch.txt
ckpts=`find ./logs/R50 -name 'checkpoint[0-9]*.pth' | sort`
for ckpt in $ckpts; do
    echo $ckpt >> $log_file
    CUDA_VISIBLE_DEVICES=0 bash scripts/eval_ms5.sh ./data $ckpt
    python tools/generate_test_dev_results.py
    python tools/evaluate_test_dev.py --per_class >> $log_file
    python tools/evaluate_test_dev.py --catid=-1 >> $log_file
done
