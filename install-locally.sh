#!/bin/bash

set -euo pipefail

# The directory which will be created, below the user's home
# directory, and in which all the repos will be checked out
DIR='tax-tribunals'

REPOS="
  tax-tribunals-docker-compose
  tax-tribunals-datacapture
  glimr-emulator
  mojfile-uploader-emulator
"

DOCKER_COMPOSE_FILE='docker-compose-with-emulators.yml'

main() {
  install_prerequisites
  create_directory_and_cd
  clone_or_update_code
  setup_dotenv_for_datacapture
  start_containers
  open_in_browser
  create_user_scripts
  finish_off
}

create_directory_and_cd() {
  cd
  mkdir ${DIR} 2>/dev/null || true
  cd ${DIR}
}

clone_or_update_code() {
  for repo in ${REPOS}; do
    clone_or_update_repo "${repo}"
  done
}

clone_or_update_repo() {
  local readonly repo=$1
  if [ ! -d "${repo}" ]; then
    echo "##################################################"
    echo "Checking out ${repo}"
    git clone https://github.com/ministryofjustice/${repo}.git
    echo "##################################################"
    echo
  else
    echo "##################################################"
    echo "Updating ${repo}"
    (
      cd ./${repo}
      git fetch
      git pull
    )
    echo "##################################################"
    echo
  fi
}

setup_dotenv_for_datacapture() {
  if [ ! -f "tax-tribunals-docker-compose/.env.datacapture.emulators" ]; then
    echo "##################################################"
    echo 'Setting up datacapture environment'
    (
      cd tax-tribunals-docker-compose
      cp env.datacapture.emulators.example .env.datacapture.emulators
      echo "##################################################"
      echo
    )
  fi
}

start_containers() {
  stop_currently_running_containers
  start_new_containers
  run_imports_and_build_assets
}

stop_currently_running_containers() {
  echo
  echo "##################################################"
  echo 'Stopping currently running versions'
  (
    cd tax-tribunals-docker-compose
    docker-compose --file ${DOCKER_COMPOSE_FILE} down
  )
  echo "##################################################"
  echo
}

start_new_containers() {
  echo "##################################################"
  echo 'Starting new containers'
  (
    cd tax-tribunals-docker-compose
    docker-compose --file ${DOCKER_COMPOSE_FILE} up --build -d
  )
  echo "##################################################"
  echo
}

run_imports_and_build_assets() {
  echo "##################################################"
  echo 'Running final setup tasks'
  (
    cd tax-tribunals-docker-compose
    sleep 10
    docker-compose --file ${DOCKER_COMPOSE_FILE} exec datacapture rails db:setup
    docker-compose --file ${DOCKER_COMPOSE_FILE} exec datacapture rails assets:clobber
    docker-compose --file ${DOCKER_COMPOSE_FILE} exec datacapture rails assets:precompile
  )
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

create_user_scripts() {
  (
    cd
    cd ${DIR}
    cat > start.sh <<EOF
#!/bin/bash
for repo in ${REPOS}; do
  (
    cd "\${repo}"; git pull
  )
done
(
  cd tax-tribunals-docker-compose
  docker-compose --file ${DOCKER_COMPOSE_FILE} start
)
EOF
    chmod 755 start.sh
  )
}

finish_off() {
  echo
  echo "##################################################"
  echo "##################################################"
  echo 'Finished.'
  echo 'To stop the app run the following commands'
  echo 'cd tax-tribunals-docker-compose'
  echo "docker-compose --file ${DOCKER_COMPOSE_FILE} stop"
  echo "##################################################"
  echo "##################################################"
echo
}

install_prerequisites() {
  install_homebrew
  install_docker
  install_git
}

install_homebrew() {
  echo "##################################################"
  echo "Installing homebrew"
  # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "##################################################"
  echo
}

install_docker() {
  docker=`which -s docker`

  if [[ $docker == 0  ]] ; then
    echo "##################################################"
    echo 'Installing docker'
    # brew cask install docker
    echo "##################################################"
    echo
  fi
}

install_git() {
  git=`which -s git`

  if [[ $git == 0  ]] ; then
    echo "##################################################"
    echo 'Installing git'
    # brew install git
    echo "##################################################"
    echo
  fi
}

main
