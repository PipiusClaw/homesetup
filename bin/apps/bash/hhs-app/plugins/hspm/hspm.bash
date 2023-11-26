#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1090

#  Script: hspm.bash
# Purpose: Manage your development tools using installation/uninstallation recipes.
# Created: Jan 06, 2020
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: homesetup@gmail.com
#    Site: https://github.com/yorevs#homesetup
# License: Please refer to <https://opensource.org/licenses/MIT>
#
# Copyright (c) 2023, HomeSetup team

# Current script version.
VERSION=0.9.2

# Current plugin name
PLUGIN_NAME="hspm"

# Usage message
USAGE="
usage: $PLUGIN_NAME [option] {install,uninstall,list,recover}

 _   _ ____  ____  __  __
| | | / ___||  _ \|  \/  |
| |_| \___ \| |_) | |\/| |
|  _  |___) |  __/| |  | |
|_| |_|____/|_|   |_|  |_|

  HomeSetup package manager

    options:
      -v  |   --version     : Display current program version.
      -h  |      --help     : Display this help message.

    arguments:
      install   <package>   : Install the package using a matching installation recipe.
      uninstall <package>   : Uninstall the package using a matching uninstallation recipe.
      list                  : List all available, OS based, installation recipes.
      recover [-i,-t,-e]    : Install or list all packages previously installed by hspm. If -i is provided, then hspm
                              will attempt to install all packages, otherwise the list is displayed. If -t is provided
                              hspm will check \${HHS_DEV_TOOLS} instead of previously installed packages. If -e is
                              provided, then the default editor will open the recovery file.

"

UNSETS=(
  help version cleanup execute cleanup_recipes list_recipes
  install_recipe uninstall_recipe
  add_breadcrumb del_breadcrumb recover_packages
  _install_ _uninstall_ _about_ _depends_ _which_
)

[[ -s "$HHS_DIR/bin/app-commons.bash" ]] && source "$HHS_DIR/bin/app-commons.bash"

# Flag to install all recovered packages
RECOVER_INSTALL=

# Flag to recover HHS_DEV_TOOLS instead of breadcrumbs
RECOVER_TOOLS=

# Hold all hspm recipes
ALL_RECIPES=()

# Directory containing all hspm recipes
RECIPES_DIR="${PLUGINS_DIR}/hspm/recipes"

# File containing all installed/uninstalled packages
BREADCRUMB_FILE="${HHS_DIR}/.hspm"

# Known package managers
KNOWN_PCG_MANAGERS=('brew' 'apt-get' 'apt' 'yum' 'dnf' 'apk')

# Sudo command
SUDO=

# HSPM log file
LOGFILE="${}"

# @purpose: HHS plugin required function
function help() {
  usage 0
}

# @purpose: HHS plugin required function
function version() {
  echo "${PLUGIN_NAME} v${VERSION}"
  exit 0
}

# @purpose: HHS plugin required function
function cleanup() {
  unset "${UNSETS[@]}"
  echo -n ''
}

# @purpose: HHS plugin required function
function execute() {

  local cmd args

  [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]] && usage 0
  [[ "$1" == "-v" || "$1" == "--version" ]] && version

  touch "${BREADCRUMB_FILE}" || quit 1 "Unable to access hspm file: ${BREADCRUMB_FILE}"

  if [[ -z "${HHS_MY_OS_PACKMAN}" ]]; then
    for pkg_man in "${KNOWN_PCG_MANAGERS[@]}"; do
      command -v "${pkg_man}" &>/dev/null && HHS_MY_OS_PACKMAN="${HHS_MY_OS_PACKMAN:-"${pkg_man}"}"
    done
    [[ -z "${OS_APP_MAN}" ]] && quit 1 "hspm.bash: no suitable tool found to install software on this machine. Tried: ${KNOWN_PCG_MANAGERS[*]}"
  fi

  cmd="$1"
  shift
  args=("$@")

  shopt -s nocasematch
  case "$cmd" in
  # Install the app
  install)
    [[ "${#}" -le 0 ]] && usage 1
    for next_recipe in "${@}"; do
      echo ''
      install_recipe "${next_recipe}"
    done
    echo ''
    ;;
  # Uninstall the app
  uninstall)
    [[ "${#}" -le 0 ]] && usage 1
    for next_recipe in "${@}"; do
      echo ''
      uninstall_recipe "${next_recipe}"
    done
    echo ''
    ;;
  # Recover installed apps
  recover)
    [[ "$1" == "-e" || "$2" == "-e" || "$3" == "-e" ]] && __hhs_open "${BREADCRUMB_FILE}" && exit 0
    [[ "$1" == "-i" || "$2" == "-i" ]] && RECOVER_INSTALL=1
    [[ "$1" == "-t" || "$2" == "-t" ]] && RECOVER_TOOLS=1
    recover_packages
    ;;
  # List available apps
  list)
    if [[ "$1" == "-a" ]]; then
      LIST_ALL=1
    fi
    echo -e "\n${BLUE}Listing ${LIST_ALL//1/all }available hspm '${HHS_MY_OS}' recipes ... ${NC}\n"
    list_recipes
    echo -e "\n${BLUE}Found (${#ALL_RECIPES[@]}) recipes${NC}\n"
    ;;
  *)
    usage 1 "Invalid ${PLUGIN_NAME} command: \"${cmd}\" !"
    ;;
  esac
  shopt -u nocasematch

  quit 0
}

# @purpose: Add a package to the breadcrumb file
function add_breadcrumb() {
  local package="${1}" os="${HHS_MY_OS_RELEASE}"
  grep -qxF "${os}:${package}" "${BREADCRUMB_FILE}" || echo "${os}:${package}" >>"${BREADCRUMB_FILE}"
}

# @purpose: Remove a package to the breadcrumb file
function del_breadcrumb() {
  local package="${1}" os="${HHS_MY_OS_RELEASE}"
  ised -e "/${os}:${package}/d" "${BREADCRUMB_FILE}"
}

# purpose: Unset all declared functions from the recipes
function cleanup_recipes() {
  unset -f _install_ _uninstall_ _about_ _depends_ _which_
}

# shellcheck disable=2155,SC2059,SC2183
# purpose: List all available hspm recipes
function list_recipes() {

  local index=0 recipe pad_len=20 pad os app

  pad=$(printf '%0.1s' "."{1..60})

  # shellcheck disable=SC2207
  ALL_RECIPES=($(find "${RECIPES_DIR}/${HHS_MY_OS}" -type f -name "*.recipe" | sort))

  if [[ ${#ALL_RECIPES[@]} -le 0 ]]; then
    index=$((index + 1))
    echo -e "${ORANGE}No recipes found matching OS='${HHS_MY_OS}'${NC}"
  fi

  for recipe in "${ALL_RECIPES[@]}"; do
    app="$(basename "${recipe//\.*/}")"
    if [[ -n "${app}" && -f "${recipe}" ]]; then
      index=$((index + 1))
      source "${recipe}"
      printf '%3s - %s' "${index}" "${BLUE}${app} "
      printf '%*.*s' 0 $((pad_len - ${#app})) "${pad}"
      echo -e "${GREEN} => ${WHITE}$(_about_) ${NC}"
      cleanup_recipes
    fi
  done

  return 0
}

# purpose: Install the specified app using the installation recipe
function install_recipe() {

  local recipe package

  package="${1}"
  recipe="${RECIPES_DIR}/$(uname -s)/${package}.recipe"

  # Source the default recipe, so we can override only what we need
  source "${RECIPES_DIR}/${HHS_MY_OS}/default.recipe"
  package=$(basename "${recipe%\.*}")

  # Check if the package is already installed
  if _which_ "${package}"; then echo -e "${YELLOW}Package \"${package}\" is already installed!\n"; quit 0; fi

  if [[ -f "${recipe}" ]]; then
    source "${recipe}"
    echo -e "${BLUE}Using recipe for \"${package}\""
  else
    echo -e "${YELLOW}Using [${HHS_MY_OS_PACKMAN}] default installation for \"${package}\"!"
  fi

  echo -e "${BLUE}Installing \"${package}\", please wait ..."

  if _depends_ && _install_ "${package}" && _which_ "${package}"; then
    echo -e "${GREEN}Installation successful => \"${package}\" ${NC}"
    add_breadcrumb "${package}"
  else
    quit 1 "${PLUGIN_NAME}: Failed to install \"${package}\" !"
  fi
}

# purpose: Uninstall the specified app using the uninstallation recipe
function uninstall_recipe() {

  local recipe package

  package="${1}"
  recipe="${RECIPES_DIR}/$(uname -s)/${package}.recipe"

  # Source the default recipe, so we can override only what we need
  source "${RECIPES_DIR}/${HHS_MY_OS}/default.recipe"
  package=$(basename "${recipe%\.*}")

  # Check if the package is already installed
  if ! _which_ "${package}"; then echo -e "${YELLOW}Package \"${package}\" is not installed!\n"; quit 0; fi

  if [[ -f "${recipe}" ]]; then
    source "${recipe}"
    echo -e "${BLUE}Using recipe for \"${package}\""
  else
    echo -e "${YELLOW}Using [${HHS_MY_OS_PACKMAN}] default uninstallation recipe for \"${package}\"!"
  fi

  echo -e "${BLUE}Uninstalling \"${package}\", please wait ..."

  if _uninstall_ "${package}" && ! _which_ "${package}"; then
    echo -e "${GREEN}Uninstallation successful => \"${package}\" ${NC}"
    del_breadcrumb "${package}"
  else
    quit 1 "${PLUGIN_NAME}: Failed to uninstall \"${package}\" !"
  fi
}

# @purpose: Install or list all packages previously installed by hspm.
function recover_packages() {

  local index=0 package pad_len=30 pkg pad all_packages=() os=${HHS_MY_OS_RELEASE}

  pad=$(printf '%0.1s' "."{1..80})

  if [[ -n "${RECOVER_INSTALL}" ]]; then
    echo -en "\n${ORANGE}Installing "
  else
    echo -en "\n${ORANGE}Listing "
  fi

  if [[ -z "${RECOVER_TOOLS}" ]]; then
    echo -e "recovered [${HHS_MY_OS}/${HHS_MY_OS_RELEASE}] packages ... "
    while read -r package; do
      all_packages+=("${package}")
    done < <(grep "^${os}:" "${BREADCRUMB_FILE}")
  else
    echo -e "development tools ... "
    # shellcheck disable=SC2206
    all_packages+=(${HHS_DEV_TOOLS[@]})
  fi
  echo "${NC}"

  if [[ -n "${RECOVER_INSTALL}" ]]; then
    for pkg in "${all_packages[@]}"; do
      package="${pkg#*:}"
      if ! command -v "${package}" &>/dev/null; then
        printf '%3s - %s' "${index}" "${BLUE}Installing package ${package} ${NC}"
        printf '%*.*s' 0 $((pad_len - ${#package})) "${pad}"
        if install_recipe "${package}" &>/dev/null; then
          echo -e " [   ${GREEN}OK${NC}   ]"
        else
          echo -e " [ ${RED}FAILED${NC} ]"
        fi
        index=$((index + 1))
      fi
    done
  else
    for pkg in "${all_packages[@]}"; do
      package="${pkg#*:}"
      printf '%3s - %s' "${index}" "${BLUE}${package} "
      printf '%*.*s' 0 $((pad_len - ${#package})) "${pad}"
      command -v "${package}" &>/dev/null && echo -e "${GREEN} INSTALLED${NC}" || echo -e "${RED} NOT INSTALLED${NC}"
      index=$((index + 1))
    done
  fi
  [[ $index -gt 0 ]] || echo "${YELLOW}No previously installed packages were found ${NC}"
  echo ''
}
