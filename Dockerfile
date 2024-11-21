FROM osrf/ros:noetic-desktop-full

# For consistency with later (jazzy, rolling) ROS images which are based on
# "noble", use "ubuntu"
ARG USER_NAME=ubuntu 
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Adding typical tools we need or like to have
RUN apt-get update \
    && apt-get install -q -y --no-install-recommends \
        git \
        python3-catkin-tools \
        python3-venv \
        ros-noetic-catkin \
        sudo \
        vim \
        wget 

# Needs to be removed because of the way ROSVENV works
ENV ROS_DISTRO=""

COPY ./entrypoint.sh /ros_entrypoint.sh

RUN  groupadd --gid ${USER_GID} ${USER_NAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} \ 
            -G sudo ${USER_NAME} \
    && echo %sudo ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/nopasswd \
    && chmod 0440 /etc/sudoers.d/nopasswd

# Install fixuid
RUN wget -O - https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${USER_NAME}\ngroup: ${USER_NAME}\n" > /etc/fixuid/config.yml

# Start in your home dir
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

ENTRYPOINT ["fixuid"]
