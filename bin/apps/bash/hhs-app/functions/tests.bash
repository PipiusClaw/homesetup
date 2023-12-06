#!/usr/bin/env bash

#  Script: tests.bash
# Purpose: Contains HomeSetup test functions
# Created: Mar 04, 2020
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: homesetup@gmail.com
#    Site: https://github.com/yorevs#homesetup
# License: Please refer to <https://opensource.org/licenses/MIT>
#
# Copyright (c) 2023, HomeSetup team

# @purpose: Run all HomeSetup automated tests.
function tests() {

  local started finished err_log badge fail=0 pass=0 status num details re_status re_len len re_skip
  local diff_time diff_time_sec diff_time_ms all_tests=("${@}")

  command -v bats &>/dev/null || quit 1 "'Bats' application not available on your PATH !"

  err_log="${TEMP}/homesetup-tests.log"
  badge="${HHS_HOME}/check-badge.svg"

  [[ ${#all_tests[@]} -eq 0 ]] && all_tests=("${HHS_HOME}"/tests/*.bats)

  [[ ${#all_tests[@]} -eq 0 ]] && quit 1 "There are no tests to execute!"

  # Execute bats tests
  echo -n '' > "${err_log}"
  re_status='^(ok|not ok) ([0-9]+) (.+) in .*$'
  re_len='^([0-9]+)\.\.([0-9]+)$'
  re_skip='^(ok|not ok) ([0-9]+) (.+) # skip (.*)'
  started="$(python -c 'import time; print(int(time.time() * 1000))')"
  echo -e "\n${WHITE}[$(date +'%H:%M:%S')] Running HomeSetup bats tests\n"
  echo -e "|-Bats v$(__hhs_version bats | head -n 1)"
  echo -e "|-Bash v$(__hhs_version bash | head -n 1)\n"

  for next in "${all_tests[@]}"; do
    while read -r result; do
      if [[ ${result} =~ ${re_skip} ]]; then
        status="${YELLOW} ${SKIP_ICN} SKIP${NC}"
        num="${BASH_REMATCH[2]}"
        details="${BASH_REMATCH[3]}"
      elif [[ ${result} =~ ${re_status} ]]; then
        status="${BASH_REMATCH[1]}"
        num="${BASH_REMATCH[2]}"
        details="${BASH_REMATCH[3]}"
        if [[ "${status}" == 'not ok' ]]; then
          status="${RED} ${FAIL_ICN} FAIL${NC}"
          ((fail += 1))
        elif [[ "${status}" == 'ok' ]]; then
          status="${GREEN} ${PASS_ICN} PASS${NC}"
          ((pass += 1))
        else
          status="? ????"
        fi
        echo -en "${status} "
        printf "%${len}d %s\n" "${num}" "${details}"
      elif [[ ${result} =~ ${re_len} ]]; then
        echo -en "\n${WHITE}[${next##*/}] Running tests ${BASH_REMATCH[1]} to ${BASH_REMATCH[2]}${NC}\n\n"
        len="${#BASH_REMATCH[2]}"
      else
        echo -e "${result}" >>"${err_log}"
      fi
    done < <(bats -rtT "${next}" 2>&1)
  done

  finished="$(python -c 'import time; print(int(time.time() * 1000))')"
  diff_time=$((finished - started))
  diff_time_sec=$((diff_time/1000))
  diff_time_ms=$((diff_time-(diff_time_sec*1000)))

  echo -en "\n\n${WHITE}[$(date +'%H:%M:%S')] Finished running $((pass + fail)) tests:\t"
  echo -e "Passed=${pass}  Failed=${fail}${NC}"

  if [[ ${fail} -gt 0 ]]; then
    echo ''
    echo -e "${ORANGE}xXx The following errors were reported xXx${NC}"
    echo ''
    __hhs_tailor "${err_log}" | nl
    echo ''
    curl 'https://badgen.net/badge/tests/failed/red' --output "${badge}" 2>/dev/null
    echo -e "${RED}${TEST_FAIL_ICN}${WHITE}  Bats tests ${RED}FAILED${WHITE} in ${diff_time_sec}s ${diff_time_ms}ms ${NC}"
    quit 2
  else
    echo ''
    curl 'https://badgen.net/badge/tests/passed/green' --output "${badge}" 2>/dev/null
    echo -e "${GREEN}${TEST_PASS_ICN}${NC}  ${WHITE}All Bats tests ${GREEN}PASSED${WHITE} in ${diff_time_sec}s ${diff_time_ms}ms ${NC}"
  fi

  quit 0 ''
}

# @purpose: Run all terminal color palette tests.
function color-tests() {

  echo ''
  echo -e "${ORANGE}--- Home Setup color palette test ${NC}"
  echo ''

  echo -en "${BLACK}  BLACK "
  echo -en "${RED}    RED "
  echo -en "${GREEN}  GREEN "
  echo -en "${ORANGE} ORANGE "
  echo -en "${BLUE}   BLUE "
  echo -en "${PURPLE} PURPLE "
  echo -en "${CYAN}   CYAN "
  echo -en "${GRAY}   GRAY "
  echo -en "${WHITE}  WHITE "
  echo -en "${YELLOW} YELLOW "
  echo -en "${VIOLET} VIOLET "
  echo -e "${NC}\n"

  echo "--- 16 Colors Low"
  echo ''
  for c in {30..37}; do
    echo -en "\033[0;${c}mC16-${c} "
  done
  echo -e "${NC}\n"

  echo "--- 16 Colors High"
  echo ''
  for c in {90..97}; do
    echo -en "\033[0;${c}mC16-${c} "
  done
  echo -e "${NC}\n"

  if [[ "${TERM##*-}" == "256color" ]]; then
    echo "--- 256 Colors"
    echo ''
    for c in {1..256}; do
      echo -en "\033[38;5;${c}m"
      printf "C256-%-.3d " "${c}"
      [[ "$(echo "$c % 12" | bc)" -eq 0 ]] && echo ''
    done
    echo -e "${NC}\n"
  fi

  echo ''

  quit 0
}
