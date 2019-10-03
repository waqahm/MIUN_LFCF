% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved. 

% Parameters Info
% SZx % # of rows in LF
% SZy % # of columns in LF
% SAMP %  # Sampling of LF (1 = 17x17 and 4=5x5)
% H % Height of Image
% W % Width of Image


function [Status]=generate_MPVS_From_LF(path_input_db, Output_path,Layers,Frames,W,H,SAMP,inputBPP,outputBPP,DATASET)
Status=0;
FlagYuvFile=1; % File writing
FlagDownSampling420=1; % Chorma Downsampling

%--------------------------------------------------------------------------
NameList=[];

if(DATASET==1)
    POC=[1 1:Frames]; % Here POC are defined note One dummy frame is added
    VeiwID=[1:Layers]; % Here View ID's are defined
elseif(DATASET==2) % For Stanford 8bpp Tarot image
    listing=dir(path_input_db);
    POC=[1 1:Frames]; % Here POC are defined note One dummy frame is added
    VeiwID=[1:Layers]; % Here View ID's are defined
else
    POC=[0 0:Frames-1]; % Here POC are defined note One dummy frame is added
    VeiwID=[0:Layers-1]; % Here View ID's are defined
end

% Create folder to store the MPVS
if ~exist(Output_path, 'dir')% check if input LF exists
    mkdir(Output_path);
end

        

for indx=1:SAMP:Layers
    if(FlagYuvFile)
        fileName=sprintf('%s\\%d_%dx%d.yuv',Output_path,indx,W,H);
        fileId = fopen(fileName, 'w');
    end
    
    for indy=1:SAMP:Frames+1       
        
        
        if(DATASET==2)
            filename=listing(POC(indy)+2+((VeiwID(indx)-1)*17)).name
            NameWithPath=sprintf('%s%s',path_input_db,filename);
            I_imgT=imread(NameWithPath);
            NameMatrix{indx,indy}=filename;
        else
            filename=sprintf('%s%03d_%03d.ppm',path_input_db,POC(indy),VeiwID(indx));
            try
                I_imgT=imread(filename); %
            catch exception
              
%                fprintf(1,'The identifier was:\n%s\n',exception.identifier);
%                fprintf(1,'There was an error! The message was:\n%s',exception.message);
        
               msgbox(exception.message,exception.identifier,'error');
               
               throw(exception)
            end
            NameMatrix{indx,indy}=strcat(sprintf('%03d_%03d.ppm',POC(indy),VeiwID(indx)));
        end
        
        % Converting to uint16
        if(inputBPP==10)
            I_imgT=double(I_imgT);
            B=I_imgT./(2^16 -1);
            I_imgT=(B).*(2^outputBPP-1);
            %clipping
            I_imgT(I_imgT<0) = 0;
            I_imgT(I_imgT>(2^outputBPP-1)) = (2^outputBPP-1);
        end
        % Rounding
        if(outputBPP==10)
            I_imgT = uint16(I_imgT);
        else
            I_imgT = uint8(I_imgT);
        end
        
        
        %------------------------------------------------------------------
        
        % ------------------- Column Padding for Lytro DB ------
        if(DATASET==1)
            I_imgT(1:2:end,625,1:3) = I_imgT(1:2:end,1,1:3);
            I_624x434=I_imgT(:,2:625,1:3);
            I_imgT=I_624x434;
        end
        
        if(outputBPP==10)
            [ycbcr] = rgb2ycbcr10bit(uint16(I_imgT));
        else
            [ycbcr] = rgb2ycbcr(uint8(I_imgT));
        end
        
        out{1,1}=ycbcr(:,:,1);
        out{2,1}=ycbcr(:,:,2);
        out{3,1}=ycbcr(:,:,3);
        
        if(FlagDownSampling420)
            [out] = downsample(ycbcr);
        end
        
        if(FlagYuvFile)
            YUVwriter(out,fileId,outputBPP);
        end
        
        
    end
    
    if(FlagYuvFile)
        fclose(fileId);
    end
end

xlswrite(strcat(Output_path,'\LF_Views.xlsx'),NameMatrix);
Status=1;
end



