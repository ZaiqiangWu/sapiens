#!/bin/bash

cd ../../.. || exit

SAPIENS_CHECKPOINT_ROOT=/home/${USER}/sapiens_host
OUTPUT_CHECKPOINT_ROOT=/home/${USER}/sapiens_lite_host

# MODE='torchscript' ## original. no optimizations (slow). full precision inference.
MODE='bfloat16' ## A100 gpus. faster inference at bfloat16
# MODE='float16' ## V100 gpus. faster inference at float16 (no flash attn)

OUTPUT_CHECKPOINT_ROOT=$OUTPUT_CHECKPOINT_ROOT/$MODE

VALID_GPU_IDS=(0)

#--------------------------MODEL CARD---------------
MODEL_NAME='sapiens_1b'; CHECKPOINT=$SAPIENS_CHECKPOINT_ROOT/pose/checkpoints/sapiens_1b/sapiens_1b_goliath_best_goliath_AP_640.pth

DATASET='goliath'
MODEL="${MODEL_NAME}-210e_${DATASET}-1024x768"
POSE_CONFIG_FILE="configs/sapiens_pose/${DATASET}/${MODEL}.py"

OUTPUT=${OUTPUT_CHECKPOINT_ROOT}/pose/checkpoints/${MODEL_NAME}/

TORCHDYNAMO_VERBOSE=1 CUDA_VISIBLE_DEVICES=${VALID_GPU_IDS[0]} python3 tools/deployment/torch_optimization.py \
            ${POSE_CONFIG_FILE} ${CHECKPOINT} --output-dir ${OUTPUT} --explain-verbose