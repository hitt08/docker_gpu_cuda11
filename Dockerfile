FROM nvidia/cuda:11.2.0-cudnn8-runtime-ubuntu20.04

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata


RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    build-essential \
    curl \ 
    zip unzip\
    openjdk-8-jre \
    git-lfs \
    vim \
    software-properties-common \
    locales

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN locale-gen en_US.UTF-8
ENV LANGUAGE en_US:en
ENV PATH="/root/miniconda/bin:${PATH}"
ARG PATH="/root/miniconda/bin:${PATH}"
    
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh -o /tmp/Miniconda3-py38_4.12.0-Linux-x86_64.sh && \
	bash /tmp/Miniconda3-py38_4.12.0-Linux-x86_64.sh -b -p $HOME/miniconda && rm /tmp/Miniconda3-py38_4.12.0-Linux-x86_64.sh

RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y --no-install-recommends python3-venv python3-pip gcc python3-dev
RUN apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /app/nltk_data/ /app/neuralcoref/
ENV NLTK_DATA=/app/nltk_data/
ENV NEURALCOREF_CACHE=/app/neuralcoref/
RUN pip3 install -U pip setuptools wheel && pip3 install jupyter -U && pip3 install jupyterlab


COPY requirements_basic.txt /tmp
COPY requirements_extended.txt /tmp
COPY neuralcoref /root/miniconda/lib/python3.8/dist-packages/neuralcoref
RUN pip3 install --no-cache-dir -r /tmp/requirements_basic.txt && \
  	conda install pytorch cudatoolkit=11.3 -c pytorch && \
  	pip3 install --no-cache-dir -r /tmp/requirements_extended.txt && \
	giveme5w1h-corenlp install && \
	cd /root/miniconda/lib/python3.8/dist-packages/neuralcoref && pip3 install -r requirements.txt && pip3 install -e .

RUN python3 -m spacy download en_core_web_sm && \
	python3 -c "import benepar; benepar.download('benepar_en3')" && \
	python3 -c "import nltk; nltk.download('wordnet','/app/nltk_data'); nltk.download('stopwords','/app/nltk_data')"
COPY neuralcoref_cache /app/neuralcoref

RUN mkdir /app/SourceSets ; mkdir /app/DocumentSets ; mkdir /app/DocumentSets/ccd ; mkdir /app/DocumentSets/json   ; mkdir /app/sourceCode ; mkdir /app/transformer_models; mkdir /app/DocumentSets/hac-5w1h; mkdir -p /app/DocumentSets/dpp/mat; mkdir -p  /root/miniconda/lib/python3.8/dist-packages/Giveme5W1H/examples/caches/

ENV TOKENIZERS_PARALLELISM=false

WORKDIR /app
RUN cd /app
