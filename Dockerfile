FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV LANG C.UTF-8

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub 
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    build-essential \
    ffmpeg \
    libassimp-dev \
    freeglut3-dev \
    libglfw3-dev \
    python-opengl \
    g++ \
    htop \
    curl \
    git \
    tar \
    python3-pip \
    python3-numpy \
    python3-scipy \
    net-tools \
    nano \
    unzip \
    vim \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH /usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \
            python3.8-venv \
            python3.8-dev 

ENV VIRTUAL_ENV=venv
RUN python3.8 -m venv /opt/$VIRTUAL_ENV
ENV PATH /opt/$VIRTUAL_ENV/bin:$PATH

WORKDIR /home/workdir
COPY . .
#network part
#####################################
RUN pip install torch==1.8.1+cu102 -f https://download.pytorch.org/whl/torch_stable.html open3d tensorboard trimesh cmake Cython
RUN pip install torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-1.8.1+cu102.html 

#data part
#####################################
RUN git clone https://github.com/WaldJohannaU/3RScan.git
RUN cd 3RSan; bash setup.sh; cd ..

RUN git clone https://github.com/ShunChengWu/3DSSG.git
RUN cd 3DSSG/files; bash preparation.sh; cd ../..

####onnx part
# RUN git clone https://github.com/microsoft/onnxruntime 
# RUN cd onnxruntime ./build.sh --config RelWithDebInfo --build_shared_lib --parallel
# RUN cd build/Linux/RelWithDebInfo; make install; cd ../..

#build part
#####################################
# RUN cd SceneGraphFusion; \
#     git submodule update --init; \
#     mkdir build; \
#     cd build; \
#     cmake ..; \
#     make
