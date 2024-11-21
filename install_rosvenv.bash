#!/bin/bash

DEPLOY_BRANCH=main
DEPLOY_REPO=https://github.com/apl-ocean-engineering/rosvenv
ROSVENV_ROOT="${HOME}/.rosvenv"

# If rosvenv isn't already installed and sourced
if [ "$( type -t createROSWS )" != "function" ]; then
	git clone --depth 1 -b $DEPLOY_BRANCH $DEPLOY_REPO $ROSVENV_ROOT

	printf "\n# ROSVENV\nsource ${ROSVENV_ROOT}/rosvenv.bash\nsource ${ROSVENV_ROOT}/rosvenv_docker.bash\n" >> "${HOME}/.bashrc"
	echo "export ROSVENV_ROOT=$ROSVENV_ROOT" >> "${HOME}/.bashrc"
fi

source "${ROSVENV_ROOT}/rosvenv.bash"
source "${ROSVENV_ROOT}/rosvenv_docker.bash"

if ! _rosvenv_precheck; then
	if rosvenv_has_docker; then
		echo "You do not seem to have ROS installed, but docker."

		if rosvenv_docker_image_exists $ROSVENV_DEFAULT_DOCKER_IMAGE; then
			read -p "The ROSVENV image is already present. Do you want to rebuild it? [y/n]: " confirm
		else
			read -p "Do you want to use ROSVENV in docker? [y/n]: " confirm
		fi

		if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
			rosvenv_docker_build_container
		else
			echo "Okay, you can (re-)build the container at a later time."
		fi
	else
		echo "You have neither ROS nor docker installed. You will not be able to run ROS."
	fi
fi

echo "ROSVENV should now be usable!"
