#!/bin/bash
function __besman_install_buyer_ui() {
	if [[ -d $BESMAN_OIAB_BUYER_UI_DIR ]]; then
		__besman_echo_white "Buyer ui code found"
	else
		__besman_echo_white "Cloning source code repo from $BESMAN_ORG/$BESMAN_OIAB_BUYER_UI"
		__besman_repo_clone "$BESMAN_ORG" "$BESMAN_OIAB_BUYER_UI" "$BESMAN_OIAB_BUYER_UI_DIR" || return 1
	fi
	cd "$BESMAN_OIAB_BUYER_UI_DIR" || return 1
	__besman_echo_white "Installing $BESMAN_OIAB_BUYER_UI"
	__besman_echo_yellow "Building OIAB buyer ui"

	# Check Dockerfile port
	if grep -q "EXPOSE 8001" Dockerfile; then
		__besman_echo_yellow "Port 8001 already exposed in Dockerfile"
	else
		sed -i "s/EXPOSE 80/EXPOSE 8001/g" Dockerfile
		__besman_echo_white "Updated Dockerfile port to 8001"
	fi

	# Check nginx.conf port
	if grep -q "listen 8001;" nginx.conf; then
		__besman_echo_yellow "Port 8001 already configured in nginx.conf"
	else
		sed -i "s/listen 80;/listen 8001;/g" nginx.conf
		__besman_echo_white "Updated nginx.conf port to 8001"
	fi

	sudo docker build --build-arg VITE_API_BASE_URL="$BESMAN_IP_ADDRESS:8000" -t oiab-buyer-ui .
	sudo docker run -d --name oiab-buyer-ui -p 8001:8001 oiab-buyer-ui
	cd "$HOME" || return 1

}