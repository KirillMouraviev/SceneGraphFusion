#!/bin/bash

docker run -it --privileged --net=host \
  --name scene_graph_fusion scene_graph_fusion
