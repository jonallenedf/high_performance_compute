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

# Navigate to the hpc_staging directory
cd ~/hpc_staging

# Download Code_Saturne
wget https://www.code-saturne.org/releases/code_saturne-8.0.2.tar.gz

# Extract the downloaded file
tar -xvf code_saturne-8.0.2.tar.gz

# Create a build directory
mkdir -p ~/hpc_staging/saturne_build

# Navigate to the parent directory of code_saturne-8.0.2
cd ~/hpc_staging/saturne_build

# Run the install script
~/hpc_staging/code_saturne-8.0.2/install_saturne.py

# Define the path to the setup file
SETUP_FILE="~/hpc_staging/saturne_build/setup"

# Check if the setup file exists
if [ -f "$SETUP_FILE" ]; then
    # Edit the setup file using sed
    sed -i '/#  Name    Use   Install  Path/,/parmetis   no    no       None/c\
    #  Name    Use   Install  Path\n#\n\
    hdf5       yes   yes      None\n\
    cgns       yes   yes      None\n\
    med        yes   yes      None\n\
    scotch     no    no       None\n\
    parmetis   no    no       None\n\
    #' "$SETUP_FILE"

    # Display the setup file for review
    echo "Contents of setup file:"
    cat "$SETUP_FILE"

    # Pause the script for review
    echo "Press Enter to continue after reviewing the setup file..."
    read
else
    echo "Error: setup file does not exist at $SETUP_FILE"
    exit 1
fi

# Pause the script for review
echo "Press Enter to continue after reviewing the set_ini file..."
read

# Run the install script again
~/hpc_staging/code_saturne-8.0.2/install_saturne.py

# Define the path to Code_Saturne
code_saturne_path="~/hpc_staging/code_saturne-8.0.2/arch/Linux_x86_64/bin"

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

# Ask user if they want to continue with the testing
while true; do
    read -p "Do you wish to continue with testing the installation? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;  # If yes, break the loop and continue
        [Nn]* ) exit;;   # If no, exit the script
        * ) echo "Please answer yes or no.";;  # If invalid response, ask again
    esac
done


echo "Code_Saturne installation test started using cs_user_zones.c in EXAMPLES directory."

# Variables
CODE_SATURNE_EXAMPLES_PATH="~/hpc_staging/code_saturne-8.0.2/arch/Linux_x86_64/share/code_saturne/user_sources/EXAMPLES"
STUDY_NAME="my_study"
CASE_NAME="my_case"
CASE_PATH="~/hpc_staging/saturne_test/${STUDY_NAME}/${CASE_NAME}"

# Create a new study case in hpc_staging/saturne_test
echo "Creating a new Code_Saturne study case..."
mkdir -p ~/hpc_staging/saturne_test
cd ~/hpc_staging/saturne_test
code_saturne create -s $STUDY_NAME -c $CASE_NAME

# Copy the cs_user_zones.c file to the SRC directory of the simulation case
echo "Copying cs_user_zones.c to the case SRC directory..."
cp "$CODE_SATURNE_EXAMPLES_PATH/cs_user_zones.c" "$CASE_PATH/SRC/"

# Navigate to the case directory
cd "$CASE_PATH"

# Compile the case
echo "Compiling the case..."
code_saturne compile

# Run the simulation
echo "Running the simulation..."
code_saturne run

echo "Simulation test case has been completed."
