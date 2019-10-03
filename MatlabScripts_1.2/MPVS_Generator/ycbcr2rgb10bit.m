% Author: Irene Viola (irene.viola@epfl.ch)
% Copyright(c) Multimedia Signal Processing Group (MMSPG),
%              Ecole Polytechnique Federale de Lausanne (EPFL)
%              http://mmspg.epfl.ch
% All rights reserved.

% script for RGB 444 to YCbCr 444 color space conversion
% Input: YCbCr image in uint16, 10-bit representation [0-1023]
%
% Please note: The correct function of this script assumes a 10-bit representation of the input YCbCr image
%
% ---------------------------------------------------------------------------------------
%

% Output: RBG image in uint16, 10-bit representation [0-1023] computed as specified in ITU-R BT.709-6.
function [rgb] = ycbcr2rgb10bit(ycbcr)

ycbcr = double(ycbcr);

ycbcr(:,:,1) = (ycbcr(:,:,1) - 64) *(1023/ 876);
ycbcr(:,:,2:3) = (ycbcr(:,:,2:3) - 512)*(1023 / 896);

M = [   1  0        1.57480 ;
        1 -0.18733 -0.46813 ;
        1  1.85563  0           ];

rgb = reshape(ycbcr, [], 3) * M';
rgb = reshape(rgb, size(ycbcr));
rgb = uint16(clip(rgb, 0,1023));
end

function [out] = clip(in, min, max)
    out = in;
    out(in < min) = min;
    out(in > max) = max;
end