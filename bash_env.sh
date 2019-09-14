#!/usr/bin/env bash
# shellcheck disable=SC2155

#  Script: bash_env.sh
# Purpose: This file is used to configure shell environment variables
# Created: Aug 26, 2008
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <http://unlicense.org/>
# !NOTICE: Do not change this file. To customize your environment variables edit the file ~/.env

# System locale
export LC_ALL=en_US
export LANG=en_US.UTF-8
export MY_OS="$(uname -s)"

# ----------------------------------------------------------------------------
# Home Sweet Homes

# Java
if command -v java >/dev/null; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/Current/Contents/Home"
    export JDK_HOME="$JAVA_HOME"
fi

# Python
command -v python >/dev/null && export PYTHON_HOME="/System/Library/Frameworks/Python.framework/Versions/Current"

# Qt
[ -d /usr/local/opt/qt/bin ] && export QT_HOME="/usr/local/opt/qt/bin"

# XCode
if command -v xcode-select >/dev/null; then
    export XCODE_HOME="$(xcode-select -p)"
    export MACOS_SDK="$XCODE_HOME/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
fi

# ----------------------------------------------------------------------------
# Other environment variables
export TEMP="${TEMP:-$TMPDIR}"
export TRASH="${TRASH:-$HOME/.Trash}"
export HOME_SETUP="$HOME/HomeSetup"
export HHS_DIR="$HOME/.hhs"
command -v git >/dev/null && export GIT_REPOS="$HOME/GIT-Repository"
command -v svn >/dev/null && export SVN_REPOS="$HOME/SVN-Repository"
[ -d "$HOME/Dropbox" ] && export DROPBOX="$HOME/Dropbox"
export WORKSPACE="$HOME/Workspace"
export DESKTOP="$HOME/Desktop"
export DOWNLOADS="$HOME/Downloads"

# Setting history length ( HISTSIZE and HISTFILESIZE ) in bash.
export HISTSIZE=${HISTSIZE:-1000}
export HISTFILESIZE=${HISTFILESIZE:-2000}
# Don't put duplicate lines in the history.
export HISTCONTROL=ignoredups:ignorespace:ignoreboth:erasedups

# ----------------------------------------------------------------------------
# HomeSetup variables
export DOTFILES_VERSION=$(grep . "$HOME_SETUP/.VERSION")
export HHS_WELCOME="${ORANGE}${MY_OS} ${GREEN}¯\_(ツ)_/¯ Welcome to HomeSetup\xef\x87\xb9 ${BLUE}v${DOTFILES_VERSION}${NC}"
export RESET_IFS="$IFS"
export MSELECT_MAX_ROWS=10
export SAVED_DIRS="$HHS_DIR/.saved_dirs"
export CMD_FILE="$HHS_DIR/.cmd_file"
export PUNCH_FILE="$HHS_DIR/.punches"
export PATHS_FILE="$HOME/.path"

# Development tools. To override it please export DEFAULT_DEV_TOOLS variable at ~/.env
export DEFAULT_DEV_TOOLS=(
    "bash" "ssh" "xcode-select" "brew" "tree" "vim" "pcregrep"  
    "shfmt" "node" "java" "rvm" "ruby" "go" "gcc" "make" "qmake"
    "doxygen" "ant" "mvn" "gradle" "git" "svn" "cvs" "docker"
    "nvm" "npm" "jenv" "vue" "eslint" "gpg" "base64" "md5" "shasum"
    "htop" "dialog" "telnet" "figlet" "shellcheck" "perl" "hexdump" 
    "iconfig" "python"
)

# Icons to be displayed. Check https://fontawesome.com/cheatsheet?from=io for details
export HIST_ICN="\357\207\232"
export USER_ICN="\357\200\207"
export ROOT_ICN="\357\224\205"
export GIT_ICN="\357\204\246"
export AT_ICN="\357\207\272"
export NET_ICN="\357\233\277"
export FOLDER_ICN="\357\201\273"