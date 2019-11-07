#!/usr/bin/env bash
# shellcheck disable=SC2155

#  Script: bash_env.bash
# Purpose: This file is used to configure shell environment variables
# Created: Aug 26, 2008
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <http://unlicense.org/>
# !NOTICE: Do not change this file. To customize your environment variables edit the file ~/.env

# System locale (defaults)
export LC_ALL=en_US
export LANG=en_US.UTF-8

export HHS_MY_OS="$(uname -s)"
export HHS_MY_SHELL="${SHELL//\/bin\//}"

# ----------------------------------------------------------------------------
# Home Sweet Homes

# Java
if command -v java >/dev/null; then
    export JAVA_HOME=${JAVA_HOME:-"/Library/Java/JavaVirtualMachines/Current/Contents/Home"}
    export JDK_HOME="${JDK_HOME:-$JAVA_HOME}"
fi

# Python
if command -v python >/dev/null; then
    export PYTHON_HOME="/System/Library/Frameworks/Python.framework/Versions/Current"
fi

# Qt
if command -v qmake >/dev/null|| [ -d /usr/local/opt/qt/bin ]; then
    export QT_HOME="/usr/local/opt/qt/bin"
fi

# XCode
if command -v xcode-select >/dev/null; then
    export XCODE_HOME="$(xcode-select -p)"
    export MACOS_SDK="$XCODE_HOME/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
fi

# ----------------------------------------------------------------------------
# Other environment variables
export TEMP="${TEMP:-$TMPDIR}"
export TRASH="${TRASH:-$HOME/.Trash}"

command -v git >/dev/null && export GIT_REPOS="${GIT_REPOS:-$HOME/GIT-Repository}"
command -v svn >/dev/null && export SVN_REPOS="${SVN_REPOS:-$HOME/SVN-Repository}"

[ -d "$HOME/Workspace" ] && export WORKSPACE="${WORKSPACE:-$HOME/Workspace}"
[ -d "$HOME/Desktop" ] && export DESKTOP="${DESKTOP:-$HOME/Desktop}"
[ -d "$HOME/Downloads" ] && export DOWNLOADS="${DOWNLOADS:-$HOME/Downloads}"
[ -d "$HOME/Dropbox" ] && export DROPBOX="${DROPBOX:-$HOME/Dropbox}"

# Setting history length ( HISTSIZE and HISTFILESIZE ) in bash
export HISTSIZE=${HISTSIZE:-1000}
export HISTFILESIZE=${HISTFILESIZE:-2000}
export HISTTIMEFORMAT=${HISTTIMEFORMAT:-"[%F %T] "}

# History control ( ignore duplicates and spaces )
export HISTCONTROL=${HISTCONTROL:-"ignoreboth:erasedups"}
export HISTFILE="${HISTFILE:-$HOME/.bash_history}"

# Hide the annoying warning about zsh
[ "Darwin" = "$HHS_MY_OS" ] && export BASH_SILENCE_DEPRECATION_WARNING=1

# ----------------------------------------------------------------------------
# HomeSetup variables

# Fixed
export HHS_HOME="$HOME/HomeSetup"
export HHS_DIR="$HOME/.hhs"
export HHS_VERSION=$(grep . "$HHS_HOME/.VERSION")
export HHS_WELCOME="${ORANGE}${HHS_MY_OS} ${GREEN}¯\_(ツ)_/¯ Welcome to HomeSetup\xef\x87\xb9 ${BLUE}v${HHS_VERSION}${NC}"
export HHS_RESET_IFS="$IFS"

# Customizeable
export HHS_MSELECT_MAX_ROWS=${HHS_MSELECT_MAX_ROWS:-10}
export HHS_SAVED_DIRS="${HHS_SAVED_DIRS:-$HHS_DIR/.saved_dirs}"
export HHS_CMD_FILE="${HHS_CMD_FILE:-$HHS_DIR/.cmd_file}"
export HHS_PUNCH_FILE="${HHS_PUNCH_FILE:-$HHS_DIR/.punches}"
export HHS_PATHS_FILE="${HHS_PATHS_FILE:-$HOME/.path}"

# Development tools. To override it please export HHS_DEV_TOOLS variable at ~/.env
HHS_DEFAULT_DEV_TOOLS=(
    "bash" "ssh" "xcode-select" "brew" "tree" "vim" "pcregrep"  
    "shfmt" "node" "java" "rvm" "ruby" "go" "gcc" "make" "qmake"
    "doxygen" "ant" "mvn" "gradle" "git" "svn" "cvs" "docker"
    "nvm" "npm" "jenv" "vue" "eslint" "gpg" "base64" "md5" "shasum"
    "htop" "dialog" "telnet" "figlet" "shellcheck" "perl" "hexdump" 
    "python" "python3" "jq"
)

export HHS_DEV_TOOLS=${HHS_DEV_TOOLS:-${HHS_DEFAULT_DEV_TOOLS[*]}}