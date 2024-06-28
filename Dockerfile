FROM jupyter/base-notebook:x86_64-ubuntu-22.04

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

WORKDIR ${HOME}

USER root

RUN apt-get update
RUN apt-get install -y curl

ENV \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # Opt out of telemetry until after we install jupyter when building the image, this prevents caching of machine id
    DOTNET_INTERACTIVE_CLI_TELEMETRY_OPTOUT=true

# Install .NET CLI dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dotnet-sdk-8.0

USER $NB_USER

RUN  dotnet tool install -g Microsoft.dotnet-interactive
ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN  dotnet interactive jupyter install

RUN mkdir -p temp
WORKDIR ${HOME}/temp

RUN dotnet new console 
RUN dotnet add package QuantLib --version 1.34.0

WORKDIR $HOME

COPY *.ipynb $HOME/

WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

