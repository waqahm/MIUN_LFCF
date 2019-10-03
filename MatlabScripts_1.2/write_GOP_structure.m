% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved.[02-09-2019].

function [] = write_GOP_structure(S, FileID)

reference_pictures_POC = S.POC_Prediction_List;
reference_pictures_VID = S.VID_Prediction_List;%not used
NumberOfRefPics = S.noActiveRef;
reference_idcs = S.RefIdcs;

%% input grid size

GridSizeVID = S.NumberOfLayers;

GridSizePOC = S.NumberOfFrames;

Offset=0.5*ones(1,GridSizePOC)';

%%
%predict
predict(2:GridSizePOC) = 1;

%delta RPS
Delta= S.DeltaRPS;

NoOfActiveRefLayerPics=S.noActiveRef_VID;

%%

refLayerPicPosIl_L0 = [0 1 2 -1];
refLayerPicPosIl_L1 = [0 1 2 -1];
Layrd{1,:} = num2str(NoOfActiveRefLayerPics(1));
max_len = max(NoOfActiveRefLayerPics); %for formatting
for i=2:GridSizeVID
    noRef = NoOfActiveRefLayerPics(i);
    layer_idc = mat2str(0:noRef-1); % updated by Waqas
    if noRef == 1
        refPosL0 = refLayerPicPosIl_L0(1);
        refPosL1 = refLayerPicPosIl_L1(end);
    elseif noRef == 2
        refPosL0 = [refLayerPicPosIl_L0(1) refLayerPicPosIl_L0(end)];
        refPosL1 = [refLayerPicPosIl_L1(1) refLayerPicPosIl_L1(end)];
    else
        refPosL0 = [refLayerPicPosIl_L0(1) 1:noRef-2 refLayerPicPosIl_L0(end)];
        refPosL1 = [refLayerPicPosIl_L1(1) 1:noRef-2 refLayerPicPosIl_L1(end)];
    end
    refPosL0=mat2str(refPosL0);
    refPosL1=mat2str(refPosL1);
    if noRef>1
        refPosL0 = refPosL0(2:end-1);
        refPosL1 = refPosL1(2:end-1);
        layer_idc = layer_idc(2:end-1);
    end
    Layrd{i,:}=sprintf('%s       %s%s%s%s%s',num2str(noRef),layer_idc,repmat(' ',1,((max_len*3)-(size(layer_idc,2)-1))),refPosL0,repmat(' ',1,((max_len*3)-(size(refPosL0,2)-1))),refPosL1);
end

%%

% QpMatload=load(S.QP_mat_file_name);
QpMat=S.QpMat;


for Vid=1:GridSizeVID
    for poc=1:GridSizePOC
        
        
        if(poc<2)
            DeltaIdx=' ';
            noOfindex=' ';
        else
            DeltaIdx=Delta(poc);
            noOfindex= numel(reference_idcs{poc,:});
        end
        
        if(Vid==1)
            if(poc==1)
                
                % 21.08.2019 Dummy first frame:
                A{poc,:}=sprintf('Frame%d:       I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,S.POCArray(poc)+1,QpMat(poc,1),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
                %             continue
            elseif(poc<10) %to manage formatting
                A{poc,:}=sprintf('Frame%d:       B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
            else
                A{poc,:}=sprintf('Frame%d:      B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
            end
            
            %add extra dummy frame to make GOP even if LF is odd size
            if(poc == GridSizePOC && rem(S.NumberOfFrames,2))
                A{poc+1,:}=sprintf('Frame%d:      I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc+1,poc+1,QpMat(1,1),Offset(poc),NumberOfRefPics(1)+NoOfActiveRefLayerPics(1),NumberOfRefPics(1),max(NumberOfRefPics)*3,reference_pictures_POC{1,:},predict(1),' ',' ',max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{1,:}));
            end
            
        else
            if(Vid<11)
                if(poc==1)
                    %write extra dummy frame at start of GOP for layers > 1
                    A{poc,:}=  sprintf('FrameI_l%d:    I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s      %s',Vid-1,poc-1,QpMat(poc,1),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(1),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3, num2str(reference_idcs{poc,:}), Layrd{1,:});
                    fwrite(FileID,A{poc,:},'uchar');
                    fwrite(FileID,double(sprintf('\n')),'uchar');
                    
                    A{poc,:}=sprintf('Frame1_l%d:    B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %2s   %3s   %*s',Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3+1, num2str(reference_idcs{poc,:}));
                elseif(poc<10)%to manage formatting
                    A{poc,:}=sprintf('Frame%d_l%d:    B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
                else
                    A{poc,:}=sprintf('Frame%d_l%d:   B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
                end
                
                %add extra dummy frame to make GOP even if LF is odd size
                if(poc == GridSizePOC && rem(S.NumberOfFrames,2))
                    A{poc+1,:}=sprintf('Frame%d_l%d:   I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc+1,Vid-1,poc+1,QpMat(1,1),Offset(poc),NumberOfRefPics(1)+NoOfActiveRefLayerPics(1),NumberOfRefPics(1),max(NumberOfRefPics)*3,reference_pictures_POC{1,:},predict(1),' ',' ',max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{1,:}));
                end
                
            else
                if(poc==1)
                    %write extra dummy frame at start of GOP for layers > 1
                    A{poc,:}=sprintf('FrameI_l%d:   I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s      %s',Vid-1,poc-1,QpMat(poc,1),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(1),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3, num2str(reference_idcs{poc,:}), Layrd{1,:});
                    fwrite(FileID,A{poc,:},'uchar');
                    fwrite(FileID,double(sprintf('\n')),'uchar');
                    
                    A{poc,:}=sprintf('Frame1_l%d:   B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %2s   %3s   %*s',Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3+1,num2str(reference_idcs{poc,:}));
                elseif(poc<10)%to manage formatting
                    A{poc,:}=sprintf('Frame%d_l%d:   B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
                else
                    A{poc,:}=sprintf('Frame%d_l%d:  B    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc,Vid-1,S.POCArray(poc)+1,QpMat(poc,Vid),Offset(poc),NumberOfRefPics(poc)+NoOfActiveRefLayerPics(Vid),NumberOfRefPics(poc),max(NumberOfRefPics)*3,reference_pictures_POC{poc,:},predict(poc),num2str(DeltaIdx),num2str(noOfindex),max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{poc,:}));
                end
                %add extra dummy frame to make GOP even if LF is odd size
                if(poc == GridSizePOC && rem(S.NumberOfFrames,2))
                    A{poc+1,:}=sprintf('Frame%d_l%d:  I    %2d    %2d  0  0       %.4f   0        0        0       %2d      %2d     %*s    %d    %3s   %3s   %*s',poc+1,Vid-1,poc+1,QpMat(1,1),Offset(poc),NumberOfRefPics(1)+NoOfActiveRefLayerPics(1),NumberOfRefPics(1),max(NumberOfRefPics)*3,reference_pictures_POC{1,:},predict(1),' ',' ',max(cellfun('size',reference_idcs,2))*3,num2str(reference_idcs{1,:}));
                end
            end
        end
        
        C{poc,:}=sprintf('%s      %s',A{poc,:},Layrd{Vid,:});
        
        fwrite(FileID,C{poc,:},'uchar');
        fwrite(FileID,double(sprintf('\n')),'uchar');
        
        
        
        %write extra dummy frame at the end of GOP to make it even if LF is odd size
        if(poc == GridSizePOC && rem(S.NumberOfFrames,2))
            C{poc+1,:}=sprintf('%s      %s',A{poc+1,:},Layrd{1,:});
            
            fwrite(FileID,C{poc+1,:},'uchar');
            fwrite(FileID,double(sprintf('\n')),'uchar');
        end
        
        
        
        
    end
    fwrite(FileID,double(sprintf('\n')),'uchar');
    fwrite(FileID,double(sprintf('\n')),'uchar');
end


end

