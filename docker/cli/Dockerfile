FROM python:3.11 AS base

# Update packages
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get autoremove

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

# Install Python
USER root
RUN apt-get install -y \
        python3-pip \
        python3-venv
USER "$user"

WORKDIR "/home/$user"

# Set up Python environment
ARG venv_path="/home/$user/venv"
RUN pip install --user --upgrade setuptools pip \
    && pip install --user --upgrade poetry \
    && python3 -m venv "$venv_path"
         
ENV VIRTUAL_ENV "$venv_path"
ENV PATH "$venv_path/bin:$PATH"

RUN mkdir app
WORKDIR app

# Install production Python dependencies
COPY --chown="$user:$user" pyproject.toml poetry.lock .
RUN poetry install --only main --no-root

FROM base as dev

# Add the script to the PATH before executing Bash.
ENTRYPOINT \
    poetry install --only-root \
    && bash

FROM base as prod

COPY --chown="$user:$user" . .
RUN poetry install --only-root

ENTRYPOINT []
CMD ["bash"]

FROM base AS test

RUN poetry install --no-root

COPY --chown="$user:$user" . .
RUN poetry install --only-root

ENTRYPOINT []
CMD ["bash"]
