
function [mov,rgb] = loadFileYuv(fileName, width, height, idxFrame,DATASET)
% load RGB movie [0, 255] from YUV 4:2:0 file
% fileName
fileId = fopen(fileName, 'r');
subSampleMat = [1, 1; 1, 1];
nrFrame = length(idxFrame);

if(DATASET==1) % For lytro DB 
mov=zeros(nrFrame,height,width+1,3);
else
mov=zeros(nrFrame,height,width,3);    
end
for f = 1 : 1 : nrFrame
    % search fileId position
    sizeFrame = 1.5 * width * height;
    fseek(fileId, (idxFrame(f) - 1) * sizeFrame, 'bof');
    
    % read Y component
    buf1 = fread(fileId, width * height, 'uchar');
    imgYuv1 = reshape(buf1, width, height).'; % reshape
    out{1,1}=imgYuv1;
    
    % read U component
    buf2 = fread(fileId, width / 2 * height / 2, 'uchar');
    imgYuv2 = reshape(buf2, width/2, height/2).'; % reshape
    out{2,1}=imgYuv2;
    
    % read V component
    buf3 = fread(fileId, width / 2 * height / 2, 'uchar');
    imgYuv3 = reshape(buf3, width/2, height/2).'; % reshape
    out{3,1}=imgYuv3;
    
    [ycbcr] = upsample(out);
    [rgb] = ycbcr2rgb(ycbcr);
    if(DATASET==1) % For lytro DB 
        %   ------------------- Column Un-Padding ---------------------------
        I_625x440(:,2:625,1:3)=rgb;
        I_625x440(:,1,1:3)=0;
        I_625x440(1:2:end,1,1:3)=I_625x440(1:2:end,625,1:3);
        I_625x440(1:2:end,625,1:3)=0;
        %    -----------------------Row padding -------------------------------
        I_624x434 =I_625x440(1:434,:,:);
        rgb=I_624x434;
        mov(f,:,:,:) = rgb;
    else
        mov(f,:,:,:) = rgb;
    end
end
fclose(fileId);





