#!/bin/bash

function __sanity_check ()
{
	local mandatory_env_variables=(
BESLAB_CODECOLLAB_DATASTORES
BESLAB_DASHBOARD_TOOL
BESLAB_DASHBOARD_RELEASE_VERSION
BESMAN_LAB_TYPE
BESMAN_LAB_NAME
BESMAN_VER
BESLAB_VERSION
BLIMAN_VERSION
BESLAB_OIAB_COMPONENTS
)

local undefined_vars=()

for env_var in "${mandatory_env_variables[@]}"
do
   if [ -z "${!env_var}" ];then
	undefined_vars+=("$env_var")
   fi
done

if [ ! $(type -t "__beslab_echo_red")"" == "function" ];then
   source $HOME/.besman/envs/besman-beslab-utils.sh
fi

if [ ! -z $undefined_vars ];then
     __besman_echo_red ""
     __besman_echo_red "ERROR:"
     __besman_echo_red "Following variables are not assigned value in the genesis.yaml file. Assign value to them first and retry."
     __besman_echo_red ""
     for und_var in "${undefined_vars[@]}"
     do
        __besman_echo_red "$und_var"
     done
     __besman_echo_red "Exiting ..."
     __besman_echo_red ""
     exit 1
fi
}

function __besman_install()
{
    __sanity_check
    __besman_echo_white "Installing OIAB components"
    __besman_install_docker || return 1
    __besman_install_docker_compose || return 1
    OLD_IFS=$IFS
    # Split the BESLAB_OIAB_COMPONENTS variable into an array
    IFS=',' read -ra components <<< "$BESLAB_OIAB_COMPONENTS"

    # Iterate over components and call their respective install functions
    for component in "${components[@]}"; do
        # local function_name="__besman_install_${component}"
        # echo "Calling: $function_name"
        # $function_name
        __besman_install_"${component}"
    done
    IFS=$OLD_IFS
}

function __besman_uninstall()
{
    __besman_echo_white "Uninstalling OIAB components"
    OLD_IFS=$IFS
    # Split the BESLAB_OIAB_COMPONENTS variable into an array
    IFS=',' read -ra components <<< "$BESLAB_OIAB_COMPONENTS"

    # Iterate over components and call their respective install functions
    for component in "${components[@]}"; do
        # local function_name="__besman_install_${component}"
        # echo "Calling: $function_name"
        # $function_name
        __besman_uninstall_"${component}"
    done
    IFS=$OLD_IFS
}