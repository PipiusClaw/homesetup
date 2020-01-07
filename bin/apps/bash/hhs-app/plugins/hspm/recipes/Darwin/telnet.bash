function about() {
  echo "Provide a bidirectional interactive text-oriented communication facility using a virtual terminal"
}

function depends() {
  if ! command -v brew >/dev/null; then
    echo "${RED}HomeBrew is required to install telnet${NC}"
    return 1
  fi

  return 0
}

function install() {
  command brew install telnet
  return $?
}

function uninstall() {
  command brew uninstall telnet
  return $?
}
