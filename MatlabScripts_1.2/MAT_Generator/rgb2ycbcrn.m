% Author :  Hadi Amirpour 
% email  :  hadi.amirpour@gmail.com
% Copyright(c) EmergIMG,
%              Universidade da Beira Interior

% script for RGB 444 to YCbCr 444 color space conversion in n bits
% Input: 
        % 1-rgb   ---> RGB image in double format
        % 2-n     ---> number of the bits, this number should be either 8 or 10

% Output: 
        % 1-ycbcr ---> YCbCr image in n bits

function [ycbcr] = rgb2ycbcrn(rgb,n)

%  Recommendation ITU-R BT.709-6
M = [ 0.212600   0.715200  0.072200 ;
     -0.114572  -0.385428  0.500000 ;
      0.500000  -0.454153 -0.045847];
  
if (nargin < 2)
    n = 8;
end

ycbcr          = reshape(double(rgb), [], 3) * M';
ycbcr          = reshape(ycbcr, size(rgb));
ycbcr(:,:,1)   = (219*ycbcr(:,:,1)+16)*2^(n-8); %Luminance
ycbcr(:,:,2:3) = (224*ycbcr(:,:,2:3) + 128)*2^(n-8);

if(n==8)
    ycbcr = uint8(ycbcr);
elseif (n==10 || n==16)
    ycbcr = uint16(ycbcr);
else
    print('invalid bit depth')
end
