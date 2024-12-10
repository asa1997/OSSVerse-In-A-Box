#!/bin/bash

function __besman_install_buyer_app() {

    local env_file="$BESMAN_OIAB_BUYER_APP_DIR/.env.default"
	if [[ -d $BESMAN_OIAB_BUYER_APP_DIR ]]; then
		__besman_echo_white "Buyer app code found"
	else
		__besman_echo_white "Cloning source code repo from $BESMAN_ORG/$BESMAN_OIAB_BUYER_APP"
		__besman_repo_clone "$BESMAN_ORG" "$BESMAN_OIAB_BUYER_APP" "$BESMAN_OIAB_BUYER_APP_DIR" || return 1
	fi
	cd "$BESMAN_OIAB_BUYER_APP_DIR" || return 1
	# Check if MongoDB port is already mapped to 27018
	if grep -q "27018:27017" docker-compose.yml; then
		__besman_echo_yellow "MongoDB port already mapped to 27018"
	else
		sed -i 's/27017:27017/27018:27017/' docker-compose.yml
		__besman_echo_white "Updated MongoDB port mapping to 27018:27017"
	fi

	sed -i "s|PROTOCOL_SERVER_URL=.*|PROTOCOL_SERVER_URL=$BESMAN_IP_ADDRESS:5001|g" "$env_file"
	sed -i "s|BAP_ID=.*|BAP_ID=$BESMAN_BAP_ID|g" "$env_file"
	sed -i "s|BAP_URI=.*|BAP_URI=$BESMAN_BAP_URI|g" "$env_file"

	__besman_echo_white "Installing $BESMAN_OIAB_BUYER_APP"
	__besman_echo_yellow "Building buyer app"
	sudo docker compose up --build -d
	cd "$HOME" || return 1
}