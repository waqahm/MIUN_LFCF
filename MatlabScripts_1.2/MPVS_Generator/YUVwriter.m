% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved.

function YUVwriter(imgYuv,fileId,bit)

%   write Y component
	buf1 = reshape(imgYuv{1,1}.', [], 1); % reshape    
   	buf2 = reshape(imgYuv{2,1}.', [], 1); % reshape    
   	buf3 = reshape(imgYuv{3,1}.', [], 1); % reshape	
    buf=[buf1;buf2;buf3];
    
    if(bit==10)
    count = fwrite(fileId, buf, 'uint16');
    else
    count = fwrite(fileId, buf, 'uchar');
    end
    
end


