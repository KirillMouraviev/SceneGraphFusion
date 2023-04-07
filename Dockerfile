FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04

ARG ssh_prv_key
ARG ssh_pub_key

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV LANG C.UTF-8

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub 
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    build-essential \
    openssh-server openssh-client\
    ffmpeg \
    libassimp-dev \
    freeglut3-dev \
    libglfw3-dev \
    python-opengl \
    g++ \
    htop \
    curl \
    locales \
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
    libeigen3-dev \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- "https://cmake.org/files/v3.14/cmake-3.14.1-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local
RUN locale-gen en_US.UTF-8
RUN --mount=type=ssh mkdir -p -m 0600 ~/.ssh && \
                     ssh-keyscan github.com >> ~/.ssh/known_hosts

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
RUN pip install torch==1.8.1+cu102 -f https://download.pytorch.org/whl/torch_stable.html numpy open3d tensorboard trimesh cmake Cython
RUN pip install torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-1.8.1+cu102.html 

#data part
#####################################
# RUN git clone https://github.com/WaldJohannaU/3RScan.git
# RUN cd 3RSan; bash setup.sh; cd ..

RUN git clone https://github.com/ShunChengWu/3DSSG.git
RUN cd 3DSSG/files; bash preparation.sh; cd ../..

####onnx part
RUN git clone --recursive --branch v1.8.2 https://github.com/microsoft/onnxruntime 
RUN cd onnxruntime; ./build.sh --config RelWithDebInfo --build_shared_lib --parallel
RUN cd build/Linux/RelWithDebInfo; make install; cd ../../../..


#build part
#####################################
RUN ln -s /usr/include/eigen3/Eigen /usr/include/Eigen
RUN --mount=type=ssh cd SceneGraphFusion; \
    git  submodule init && \
    git submodule update &&\
    mkdir build && \
    cd build && \
    cmake -DBUILD_GUI=ON -DBUILD_GRAPHPRED=ON .. && \
    make
RUN rm -rf /root/.ssh/
