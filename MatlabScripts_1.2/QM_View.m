% Author :  Hadi Amirpour
% email  :  hadi.amirpour@gmail.com
% Copyright(c) EmergIMG,
%              Universidade da Beira Interior
% inputs :
%ref   = reference image,
%rec   = reconstructed image,
%n_rgb = number of the bits for RGB inputs, this number should be either 8 or 10.
%n_yuv = number of bits for YUVs, this number is the same as n_rgb
% outputs:
%Y_PSNR
%YUV_PSNR
%Y_SSIM

function [Y_PSNR YUV_PSNR Y_SSIM]=QM(ref,rec,n_rgb,n_yuv)

%convert rgb to double
ref_double = double(ref)./(2^n_rgb-1);
rec_double = double(rec)./(2^n_rgb-1);
% 
% figure,imagesc(ref_double)
% figure,imagesc(rec_double)

%convert double rgb images to n_yuv bits ycbcr (4:4:4)
ref_YCbCr_444=rgb2ycbcrn(ref_double,n_yuv);
rec_YCbCr_444=rgb2ycbcrn(rec_double,n_yuv);

Y1 = ref_YCbCr_444(:,:,1);
U1 = ref_YCbCr_444(:,:,2);
V1 = ref_YCbCr_444(:,:,3);

Y2 = rec_YCbCr_444(:,:,1);
U2 = rec_YCbCr_444(:,:,2);
V2 = rec_YCbCr_444(:,:,3);

% Objective metrics
Y_MSE=immse(Y1,Y2);
U_MSE=immse(U1,U2);
V_MSE=immse(V1,V2);

Y_PSNR   = 10*log10((2^n_yuv-1)*(2^n_yuv-1)/Y_MSE);
U_PSNR   = 10*log10((2^n_yuv-1)*(2^n_yuv-1)/U_MSE);
V_PSNR   = 10*log10((2^n_yuv-1)*(2^n_yuv-1)/V_MSE);

YUV_PSNR = (6*Y_PSNR+U_PSNR+V_PSNR)/8;

Y_SSIM = ssim(double(Y1)./(2^n_yuv-1),double(Y2)./(2^n_yuv-1));
end
