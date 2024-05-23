import pickle
import torch
from pycvvdp.display_model import pq2lin, lin2pq, vvdp_display_photo_eotf
from pycvvdp import video_source_video_file
from yuv_utils import YUVWriter


'''
This code reads a BT.2020-PQ Video, account for the display luminance, apply the display LUT model, 
and save the video as a YUV file
'''

'''
This code is using the ColorVideoVDP framework for reading the HDR video. 
The installation instruction can be found in: https://github.com/gfxdisp/ColorVideoVDP

as well as the torch_implementation framework to load and run the lut model
'''


'''
We are using the test/Bistro/Bistro_L_1920x1080.mp4
You can find the video in the HDR-VDC dataset provided in https://doi.org/10.17863/CAM.107964
'''


# Define the display luminance, can be either bright or dim
display_luminance = 'bright'

# Define the torch device
if torch.cuda.is_available() and torch.cuda.device_count() > 0:
    device = torch.device('cuda:0')

# Import the LUT model
lut_model_path = 'pq_lut_model.pck'
filehandler = open(lut_model_path, 'rb')
lut_model = pickle.load(filehandler)
filehandler.close()

lut_model.to_device(device)

# Open the test video
display_photometry = vvdp_display_photo_eotf(Y_peak=10000, contrast=1000000, source_colorspace='BT.2020-PQ', EOTF='PQ', E_ambient=0)
vid_source = video_source_video_file('Bistro_L_1920x1080.mp4', 'Bistro_L_1920x1080.mp4', frames=-1, display_photometry=display_photometry)
w, h, N_frames = vid_source.get_video_size()

# Define the properties of the YUV file
vprops = dict()
vprops["width"] = w
vprops["height"] = h
vprops["fps"] = vid_source.get_frames_per_second()
vprops["bit_depth"] = 10
vprops["color_space"] = '2020'
vprops["chroma_ss"] = '420'

# Open the YUV file

with YUVWriter('Bistro_L_1920x1080_'+display_luminance, vprops) as vw:
    for ff in range(N_frames):

        # We get the frame in Linear RGB BT.2020, in C, H, W format.
        R = vid_source.get_reference_frame(ff, device=device, colorspace='RGB2020').squeeze()

        # Accounting for the display luminance level
        # If the display is bright the luminance factor is 1, if the display is dim the luminance factor is 1/8

        if display_luminance == 'bright':
            luminance_factor = 1
        else:
            luminance_factor = 1/8

        R *= luminance_factor

        # The LUT model is applied on PQ-encoded values
        R = lin2pq(R)

        # Apply the display model (LUT model)

        R = lut_model([R[0], R[1], R[2]]) # The output is in H, W, C format

        # Ensure that the values are still between 0 and 1

        R = R.clamp(min=0, max=1)

        # The results are now written in the YUV file
        vw.append_frame_rgb(R.cpu().numpy())

'''
To visualize the video you can use ffmpeg to encode.
A simple CLI:
ffmpeg -f rawvideo -pix_fmt yuv420p10le -s:v 1920x1080 -r 24 -colorspace bt2020nc -color_trc smpte2084 -color_primaries bt2020 -n -i Bistro_L_1920x1080_bright_1080x1920_420_2020_10b.yuv -c:v libx264 -crf 0 Bistro_L_1920x1080_bright.mp4
'''