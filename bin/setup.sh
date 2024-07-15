#!/usr/bin/env bash
# shellcheck disable=SC1091

PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Conditionally install Homebrew
install_homebrew() {
  if ! command -v brew >/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

# Installs all packages from Brewfile
install_homebrew_bundle() {
  echo -e "\n\033[1mInstalling from Brewfile...\033[0m\n"
  brew bundle --file=Brewfile
}

# Installs Node dependencies if not installed already
install_node_deps() {
  if [ -d 'node_modules' ]; then
    echo -e "\n\033[1mNode deps are installed, skipping...\033[0m\n"
  else
    echo -e "\n\033[1mInstalling Node deps for project!\033[0m\n"
    npm install
  fi
}

# Install asdf and plugins. This function checks if asdf is installed via Homebrew or manually.
install_asdf_and_plugins() {
  echo -e "\n\033[1mInstalling packages via asdf...\033[0m"
  if which brew >/dev/null 2>&1; then
    ASDF_DIR="$(brew --prefix asdf)/libexec"
  else
    ASDF_DIR="${HOME}/.asdf"
  fi

  if [ -f "$ASDF_DIR/asdf.sh" ]; then
    echo -e "\n\033[1mSourcing asdf...\033[0m"
    . "$ASDF_DIR/asdf.sh"
  else
    echo -e "\n\033[1mFailed to source asdf from $ASDF_DIR/asdf.sh. Please check the installation path.\033[0m"
    exit 1
  fi

  echo -e "\n\033[1mAdding asdf plugins...\033[0m\n"
  while IFS=' ' read -r tool _; do
    asdf plugin-add "$tool" || echo "Failed to add plugin $tool"
  done < <(sed '/^[[:blank:]]*#/d;s/#.*//' "$PROJECT_ROOT/.tool-versions")

  echo -e "\n\033[1mInstalling asdf tools...\033[0m\n"
  yes | asdf install
}

main() {
  echo -e "\n\033[1mWelcome to the Copia Automation Developer Setup for helm-charts project!\033[0m"
  echo -e "It will install Homebrew if it is not available, as it will be used for the installation of asdf and other tools."
  echo -e "This script will install and configure the ASDF version manager along with its plugins"
  echo -e "Look at the Brewfile, .tool-versions and package.json for a list of installed tools.\n"

  install_homebrew
  install_homebrew_bundle
  install_asdf_and_plugins
  install_node_deps

  echo -e "\n\033[1mIMPORTANT SETUP INSTRUCTIONS:\033[0m\n"
  echo -e "1. Ensure asdf is sourced in your shell profile:\n"
  echo -e "   Add this to ~/.bash_profile, ~/.profile, or ~/.zshrc:\n"
  echo -e "   \033[32mif [ -f $ASDF_DIR/asdf.sh ]; then\033[0m"
  echo -e "   \033[32m	export ASDF_DIR=$ASDF_DIR/\033[0m"
  echo -e "   \033[32m	. $ASDF_DIR/asdf.sh\033[0m"
  echo -e "   \033[32mfi\033[0m\n"
  echo -e "2. Source your profile:\n"
  echo -e "   \033[36msource ~/.bash_profile\033[0m (for Bash)"
  echo -e "   \033[36msource ~/.profile\033[0m (if .bash_profile is not used)"
  echo -e "   \033[36msource ~/.zshrc\033[0m (for Zsh)\n"
  echo -e "Visit \033[34mhttps://brew.sh/\033[0m and \033[34mhttps://asdf-vm.com/\033[0m for more details.\n"
}

main
