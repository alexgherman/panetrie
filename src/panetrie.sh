#!/bin/sh

greeting() {
    cat << EOF

██████╗  █████╗ ███╗   ██╗███████╗████████╗██████╗ ██╗███████╗
██╔══██╗██╔══██╗████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║██╔════╝
██████╔╝███████║██╔██╗ ██║█████╗     ██║   ██████╔╝██║█████╗  
██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝     ██║   ██╔══██╗██║██╔══╝  
██║     ██║  ██║██║ ╚████║███████╗   ██║   ██║  ██║██║███████╗
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝

EOF
}

normal="$(tput sgr0)"
bold="$(tput bold)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
magenta="$(tput setaf 5)"
cyan="$(tput setaf 6)"
white="$(tput setaf 7)"

CONFIG_EXAMPLE_PATH=/usr/share/panetrie/panetrie.conf.example

BASEDIR=$(dirname "$(readlink -f "$0")")

DEFAULT_CONFIG_PATH="/etc/panetrie/panetrie.conf"

DEFAULT_NATIVE_PACKAGES_PATH=/tmp/pacman.list
DEFAULT_FOREIGN_PACKAGES_PATH=/tmp/aur.list
DEFAULT_PACKAGE_VERSIONS=1

if [ -n "$CONFIG_PATH" ]; then
    echo "${bold}${green}==>${normal} Custom configuration file path provided"
    CONFIG_PATH=$([[ $CONFIG_PATH = /* ]] && echo $CONFIG_PATH || echo $(realpath "${BASEDIR}/${CONFIG_PATH}"))
    echo "${green}${bold} -> ${yellow}CONFIG_PATH${normal}=${cyan}${CONFIG_PATH}${normal}"
fi

: "${CONFIG_PATH:=$DEFAULT_CONFIG_PATH}"
if [ -f ${CONFIG_PATH} ]; then
    source ${CONFIG_PATH}
else
    unset CONFIG_PATH
fi

: "${native_packages_path:=$DEFAULT_NATIVE_PACKAGES_PATH}"
: "${foreign_packages_path:=$DEFAULT_FOREIGN_PACKAGES_PATH}"
: "${package_versions:=$DEFAULT_PACKAGE_VERSIONS}"

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

print_config_line_item() {
    local name=$1
    local var_name=$2
    local status=$([[ "${!var_name}" = "0" ]] && echo "${red}${bold}[DISABLED]${normal}" || echo "${green}${bold}[ENABLED]${normal}")
    print_padded "${green}${bold} -> ${yellow}${name}${normal}" "[${magenta}$var_name${normal} = ${cyan}${!var_name}${normal}]" "${status}"
}

print_current_config() {
    hr Configuration
    print_config_line_item "Native packages" native_packages_path
    print_config_line_item "Foreign packages" foreign_packages_path
    print_config_line_item "Package versions" package_versions
    hr
}

refresh() {
    echo "${green}==> ${yellow}${bold}[Panetrie]${normal} Refreshing package lists..."

    # TODO check permissions on these paths before doing anything

    pacman_cmd="pacman -Qe$([ "${package_versions}" = "0" ] && echo 'q' || echo '')"
    eval "${pacman_cmd}n" > ${native_packages_path}
    eval "${pacman_cmd}m" > ${foreign_packages_path}
}

install() {
    greeting
    config
}

cleanup() {
    echo "Attempting to clean up previous package list dumps..."

    local cleaned=0
    if [ -f ${native_packages_path} ]; then
        cleaned=$((cleaned + 1))
        rm ${native_packages_path}
    fi

    if [ -f ${foreign_packages_path} ]; then
        cleaned=$((cleaned + 1))
        rm ${foreign_packages_path}
    fi

    if [ -f ${CONFIG_PATH} ]; then
        cleaned=$((cleaned + 1))
        rm ${CONFIG_PATH}
    fi

    if [ -d $(dirname $CONFIG_PATH) ]; then
        rm -d $(dirname $CONFIG_PATH)
    fi

    if [ $cleaned -gt 0 ]; then
        echo "Done. ${cleaned} dumps removed. Goodbye!"
    else
        echo "No files to clean up. Goodbye!"
    fi
}

config() {
    if [ -n "$CONFIG_PATH" ]; then
        echo "Current configuration values based on [${CONFIG_PATH}]"
    else
        echo "No configuration file provided. Using default values."
        # sudo needed because touching files under /etc
        echo "To customize run: $ sudo panetrie init-config"
    fi
    print_current_config
}

initConfig() {
    mkdir -p $(dirname $1)
    cp ${CONFIG_EXAMPLE_PATH} $1
}

usage() {
    echo "Usage: panetrie [refresh|install|cleanup]"
    echo "🚧 under construction 🚧"
}

main() {

    case $1 in
        refresh)
            refresh
            ;;
        install)
            install
            refresh
            ;;

        cleanup)
            cleanup
            ;;
        config)
            config
            ;;
        init-config)

            if [ -f ${DEFAULT_CONFIG_PATH} ]; then
                echo "${red}Configuration file [${DEFAULT_CONFIG_PATH}] already exists.${normal}"
                read -p "Would you like to reset to default settings? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    initConfig ${DEFAULT_CONFIG_PATH}
                    echo "Config [${DEFAULT_CONFIG_PATH}] re-initialized. Happy usage."
                else
                    echo "Aborting... Nothing happened."
                fi
            else
                initConfig ${DEFAULT_CONFIG_PATH}
                echo "Config [${DEFAULT_CONFIG_PATH}] initialized. Happy usage."
            fi
            ;;
        "")
            if ! [ -f ${native_packages_path} ] && ! [ -f ${foreign_packages_path} ]; then
                install
            fi
            refresh
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
