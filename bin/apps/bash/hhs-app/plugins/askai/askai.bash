#!/usr/bin/env bash

#  Script: askai.bash
# Purpose: Manager for HomeSetup AskAI integration
# Created: Aug 19, 2024
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: homesetup@gmail.com
#    Site: https://github.com/yorevs#homesetup
# License: Please refer to <https://opensource.org/licenses/MIT>
#
# Copyright (c) 2024, HomeSetup team

# Current plugin name
PLUGIN_NAME="askai"

UNSETS=(
  help version cleanup execute args action db_alias dotfiles
)

AI_ENABLED="${AI_ENABLED:-$(python3 -m pip show hspylib-askai &>/dev/null && echo 1)}"

ASKAI_URL="https://github.com/yorevs/askai"

# @purpose: HHS plugin required function
function help() {
  [[ -n "${AI_ENABLED}" ]] && python3 -m ${PLUGIN_NAME} -h
  exit $?
}

# @purpose: HHS plugin required function
function version() {
  [[ -n "${AI_ENABLED}" ]] && python3 -m ${PLUGIN_NAME} -v
  exit $?
}

# @purpose: HHS plugin required function
function cleanup() {
  unset -f "${UNSETS[@]}"
  echo -n ''
}

# @purpose: HHS plugin required function
function execute() {

  [[ -n "${AI_ENABLED}" ]] || quit 1 "AskAI is not installed. Visit ${ASKAI_URL} for installation instructions"

  local args output ans script_name

  echo "${GREEN}Processing..."

  # shellcheck disable=SC2206
  args=("$@")
  output=$(python3 -m askai -c off -p "${HHS_PROMPTS_DIR}/homesetup.txt" "${args[@]}" 1>&1)
  [[ -z "${output}" ]] && echo -e "The query didn't produce an output!" && exit 1
  script_name=$(echo "${output}" | grep "^# [Ss]cript [Nn]ame:" | cut -d ':' -f2 | xargs)
  if [[ -z "${script_name}" ]]; then
    echo -e "${YELLOW}I was unable to detect the script name${NC}"
    echo "${output}"
    echo ''
    quit 0
  fi
  script_name="${script_name#*:}"
  script_name="${script_name%.*}.bash"

  if [[ -s "${script_name}" ]]; then
    echo -e "${ORANGE}"
    read -rn 1 -p "File '${script_name}' already exists. Overwrite it (y/[n])? " ans
    echo -e "${NC}" && [[ -n "${ans}" ]] && echo ''
    if [[ -n "${ans}" ]] && [[ "${ans}" == "y" || "${ans}" == 'Y' ]]; then
      echo -en "${BLUE}Writing file: ${WHITE}${script_name}${NC}... "
      echo "${output}" > "${script_name}"
      [[ -s "${script_name}" ]] && echo "${GREEN}OK${NC}"
      [[ -s "${script_name}" ]] || echo "${RED}FAILED${NC}"
    fi
  else
    echo "${output}" > "${script_name}"
  fi

  if [[ -s "${script_name}" ]]; then
    chmod +x "${script_name}"
    if __hhs_has bat; then bat "${script_name}"; else cat "${script_name}"; fi
  fi

  echo "${GREEN}Finished!${NC}"
  quit 0
}
