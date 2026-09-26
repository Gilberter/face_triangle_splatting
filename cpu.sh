#!/bin/bash
#SBATCH --job-name=python_runner
#SBATCH --output=out/run_%j.out
#SBATCH --error=out/run_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00
#SBATCH --account=gs_hyperspectral
#SBATCH --partition=cpu-cvail01

CONDA_ENV="triangle-splatting2"

export CUDA_HOME=$CONDA_PREFIX
export BUILD_PULSAR=0

# Parse custom runner flags
while getopts "e:" opt; do
  case ${opt} in
    e )
      CONDA_ENV=$OPTARG
      ;;
    \? )
      echo "Usage: sbatch $0 [-e conda_env] <script.py> [script arguments...]"
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))


# Check if a Python script was provided
if [ -z "$1" ]; then
    echo "Error: No Python script specified."
    echo "Usage: sbatch $0 <script.py> [script arguments...]"
    exit 1
fi

# 1. Initialize conda for non-interactive shells and activate environment
source $(conda info --base)/etc/profile.d/conda.sh
echo "Activating environment: $CONDA_ENV"
conda activate "$CONDA_ENV"

TARGET_CMD="$1"
SHIFT_ARGS="${@:2}"

echo "Running target: $TARGET_CMD"
echo "With arguments: $SHIFT_ARGS"


if [[ "$TARGET_CMD" == *.py ]]; then
    python "$TARGET_CMD" $SHIFT_ARGS
elif command -v "$TARGET_CMD" >/dev/null 2>&1 || [ -x "$TARGET_CMD" ]; then
    "$TARGET_CMD" $SHIFT_ARGS
else
    echo "Error: '$TARGET_CMD' is not a valid Python script, system command, or executable file."
    exit 1
fi