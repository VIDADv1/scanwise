#!/bin/bash
#
#   Copyright 2024 gitricko
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

set -e

track_last_command() {
    last_command=$current_command
    current_command=$BASH_COMMAND
}
trap track_last_command DEBUG

echo_failed_command() {
    local exit_code="$?"
	if [[ "$exit_code" != "0" ]]; then
		echo "'$last_command': command failed with exit code $exit_code."
	fi
}
trap echo_failed_command EXIT

# Global variables
export SCANWISE_SOURCES="https://raw.githubusercontent.com/VIDADv1/scanwise/main/scripts/makefile.sh"  # URL where makefile.sh is hosted

if [ -z "$SCANWISE_DIR" ]; then
    SCANWISE_DIR="$HOME/.scanwise"
fi
export SCANWISE_DIR

# Local variables
scanwise_bashrc="${HOME}/.bashrc"
scanwise_zshrc="${HOME}/.zshrc"


cat <<'EOF'
               _____                 __          __ _
              / ____|                \ \        / /(_)
             | (___    ___  __ _  _ __\ \  /\  / /  _  ___   ___
              \___ \  / __|/ _` || '_ \\ \/  \/ /  | |/ __| / _ \
              ____) || (__| (_| || | | |\  /\  /   | |\__ \|  __/
             |_____/  \___|\__,_||_| |_| \/  \/    |_||___/ \___|

EOF
echo ''
echo ''
echo '                                                     Now attempting installation...'
echo ''                                                                 


# Sanity checks

echo "Looking for a previous installation of SCANWISE..."
if [ -d "$SCANWISE_DIR" ]; then
	echo "SCANWISE found."
	echo ""
	echo "======================================================================================================"
	echo " You already have SCANWISE installed."
	echo " SCANWISE was found at:"
	echo ""
	echo "    ${SCANWISE_DIR}"
	echo ""
	echo " Please consider uninstalling and reinstall."
	echo ""
	echo "    $ scanwise uninstall "
	echo ""
	echo "               or "
	echo ""
	echo "    $ rm -rf ${SCANWISE_DIR}"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for docker..."
if ! command -v docker > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install docker on your system using your favourite package manager."
	echo ""
	echo " Restart after installing docker."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for jq..."
if ! command -v jq > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install jq on your system using your favourite package manager."
	echo ""
	echo " Restart after installing jq."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Looking for sed..."
if ! command -v sed > /dev/null; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install sed on your system using your favourite package manager."
	echo ""
	echo " Restart after installing sed."
	echo "======================================================================================================"
	echo ""
	exit 1
fi

echo "Installing Scanwise helper scripts..."

# Create directory structure
mkdir -p "${SCANWISE_DIR}"

set +e
# Download makefile.sh depending which env (git or over curl)
# Check if you are in scanwise git
LOCAL_FILE_EXIST=$([[ -d ./.git ]] && git remote get-url origin | grep -q scanwise && [[ -s ./scripts/makefile.sh ]]; echo "$?")
if [[ "${LOCAL_FILE_EXIST}" -eq "0" ]]; then
	echo "* Copying from local git..."
	cp -f ./scripts/makefile.sh "${SCANWISE_DIR}"
else
	echo "* Downloading..."
	curl --fail --location --progress-bar "${SCANWISE_SOURCES}" > "${SCANWISE_DIR}/makefile.sh"
	chmod +x "${SCANWISE_DIR}/makefile.sh"
fi

# Create alias in ~/.bashrc ~/.zshrc if available
if [[ ! -s "${scanwise_bashrc}" ]] || ! grep -q 'scanwise' "${scanwise_bashrc}" ;then
	echo "alias scanwise='$HOME/.scanwise/makefile.sh'" >> "${scanwise_bashrc}"
fi

if [[ ! -s "${scanwise_zshrc}" ]] || ! grep -q 'scanwise' "${scanwise_zshrc}"; then
	echo "alias scanwise='$HOME/.scanwise/makefile.sh'" >> "${scanwise_zshrc}"
fi

# Dynamically create the alias during installation so that use can use it
if ! command -v scanwise > /dev/null; then
	alias scanwise='$HOME/.scanwise/makefile.sh'
fi

echo ""
echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    alias scanwise='$HOME/.scanwise/makefile.sh' "
echo ""
echo "Then issue the following command:"
echo ""
echo "    scanwise help"
echo ""
echo "Enjoy!!!"