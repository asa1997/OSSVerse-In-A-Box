#!/bin/bash
function __besman_install_ossverse_network() {
    if [[ -d $BESMAN_BECKN_ONIX_DIR ]]; then
		__besman_echo_white "Beckn Onix code found"
        return 0
	else
		__besman_echo_white "Cloning source code repo from $BESMAN_BECKN_ONIX_SOURCE/$BESMAN_BECKN_ONIX_SOURCE_REPO"
		__besman_repo_clone "$BESMAN_BECKN_ONIX_SOURCE" "$BESMAN_BECKN_ONIX_SOURCE_REPO" "$BESMAN_BECKN_ONIX_DIR" || return 1
		cd "$BESMAN_BECKN_ONIX_DIR" || return 1
		if [[ "$BESMAN_BECKN_ONIX_SOURCE_BRANCH" != "main" ]]; then
			git checkout "$BESMAN_BECKN_ONIX_SOURCE_BRANCH"
			__besman_echo_white "Switched to branch: $BESMAN_BECKN_ONIX_SOURCE_BRANCH"
		fi
	fi
	# Running the third option in beckn-onix.sh(install file) which will install the entire network in your current machine.
	cd "$BESMAN_BECKN_ONIX_DIR/install" || return 1
	echo "3" | ./beckn-onix.sh

	if [[ "$?" != "0" ]]; then
		__besman_echo_red "Failed to install using OSSVerse Onix"
		return 1
	else
		__besman_echo_green "Successfully installed the entire network using OSSVerse Onix"
		return 0
	fi
}
