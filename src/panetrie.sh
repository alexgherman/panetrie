#!/bin/sh

# TODO: does ncurses need to be an explicit dependency?

normal="$(tput sgr0)"
bold="$(tput bold)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
magenta="$(tput setaf 5)"
cyan="$(tput setaf 6)"
white="$(tput setaf 7)"

BASEDIR=$(dirname "$(readlink -f "$0")")

# Default variables
DEFAULT_CONFIG_FILE="/etc/panetrie/panetrie.conf"
DEFAULT_NATIVE_FILENAME=pacman.list
DEFAULT_FOREIGN_FILENAME=aur.list

if [ -n "$CONFIG_FILE" ]; then
    echo "${bold}${green}==>${normal} Custom configuration file path provided"
    CONFIG_FILE=$([[ $CONFIG_FILE = /* ]] && echo $CONFIG_FILE || echo $(realpath "${BASEDIR}/${CONFIG_FILE}"))
    echo "${green}${bold} -> ${yellow}CONFIG_FILE${normal}=${cyan}${CONFIG_FILE}${normal}"
fi

: "${CONFIG_FILE:=$DEFAULT_CONFIG_FILE}"

if ! [ -f $CONFIG_FILE ]; then
    echo "${red}${bold}==> ERROR: Configuration file does not exist [${CONFIG_FILE}]${normal}"
    exit 1
fi

source ${CONFIG_FILE}

: "${native_filename:=$DEFAULT_NATIVE_FILENAME}"
: "${foreign_filename:=$DEFAULT_FOREIGN_FILENAME}"

hr() {
    local total=$(tput cols)
    local header=$([[ -z $1 ]] && echo "" || echo "-$1-" | tr '-' " ")
    local left=$(printf '%*s' "-$(( (total - ${#header}) / 2 ))" '' | tr ' ' =)
    local right=$(printf '%*s' "-$((total - ${#left} - ${#header}))" '' | tr ' ' =)
    echo "${left}${header}${right}"
}

# clean all the tput special characters
cleanse() {
    echo -e "$1" | sed "s/$(echo -e "\e")[^m]*m//g"
}

print_padded() {
    local left_column_max_width=20
    local pad_length=$(tput cols)
    local left=$1
    local middle=$2
    local right=$3
    local left_clean=$(cleanse "$left")
    local middle_clean=$(cleanse "$middle")
    local right_clean=$(cleanse "$right")

    printf '%s ' "$left"
    printf '%.s-' $(seq ${#left_clean} $left_column_max_width)
    printf ' %s ' "$middle"
    printf '%.*s' $((pad_length - left_column_max_width - ${#middle_clean} - ${#right_clean} - 5)) "$(printf '%.0s-' $(seq 1 $pad_length))"
    printf ' %s\n' "$right"
}

print_config_status() {
    local name=$1
    local var_name=$2
    local status=$([[ "${!var_name}" = "0" ]] && echo "${red}${bold}[DISABLED]${normal}" || echo "${green}${bold}[ENABLED]${normal}")
    print_padded "${green}${bold} -> ${yellow}${name}${normal}" "[${magenta}$var_name${normal} = ${cyan}${!var_name}${normal}]" "${status}"
}


hr Configuration
print_config_status "Native packages" native_filename
print_config_status "Foreign packages" foreign_filename
print_config_status "Package versions" package_versions
hr

pacman_cmd="pacman -Qe$([ "${package_versions}" = "0" ] && echo 'q' || echo '')"
eval "${pacman_cmd}n" > /tmp/pacman.list
eval "${pacman_cmd}m" > /tmp/aur.list
