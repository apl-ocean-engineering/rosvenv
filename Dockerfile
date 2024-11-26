FROM osrf/ros:noetic-desktop-full

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

COPY --chmod=0755 ./entrypoint.sh /ros_entrypoint.sh

# Later (jazzy, rolling) ROS images are based on "noble"
# "noble" images contain a built-in user "ubuntu" as uid 1000
# so we use that name as well
#
# Note the sudoers file calls out "all members of group sudo"
# so it works even if ubuntu's UID changes
ARG USER_NAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USER_NAME} && \
    useradd  --gid ${USER_GID} --uid ${USER_UID} \
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
