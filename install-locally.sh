#!/bin/bash

set -euo pipefail

docker=`which -s docker`
git=`which -s git`

# The directory which will be created, below the user's home
# directory, and in which all the repos will be checked out
DIR='tax-tribunals'

main() {
  install_homebrew
  install_docker
  install_git
  create_directory_and_cd
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

create_directory_and_cd() {
  cd
  mkdir ${DIR} 2>/dev/null || true
  cd ${DIR}
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
    git clone https://github.com/ministryofjustice/tax-tribunals-docker-compose.git
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
    git clone https://github.com/ministryofjustice/tax-tribunals-datacapture.git
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
    git clone https://github.com/ministryofjustice/glimr-emulator.git
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
    git clone https://github.com/ministryofjustice/mojfile-uploader-emulator.git
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
