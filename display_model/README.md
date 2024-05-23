# Display LUT Model

The video files in the HDR-VDC dataset are encoded using the PQ transfer function and can span a very large dynamic range.
The videos were presented in the experiment on a pair of LG OLED G2 displays, which can have a limited peak luminance and 
color gamut.
Therefore, in order to correctly simulate the light emitted from the display during the experiment, we provided the
display LUT model in [`display_model/pq_lut_model.pck`](https://github.com/gfxdisp/HDR-VDC/blob/main/display_model/pq_lut_model.pck).
The model expects as an input BT.2020-PQ images and provides the BT.2020-PQ images as perceived from the display. 

The LUT model employs the grid interpolation framework proposed in https://github.com/sbarratt/torch_interpolations.
We provide the framework within this folder since we have added some small modifications to it, to facilitate its integration in our code.

The folder contains the following files:

* [`pq_lut_model.pck`](https://github.com/gfxdisp/HDR-VDC/blob/main/display_model/pq_lut_model.pck): The display LUT model.
* [`example.py`](https://github.com/gfxdisp/HDR-VDC/blob/main/display_model/example.py): An example code that uses the LUT model to simulate the display on the Bistro_L_1920x1080.mp4 BT.2020-PQ video (You can find the video in the HDR-VDC dataset). The code also simulates the display luminance levels. 
* [`yuv_utils.py`](https://github.com/gfxdisp/HDR-VDC/blob/main/display_model/yuv_utils.py): Utils file to save the frames in a YUV file. 

The [`example.py`](https://github.com/gfxdisp/HDR-VDC/blob/main/display_model/example.py) code requires the installation of:
* Pytorch: Please find the installation instructions at https://pytorch.org/.
* ColorVideoVDP: Please find the installation instructions at https://github.com/gfxdisp/ColorVideoVDP/.
* torch_interpolations: The installation instructions: 
```commandline
cd torch_interpolations
pip install -e .
```
