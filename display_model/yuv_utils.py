import numpy as np
import os.path
import re
import scipy.signal as ss


def convert444to420(comp, bit_depth):
    horfilter = np.array([[1, 6, 1]], dtype=comp.dtype)
    verfilter = np.array([[0, 1, 1]], dtype=comp.dtype).transpose()
    compF = ss.convolve2d(comp, horfilter, mode='same', boundary='symm')
    compF = compF[:,0::2]
    compF = ss.convolve2d(compF, verfilter, mode='same', boundary='symm')
    compF = compF[0::2,:]
    maxV = 2**bit_depth-1
    compF = np.right_shift(compF+8,4).clip(0,maxV)
    return compF


def float2fixed(YCbCr,nbit):

    offset = (2**(nbit-8))*16
    weight = (2**(nbit-8))*219
    max_lum = (2**nbit)-1

    if nbit<=8:
        dtype = np.uint8
    else:
        dtype = np.uint16
    
    Y = np.round(weight*YCbCr[:,:,0]+offset).clip(0,max_lum).astype(dtype)
    
    offset = (2**(nbit-8)) * 128
    weight = (2**(nbit-8)) * 224  
    
    U = np.round(weight*YCbCr[:,:,1]+offset).clip(0,max_lum).astype(dtype)
    V = np.round(weight*YCbCr[:,:,2]+offset).clip(0,max_lum).astype(dtype)
  
    return np.concatenate(  (Y[:,:,np.newaxis], U[:,:,np.newaxis], V[:,:,np.newaxis]), axis=2 )
 

_rgb2ycbcr_rec2020 = np.array([[0.262699236013774, 0.678001738734420, 0.059299025251807],\
  [-0.139629656645994, -0.360370861451270,  0.500000518097265],\
  [0.500000518097265,  -0.459786883720616,  -0.040213634376649]], dtype=np.float32)

_rgb2ycbcr_rec709 = np.array([[0.2126 , 0.7152 , 0.0722],\
        [-0.114572 , -0.385428 , 0.5],\
        [0.5 , -0.454153 , -0.045847]], dtype=np.float32)


class YUVWriter:

    def __init__(self, base_name, vprops):        
        self.base_name = base_name
        self.vprops = vprops
        self.fname = "{bname}_{width}x{height}_{subsampling}_{colorspace}_{bitdepth}b.yuv".format( \
            bname=base_name,\
            width=vprops["width"], height=vprops["height"], \
            subsampling=vprops["chroma_ss"], \
            colorspace=vprops["color_space"], \
            bitdepth=vprops["bit_depth"])
        
        self.pix_count = vprops["width"]*vprops["height"]
        self.bit_depth = vprops["bit_depth"]
        self.fh = open( self.fname, "w")

    def __enter__(self):
        return self

    def __exit__(self, type, value, tb):
        self.fh.close()

    def append_frame_rgb( self, RGB ):

        col_mat = _rgb2ycbcr_rec2020 if self.vprops["color_space"]=='2020' else _rgb2ycbcr_rec709

        YUV = (np.reshape( RGB, (self.pix_count, 3), order='F' ) @ col_mat.transpose()).reshape( (RGB.shape), order='F' )

        YUV_fixed = float2fixed( YUV, self.bit_depth )

        Y = YUV_fixed[:,:,0]
        if self.vprops["chroma_ss"] == '444':
            u = YUV_fixed[:,:,1]
            v = YUV_fixed[:,:,2]
        elif self.vprops["chroma_ss"] == '420':
            u = convert444to420(YUV_fixed[:,:,1], self.bit_depth)
            v = convert444to420(YUV_fixed[:,:,2], self.bit_depth)
        else:
            raise RuntimeError( 'Not implemented' )

        Y.tofile(self.fh)
        u.tofile(self.fh)
        v.tofile(self.fh)

    '''
    Depreciated. Use `append_frame_rgb` instead. 
    '''
    def append_frame_rgb_rec2020( self, RGB ):

        YUV = (np.reshape( RGB, (self.pix_count, 3), order='F' ) @ _rgb2ycbcr_rec2020.transpose()).reshape( (RGB.shape), order='F' )

        YUV_fixed = float2fixed( YUV, self.bit_depth )

        Y = YUV_fixed[:,:,0]
        u = convert444to420(YUV_fixed[:,:,1], self.bit_depth)
        v = convert444to420(YUV_fixed[:,:,2], self.bit_depth)

        Y.tofile(self.fh)
        u.tofile(self.fh)
        v.tofile(self.fh)

