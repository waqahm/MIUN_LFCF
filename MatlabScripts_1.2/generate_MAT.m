% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved [02-09-2019].

function  generate_MAT(DATASET,P)

% This function creates the MAT file of the selected input LF

% PATH=pwd;
if(DATASET==1) % Handling the Lytro Simulation data
  QP_List_MAT=[13 23 32 40; 15 25 33 42; 14 21 27 36; 14 23 32 42];
      Images={'Bikes','Danger_de_Mort','Stone_Pillars_Outside','Fountain_Vincent2'};
    for k=1:size(Images,2)
        QP_List=QP_List_MAT(k,:);
        for q=1:4 % size(IMG,2)
            path_input=sprintf('%s\\Lytro\\Output_%s\\QP_%d\\',P.pathEncodingSystem,Images{k},QP_List(q));
            path_logFile=sprintf('%s\\Lytro\\Output_%s\\',P.pathEncodingSystem,Images{k});
            path_output=sprintf('%s\\Lytro\\%s_dec_%d',P.pathCompressedMats,Images{k},QP_List(q));
            path_input_db=sprintf('%s\\Lytro\\%s\\',P.PathDataset,Images{k});
            if exist(path_input,'dir')
                mkdir(sprintf('%s\\Lytro\\',P.pathCompressedMats))
                res=mvs2mat(path_input,path_output,624,434,P.NumberOfLayers,P.NumberOfFrames,P.POCArray,P.VIDArray,DATASET,QP_List(q),path_logFile,path_input_db,P.Write_PPM);
            else
                fprintf('output encoded LF "Lytro/Output_%s/QP_%d/" does not exist. \n',Images{k},QP_List(q))
            end
        end
    end
    
elseif(DATASET==2)
    QP_List=[15 25 30 40];
    for q=1:size(QP_List,2) % size(IMG,2)
        path_input=sprintf('%s\\Stanford\\Output_%s\\QP_%d\\',P.pathEncodingSystem,'tarot',QP_List(q));
        path_logFile=sprintf('%s\\Stanford\\Output_%s\\',P.pathEncodingSystem,'tarot');
        path_output=sprintf('%s\\Stanford\\8bpp\\%s_dec_%d',P.pathCompressedMats,'tarot',QP_List(q));
        path_input_db=sprintf('%s\\Stanford\\%s\\',P.PathDataset,'tarot');
        if exist(path_input,'dir')  
            mkdir(sprintf('%s\\Stanford\\',P.pathCompressedMats))
            res=mvs2mat(path_input,path_output,1024,1024,P.NumberOfLayers,P.NumberOfFrames,P.POCArray,P.VIDArray,DATASET,QP_List(q),path_logFile,path_input_db,P.Write_PPM);
        else
            fprintf('output encoded LF "Stanford/Output_%s/QP_%d/" does not exist. \n','tarot',QP_List(q))
        end
    end
    
elseif(DATASET==3)
    QP_List=[18 23 32 36 48];
    for q=1:size(QP_List,2) % size(IMG,2)
        path_input=sprintf('%s\\Fraunhofer_IIS\\Output_%s\\QP_%d\\',P.pathEncodingSystem,'Set2',QP_List(q));
        path_logFile=sprintf('%s\\Fraunhofer_IIS\\Output_%s\\',P.pathEncodingSystem,'Set2');
        path_output=sprintf('%s\\Fraunhofer_IIS\\%s_dec_%d',P.pathCompressedMats,'Set2',QP_List(q));
        path_input_db=sprintf('%s\\Fraunhofer_IIS\\%s\\',P.PathDataset,'Set2');
        if exist(path_input,'dir')
            mkdir(sprintf('%s\\Fraunhofer_IIS\\',P.pathCompressedMats))
            res=mvs2mat(path_input,path_output,1920,1080,P.NumberOfLayers,P.NumberOfFrames,P.POCArray,P.VIDArray,DATASET,QP_List(q),path_logFile,path_input_db,P.Write_PPM);
        else
            fprintf('output encoded LF "Fraunhofer_IIS/Output_%s/QP_%d/" does not exist. \n','Set2',QP_List(q))
        end
    end
    
    
end

end

