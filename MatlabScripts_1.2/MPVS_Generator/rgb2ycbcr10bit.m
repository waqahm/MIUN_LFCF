% Author: Irene Viola (irene.viola@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script for RGB 444 to YCbCr 444 color space conversion
% Input: RGB image in uint16, 10-bit representation [0-1023]
%
% Please note: The correct function of this script assumes a 10-bit representation of the input RGB image
%
%
% ---------------------------------------------------------------------------------------
%

% Output: YCbCr image in uint16, 10-bit representation [0-1023] computed as specified in ITU-R BT.709-6.

function [ycbcr] = rgb2ycbcr10bit(rgb)

M = [    0.212600  0.715200  0.072200 ;
        -0.114572 -0.385428  0.500000 ;
         0.500000 -0.454153 -0.045847   ];

ycbcr = reshape(double(rgb)/1023, [], 3) * M';
ycbcr = reshape(ycbcr, size(rgb));
ycbcr(:,:,1) = 876*ycbcr(:,:,1) + 64;
ycbcr(:,:,2:3) = 896*ycbcr(:,:,2:3) + 512;
ycbcr = uint16(ycbcr);
