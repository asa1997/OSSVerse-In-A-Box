#!/bin/bash

function __besman_update_cors_and_config() {

	__besman_echo_white "Updating CORS and config"

	local seller_cors_file="$BESMAN_SELLER_APP_DIR/seller/app/config/environments/base/env.cors.js"
	local seller_env_file="$BESMAN_SELLER_APP_DIR/seller/.env"
	local seller_api_config="$BESMAN_SELLER_APP_DIR/seller-app-api/lib/config/production_env_config.json"

	if [[ -f $seller_env_file ]]; then
		sed -i "s|OPENFORT_SELLER_APP=.*|OPENFORT_SELLER_APP=$BESMAN_IP_ADDRESS:3008|g" "$seller_env_file"

	else
		__besman_echo_red "Seller env file not found"
		return 1
	fi

	[[ -f $seller_cors_file ]] && rm "$seller_cors_file"
	touch "$seller_cors_file"

	cat <<EOF >"$seller_cors_file"
module.exports = {
    'cors': {
        'whitelistUrls': [
            '*',
            '$BESMAN_IP_ADDRESS'
        ]
    }
};
EOF

	[[ -f $seller_api_config ]] && rm "$seller_api_config"
	touch "$seller_api_config"
	cat <<EOF >"$seller_api_config"
{
  "express": {
    "protocol": "http://",
    "useFqdnForApis": false,
    "ipAddress": "strapi",
    "fqdn": "",
    "port": 3001,
    "apiUrl": ""
  },
  "auth": {
    "token": {
      "access": {
        "exp": 8640000,
        "secret": "wftd3hg5$g67h*fd5h6fbvcy6rtg5wftd3hg5$g67h*fd5xxx"
      },
      "resetPasswordLink": {
        "exp": 86400,
        "secret": "de$rfdf5$g67*jhu*sdfbvcy3frd6r4e"
      }
    }
  },
  "database": {
    "username": "strapi",
    "password": "strapi",
    "name": "sellerapp",
    "host": "postgres",
    "port": "5432",
    "dialect": "postgres",
    "pool": {
      "max": 60,
      "min": 0,
      "acquire": 1000000,
      "idle": 10000,
      "evict": 10000
    }
  },
  "email": {
    "transport": {
      "SMTP": {
        "host": "",
        "port": 587,
        "secure": false,
        "auth": {
          "user": "",
          "pass": ""
        }
      },
      "local": {
        "sendmail": true,
        "newline": "unix",
        "path": "/usr/sbin/sendmail"
      }
    },
    "sender": "",
    "supportEmail": "",
    "webClientUri": "http://34.123.120.224",
    "shareUrl": "https://www.google.com"
  },
  "cors": {
    "whitelistUrls": [
      "http://strapi:3001",
      "$BESMAN_IP_ADDRESS"
    ]
  },
  "directory": {
    "profilePictures": "PROFILE_PICTURES"
  },
  "cookieOptions": {
    "httpOnly": true,
    "secure": false,
    "sameSite": false
  },
  "general": {
    "exceptionEmailRecipientList": []
  },
  "seller": {
    "serverUrl": "http://seller:3008"
  },
  "firebase": {
    "account": ""
  },
  "sellerConfig": {
    "BPP_ID": "sellerapp-staging.datasyndicate.in",
    "BPP_URI": "$BESMAN_IP_ADDRESS:6001",
    "BAP_ID": "sellerapp-staging.datasyndicate.in",
    "BAP_URI": "https://7e3b-2401-4900-1c5d-2b13-814b-de08-9df3-b44e.ngrok-free.app",
    "storeOpenSchedule": {
      "time": {
        "days": "1,2,3,4,5,6,7",
        "schedule": {
          "holidays": [
            "2022-08-15",
            "2022-08-19"
          ],
          "frequency": "PT4H",
          "times": [
            "1100",
            "1900"
          ]
        },
        "range": {
          "start": "1100",
          "end": "2100"
        }
      }
    },
    "sellerPickupLocation": {
      "person": {
        "name": "Ramu"
      },
      "location": {
        "gps": "12.938382, 77.651775",
        "address": {
          "area_code": "560087",
          "name": "Fritoburger",
          "building": "12 Restaurant Tower",
          "locality": "JP Nagar 24th Main",
          "city": "Bengaluru",
          "state": "Karnataka",
          "country": "India"
        }
      },
      "contact": {
        "phone": "98860 98860",
        "email": "abcd.efgh@gmail.com"
      }
    }
  },
  "settlement_details": [
    {
      "settlement_counterparty": "buyer-app",
      "settlement_type": "upi",
      "upi_address": "gft@oksbi",
      "settlement_bank_account_no": "XXXXXXXXXX",
      "settlement_ifsc_code": "XXXXXXXXX"
    }
  ]
}
EOF

	# If any of the above files are not present, return an error
	if [[ ! -f $seller_cors_file ]] || [[ ! -f $seller_api_config ]]; then
		__besman_echo_red "Failed to update CORS and config"
		return 1
	fi

}

function __besman_install_seller_app() {

	__besman_echo_yellow "Installing seller app"
	if [[ -d $BESMAN_SELLER_APP_DIR ]]; then
		__besman_echo_no_colour "Found seller app source code"

	else
		__besman_echo_white "Cloning seller app source code"
		__besman_repo_clone "$BESMAN_ORG" "$BESMAN_SELLER_APP_SOURCE_REPO" "$BESMAN_SELLER_APP_DIR" || return 1
	fi

	cd "$BESMAN_SELLER_APP_DIR" || return 1

	__besman_update_cors_and_config || return 1

	__besman_echo_white "Building seller app"
	sudo docker compose up --build -d

}