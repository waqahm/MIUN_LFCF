% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved.

% This function creates the multi-view sequences of the selected input LF

function generate_MPVS(DATASET,P)

% PATH=pwd;
SAMP=1;

disp('.... Generating MPVS .....')
if (DATASET==1) % Handling Lytro Dataset
    Images={'Bikes','Danger_de_Mort','Stone_Pillars_Outside','Fountain_Vincent2'};
    W=624;
    H=434;
    inputBPP=10;
    outputBPP=8;
    
    for k=1:4 % size(IMG,2)
        path_input=sprintf('%s\\Lytro\\%s\\',P.PathDataset,Images{k});
        path_output=sprintf('%s\\Lytro\\%s',P.pathMPVS_Sequences,Images{k});
        if exist(path_input, 'dir')% check if input LF exists
            mkdir(path_output)
            fprintf('Generating MPVS for input LF: %s...\n',Images{k})
            [Status]=generate_MPVS_From_LF(path_input, path_output,P.NumberOfLayers,P.NumberOfFrames,W,H,SAMP,inputBPP,outputBPP,DATASET);
            fprintf('MPVS generated for input LF: %s\n',Images{k})
        else
            fprintf('input LF /Lytro/%s/ does not exist \n',Images{k})
        end
        
    end
    
elseif(DATASET == 2) %Handling Tarot Light Field from Stanford Dataset given in 8 Bpp .png format
    W=1024;
    H=1024;
    inputBPP=8;
    outputBPP=8;
    path_input=sprintf('%s\\Stanford\\tarot_Stanford\\',P.PathDataset);
    path_output=sprintf('%s\\Stanford\\tarot_Stanford',P.pathMPVS_Sequences);
    
    if exist(path_input, 'dir')% check if input LF exists
        mkdir(path_output)
        [Status]=generate_MPVS_From_LF(path_input, path_output,P.NumberOfLayers,P.NumberOfFrames,W,H,SAMP,inputBPP,outputBPP,DATASET);
    else
        msgbox('input LF "/Stanford/tarot_Stanford/" does not exist','Directory Error','error');
        error('input LF "/Stanford/tarot_Stanford/" does not exist')
    end
    
    
elseif (DATASET==3)  % Handling Fraunhofer_IIS Dataset
    W=1920;
    H=1080;
    inputBPP=10;
    outputBPP=8;
    path_input=sprintf('%s\\Fraunhofer_IIS\\Set2\\',P.PathDataset);
    path_output=sprintf('%s\\Fraunhofer_IIS\\set2',P.pathMPVS_Sequences);
    
    if exist(path_input, 'dir')% check if input LF exists
        mkdir(path_output)
        [Status]=generate_MPVS_From_LF(path_input, path_output,P.NumberOfLayers,P.NumberOfFrames,W,H,SAMP,inputBPP,outputBPP,DATASET);
    else
        msgbox('input LF "/Fraunhofer_IIS/Set2/" does not exist','Directory Error','error');        
        error('input LF "/Fraunhofer_IIS/Set2/" does not exist')
    end
    
end
disp('.... MPVS Generated .....')


end

