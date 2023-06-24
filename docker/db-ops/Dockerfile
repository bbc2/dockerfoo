FROM debian:11

# Update packages
RUN apt update \
    && apt upgrade -y \
    && apt autoremove

# Add user with password-less sudo
ARG user=main
RUN useradd --create-home "$user" \
    && apt-get update \
    && apt-get install -y sudo \
    && echo "$user" ALL=\(root\) NOPASSWD:ALL > "/etc/sudoers.d/$user" \
    && chmod 0440 "/etc/sudoers.d/$user"
ENV PATH /home/$user/.local/bin:$PATH
USER "$user"

# Set up persistent Bash history
ARG HISTORY=/home/$user/history
VOLUME /home/$user/history
RUN mkdir "$HISTORY" \
    && chown -R "$user:" "$HISTORY"
ENV HISTFILE "$HISTORY/bash"

# Install `psql`
USER root
RUN apt install -y postgresql-client
USER "$user"

ENV PSQL_HISTORY /home/$user/history/psql
