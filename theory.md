# Pipeline
Here we summarise how the network works.
## Input data
Here we provide some details to understand what input we should provide to the pipeline. Based on the framework [paper](https://arxiv.org/pdf/2103.14898.pdf).

1. Reconstruction and segmentation pipeline (refererring to TBD). The system takes system takes a sequence of RGB-D frames with associated poses as input. One of pretrained models accelssible was trained on [NYU Depth Dataset V2](https://cs.nyu.edu/~silberman/datasets/nyu_depth_v2.html), one's labeled part contains several fields:
    * `accelData` -- `Nx4` matrix of accelerometer values indicated when each frame was taken. The columns contain the `roll`, `yaw`, `pitch` and `tilt angle` of the device.
    * `depths` -- `HxWxN` matrix of in-painted depth maps where H and W are the height and width, respectively and `N` is the number of images. The values of the depth elements are in meters.
    * `images` -- `HxWx3xN` matrix of RGB images where `H` and `W` are the height and width, respectively, and `N` is the number of images.
    * `instances` -- `HxWxN` matrix of instance maps. Use get_instance_masks.m in the Toolbox to recover masks for each object instance in a scene.
    * `labels` -- `HxWxN` matrix of object label masks where `H` and `W` are the height and width, respectively and `N` is the number of images. The labels range from `1..C` where `C` is the total number of classes. If a pixel's label value is 0, then that pixel is "unlabeled".
    * `names` -- `Cx1` cell array of the english names of each class.
    * `namesToIds` -- map from english label names to class IDs (with `C` key-value pairs)
    * `rawDepths` -- `HxWxN` matrix of raw depth maps where `H` and `W` are the height and width, respectively, and `N` is the number of images. These depth maps capture the depth images after they have been projected onto the RGB image plane but before the missing depth values have been filled in. Additionally, the depth non-linearity from the Kinect device has been removed and the values of each depth image are in meters.
    * `scenes` -- `Nx1` cell array of the name of the scene from which each image was taken.
    * `sceneTypes` – `Nx1` cell array of the scene type from which each image was taken.

More could be found [here](https://github.com/xapharius/pytorch-nyuv2)

2. In [3RScan](https://github.com/WaldJohannaU/3RScan) dataset the following input is provided:
    * reconstructed `surface mesh file` (*.obj): OBJ format mesh with +Z axis in upright orientation.
    * `RGB-D sensor data` (*.zip): ZIP-archive with per-frame color, depth, camera pose and camera intrinsics.

TBD: [FAQ](https://github.com/WaldJohannaU/3RScan/blob/master/FAQ.md) review.