#!/bin/bash

set -euo pipefail

docker=`which -s docker`
git=`which -s git`

datacapture_repo="https://github.com/ministryofjustice/tax-tribunals-datacapture.git"
docker_compose_repo="https://github.com/ministryofjustice/tax-tribunals-docker-compose.git"
glimr_emulator="https://github.com/ministryofjustice/glimr-emulator.git"
uploader_emulator="https://github.com/ministryofjustice/mojfile-uploader-emulator.git"

main() {
  check_if_dependencies_required
  git_use_ssh_or_https
  clone_tax_tribunals_docker_compose
  setup_dotenv_for_datacapture
  clone_tax_tribunals_datacapture
  clone_glimr_emulator
  clone_mojfile_uploader_emulator
  stop_currently_running_containers
  start_new_containers
  run_imports_and_build_assets
  open_in_browser
  finish_off
}

check_if_dependencies_required() {
  echo "#####################################################"
  echo "You should only need to choose 'y' the first time you"
  echo "run this script."
  echo "#####################################################"
  echo
  read -p "Install homebrew, docker and git (y/n)? " answer
  case ${answer:0:1} in
    y|Y )
      install_homebrew
      install_docker
      install_git
      ;;
    * )
      echo "##################################################"
      echo "Skipping homebrew, docker and git."
      echo "##################################################"
      echo
      ;;
  esac
}

git_use_ssh_or_https() {
  echo "#####################################################"
  echo "Use SSH if you have a valid MoJ github account and"
  echo "want to be able to send PRs to the various projects."
  echo "If you don't know what this means, choose 'n'."
  echo "#####################################################"
  echo
  read -p "Use ssh for git repos (y/n)? " answer
  case ${answer:0:1} in
    y|Y )
      echo "##################################################"
      echo "Using ssh for github repos."
      echo "##################################################"
      echo
      datacapture_repo="git@github.com:ministryofjustice/tax-tribunals-datacapture.git"
      docker_compose_repo="git@github.com:ministryofjustice/tax-tribunals-docker-compose.git"
      glimr_emulator="git@github.com:ministryofjustice/glimr-emulator.git"
      uploader_emulator="git@github.com:ministryofjustice/mojfile-uploader-emulator.git"
      ;;
    * )
      echo "##################################################"
      echo "Using https for github repos."
      echo "##################################################"
      echo
      ;;
  esac
}

install_homebrew() {
  echo "##################################################"
  echo "Installing homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "##################################################"
  echo
}

install_docker() {
  if [[ $docker == 0  ]] ; then
    echo "##################################################"
    echo 'Installing docker'
    brew cask install docker
    echo "##################################################"
    echo
  fi
}

install_git() {
  if [[ $git == 0  ]] ; then
    echo "##################################################"
    echo 'Installing git'
    brew install git
    echo "##################################################"
    echo
  fi
}

clone_tax_tribunals_docker_compose() {
  if [ ! -d "tax-tribunals-docker-compose" ]; then
    echo "##################################################"
    echo 'Checking out tax-tribunals-docker-compose'
    git clone $docker_compose_repo
    echo "##################################################"
    echo
  else
    echo "##################################################"
    echo 'Updating tax-tribunals-docker-compose'
    cd ./tax-tribunals-docker-compose
    git fetch
    git pull
    cd ..
    echo "##################################################"
    echo
  fi
}

setup_dotenv_for_datacapture() {
  if [ ! -f "tax-tribunals-docker-compose/.env.datacapture.emulators" ]; then
    echo "##################################################"
    echo 'Setting up datacapture environment'
    cd tax-tribunals-docker-compose
    cp env.datacapture.emulators.example .env.datacapture.emulators
    echo "##################################################"
    echo
    cd ..
  fi
}

clone_tax_tribunals_datacapture() {
  if [ ! -d "tax-tribunals-datacapture" ]; then
    echo "##################################################"
    echo 'Checking out tax-tribunals-datacapture'
    git clone $datacapture_repo
    echo "##################################################"
    echo
  else
    echo "##################################################"
    echo 'Updating tax-tribunals-datacapture'
    cd ./tax-tribunals-datacapture
    git fetch
    git pull
    cd ..
    echo "##################################################"
    echo
  fi
}

clone_glimr_emulator() {
  if [ ! -d "glimr-emulator" ]; then
    echo "##################################################"
    echo 'Checking out glimr-emulator'
    git clone $glimr_emulator
    echo "##################################################"
    echo
  else
    echo "##################################################"
    echo 'Updating glimr-emulator'
    cd ./glimr-emulator
    git fetch
    git pull
    cd ..
    echo "##################################################"
    echo
  fi
}

clone_mojfile_uploader_emulator() {
  if [ ! -d "mojfile-uploader-emulator" ]; then
    echo "##################################################"
    echo 'Checking out mojfile-uploader-emulator'
    git clone $uploader_emulator
    echo "##################################################"
    echo
  else
    echo "##################################################"
    echo 'Updating mojfile-uploader-emulator'
    cd ./mojfile-uploader-emulator
    git fetch
    git pull
    cd ..
    echo "##################################################"
    echo
  fi
}

stop_currently_running_containers() {
  echo
  echo "##################################################"
  echo 'Stopping currently running versions'
  cd tax-tribunals-docker-compose
  docker-compose --file docker-compose-with-emulators.yml down
  echo "##################################################"
  echo
}

start_new_containers() {
  echo "##################################################"
  echo 'Starting new containers'
  docker-compose --file docker-compose-with-emulators.yml up --build -d
  echo "##################################################"
  echo
}

run_imports_and_build_assets() {
  echo "##################################################"
  echo 'Running final setup tasks'
  sleep 10
  docker-compose --file docker-compose-with-emulators.yml exec datacapture rails db:setup
  docker-compose --file docker-compose-with-emulators.yml exec datacapture rails assets:clobber
  docker-compose --file docker-compose-with-emulators.yml exec datacapture rails assets:precompile
  echo "##################################################"
  echo
}

open_in_browser() {
  echo "##################################################"
  echo 'Opening in browser'
  open "http://localhost:3000"
  echo "##################################################"
  echo
}

finish_off() {
  echo
  echo "##################################################"
  echo "##################################################"
  echo 'Finished.'
  echo 'To stop the app run the following commands'
  echo 'cd tax-tribunals-docker-compose'
  echo 'docker-compose --file docker-compose-with-emulators.yml stop'
  echo "##################################################"
  echo "##################################################"
  echo
}

main
