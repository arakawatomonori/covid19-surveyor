FROM jupyter/scipy-notebook:latest

ADD setup.py /app/
ADD notebooks /app/notebooks

USER root
RUN apt-get update && \
  apt-get install -y \
    git \
    build-essential \
    curl \
    mecab \
    libmecab-dev \
    --no-install-recommends && \
  apt-get clean

USER $NB_UID
RUN pip install /app
