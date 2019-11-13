FROM python:buster

RUN apt-get update && apt-get install -y doxygen
RUN pip install --upgrade pip sphinx sphinxcontrib-bibtex sphinx-rtd-theme

ENV MPC_HOME /usr/src/SCALE-MAMBA
WORKDIR $MPC_HOME
