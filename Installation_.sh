#!/bin/bash

# Update the system
sudo yum update -y

# Install GCC (C Compiler), G++ (C++ Compiler), and GFortran (Fortran Compiler)
echo "Installing GCC, G++, and GFortran..."
sudo yum install gcc gcc-c++ gfortran -y

# Check if Python is installed, install Python3 if not
if ! command -v python3 &> /dev/null
then
    echo "Installing Python3..."
    sudo yum install python3 -y
else
    echo "Python3 is already installed."
fi

# Install OpenMPI and its development package
echo "Installing OpenMPI and its development package..."
sudo yum install openmpi openmpi-devel -y

# Install PyQt5 for GUI support
echo "Installing PyQt5 for GUI support..."
sudo yum install PyQt5 -y

# Install Zlib development package
echo "Installing Zlib development package..."
sudo yum install zlib-devel -y

echo "Installation of prerequisites is complete."

echo "Code_Saturne installation starting."

# Navigate to the hpc directory
cd ~/hpc

# Download Code_Saturne
wget https://www.code-saturne.org/releases/code_saturne-8.0.2.tar.gz

# Extract the downloaded file
tar -xvf code_saturne-8.0.2.tar.gz

# Create a build directory
mkdir -p ~/hpc/saturne_build

# Navigate to the parent directory of code_saturne-8.0.2
cd ~/hpc/code_saturne-8.0.2/..

# Run the install script
~/hpc/code_saturne-8.0.2/install_saturne.py

# Edit the set_ini file in the saturne_build directory
# This uses a sed command to replace the relevant lines
sed -i '/#  Name    Use   Install  Path/,/parmetis   no    no       None/c\
#  Name    Use   Install  Path\n#\n\
hdf5       yes   yes      None\n\
cgns       yes   yes      None\n\
med        yes   yes      None\n\
scotch     no    no       None\n\
parmetis   no    no       None\n\
#' ~/hpc/saturne_build/set_ini

# Display the set_ini file for review
echo "Contents of set_ini file:"
cat ~/hpc/saturne_build/set_ini

# Pause the script for review
echo "Press Enter to continue after reviewing the set_ini file..."
read

# Run the install script again
~/hpc/code_saturne-8.0.2/install_saturne.py

# Define the path to Code_Saturne
code_saturne_path="/root/code_saturne/8.0.2/code_saturne-8.0.2/arch/Linux_x86_64/bin"

# Check if the path is already in .bashrc
if grep -Fxq "export PATH=$code_saturne_path:\$PATH" ~/.bashrc
then
    echo "Code_Saturne path already exists in .bashrc"
else
    # Add the path to .bashrc
    echo "export PATH=$code_saturne_path:\$PATH" >> ~/.bashrc

    # Source the .bashrc to update the PATH in the current session
    source ~/.bashrc

    echo "Code_Saturne path added to .bashrc and sourced for the current session."
fi

echo "Code_Saturne environment has been updated."

echo "Code_Saturne installation and setup script has completed."

echo "Code_Saturne installation test started using cs_user_zones.c in EXAMPLES directory."

# Variables
CODE_SATURNE_EXAMPLES_PATH="/root/code_saturne/8.0.2/code_saturne-8.0.2/arch/Linux_x86_64/share/code_saturne/user_sources/EXAMPLES"
STUDY_NAME="my_study"
CASE_NAME="my_case"
CASE_PATH="~/hpc/saturne_test/${STUDY_NAME}/${CASE_NAME}"

# Create a new study case in hpc/saturne_test
echo "Creating a new Code_Saturne study case..."
mkdir -p ~/hpc/saturne_test
cd ~/hpc/saturne_test
code_saturne create -s $STUDY_NAME -c $CASE_NAME

# Copy the cs_user_zones.c file to the SRC directory of the simulation case
echo "Copying cs_user_zones.c to the case SRC directory..."
cp "${CODE_SATURNE_EXAMPLES_PATH}/cs_user_zones.c" "${CASE_PATH}/SRC/"

# Navigate to the case directory
cd $CASE_PATH

# Compile the case
echo "Compiling the case..."
code_saturne compile

# Run the simulation
echo "Running the simulation..."
code_saturne run

echo "Simulation test case has been completed."
