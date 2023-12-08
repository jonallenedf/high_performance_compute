#!/bin/bash

# Check if a directory name is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tutorial_directory_name>"
    exit 1
fi

TUTORIAL_DIR_NAME=$1
TUTORIALS_PATH="/tmp/saturne-tutorials"
CASE_PATH="${TUTORIALS_PATH}/${TUTORIAL_DIR_NAME}"

# Check if the tutorial directory exists
if [ ! -d "${CASE_PATH}" ]; then
    echo "Tutorial directory ${CASE_PATH} does not exist."
    exit 1
fi

# Variables for Code_Saturne case
STUDY_NAME="${TUTORIAL_DIR_NAME}"
CASE_NAME="case_1"
FULL_CASE_PATH="/tmp/saturne_test/${STUDY_NAME}/${CASE_NAME}"

# Create a new study case
echo "Creating a new Code_Saturne study case..."
mkdir -p /tmp/saturne_test
cd /tmp/saturne_test
code_saturne create -s ${STUDY_NAME} -c ${CASE_NAME}

# Copy necessary files from the tutorial directory to the case directory
echo "Copying files from the tutorial directory to the case directory..."
cp -r ${CASE_PATH}/* ${FULL_CASE_PATH}/DATA/

# Navigate to the case directory
cd ${FULL_CASE_PATH}

# Compile and run the case
echo "Compiling the case..."
code_saturne compile

echo "Running the simulation..."
code_saturne run

echo "Simulation test case for ${STUDY_NAME} has been completed."
