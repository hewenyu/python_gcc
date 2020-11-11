# [Choice] Python version: 3, 3.9, 3.8, 3.7, 3.6
ARG VARIANT=3
FROM python:${VARIANT}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY .devcontainer/library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install common packages, non-root user
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Setup default python tools in a venv via pipx to avoid conflicts
ENV PIPX_HOME=/usr/local/py-utils \
    PIPX_BIN_DIR=/usr/local/py-utils/bin
ENV PATH=${PATH}:${PIPX_BIN_DIR}
COPY .devcontainer/library-scripts/python-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/python-debian.sh "none" "/usr/local" "${PIPX_HOME}" "${USERNAME}" "false" \ 
    && apt-get clean -y && rm -rf /tmp/library-scripts


# oracle支持
COPY instantclient-basic-linux.x64-12.2.0.1.0.zip /tmp/


RUN cd  /tmp/ && unzip instantclient-basic-linux.x64-12.2.0.1.0.zip  -d  /opt/oracle/ && \
    rm /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip && \
    cd /opt/oracle/instantclient_12_2 && \
    ln -s libclntsh.so.12.1 libclntsh.so && \
    ln -s libocci.so.12.1 libocci.so && \
    sh -c "echo /opt/oracle/instantclient_12_2 >  /etc/ld.so.conf.d/oracle-instantclient.conf" && \
    ldconfig

# ENV ORACLE_BASE /opt/oracle/instantclient_12_2
ENV LD_LIBRARY_PATH /opt/oracle/instantclient_12_2
# ENV TNS_ADMIN /opt/oracle/instantclient_12_2
# ENV ORACLE_HOME /opt/oracle/instantclient_12_2