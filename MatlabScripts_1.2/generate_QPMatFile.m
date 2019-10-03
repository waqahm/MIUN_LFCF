% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved [02-09-2019].

function [P] = generate_QPMatFile(P)
% Rate Allocation code for proposed mulitview compression scheme for plenoptic image

%% input grid size
GridSizeVID = P.NumberOfLayers;
GridSizePOC = P.NumberOfFrames;
POCArray = P.POCArray;
VIdArray = P.VIDArray;

disp('Generating QP file...');

%% Prediciton level Assignment
%----------- Note ----------------
% 0 is for base frame
% 1 is for level 2 predictor
% 2 is for level 3 predictor
% 3 is for leaf frames.
WPOC = P.POCLevels; % Automated 07/12/2015
WVID = P.VIDLevels;

%% ------- Frame Veiw order index and View ID --------
framesVID=0:GridSizeVID-1;
for k=1:GridSizeVID
    framesVOI(VIdArray(k)+1)=k-1;
end

%% ------- Frame Picture Order Count and Decoding Order -----
FramesPOC=0:GridSizePOC-1;
for k=1:GridSizePOC
    FramesDO(POCArray(k)+1)=k-1;
end


%% QP matrix generation

% Base frame Indexes
BasePOC=POCArray(1);
BaseViewID=VIdArray(1);

for IdxPoc=1:GridSizePOC
    for IdxVid=1:GridSizeVID
        
        W=P.WeightMat(WPOC(IdxPoc)+1,WVID(IdxVid)+1);

        
        pocOffset= abs(BasePOC-FramesPOC(IdxPoc));
        vidOffset= abs(BaseViewID-framesVID(IdxVid));
        
        if(framesVOI(IdxVid)<BaseViewID+1)
            voiOffset= floor(framesVOI(IdxVid)/W);
        else
            voiOffset= floor((framesVOI(IdxVid)-BaseViewID)/W);
        end
        
        if(FramesDO(IdxPoc)<BasePOC+1)
            dOOffset= floor(FramesDO(IdxPoc)/W);
        else
            dOOffset= floor((FramesDO(IdxPoc)-BasePOC)/W);
        end
        
        Weightage(IdxPoc,IdxVid)=W;
        
        FD= floor(pocOffset/(1*W))+floor(vidOffset/(1*W)); % Updated on 12.12.2018 distance is divided by half to have less impact
        
        if(FramesPOC(IdxPoc)==BasePOC)||(framesVID(IdxVid)==BaseViewID)
            FQP(IdxPoc,IdxVid)=max(WPOC(IdxPoc),WVID(IdxVid)) ;
        else
            FQP(IdxPoc,IdxVid)= FD + voiOffset + dOOffset;
        end
        
    end
end

% Updated on 12.1.2019 QP offset is normalized according to given maximum offset
Norm_QP=FQP/(max(max(FQP)));
MAX_QP=P.MaxQPOffset;
QP_Desired=round(Norm_QP.*MAX_QP);

% QpMat=QP_Desired;
%--------------------------------------------------------------------------

for Id=1:size(POCArray,2)
    FQP_Updated(Id,:)=QP_Desired(POCArray(Id)+1,:);
end

for Id=1:size(VIdArray,2)
    QpMat(:,Id)=FQP_Updated(:,VIdArray(Id)+1);
end

P(:).QpMat=QpMat;
% save(strcat('.\cfg\',P.QP_mat_file_name,'_desired'),'QP_Desired') % storing on Input grid position
% save(strcat('.\cfg\',P.QP_mat_file_name),'QpMat') % storing on Input grid position

disp('.... QP estimated .....')

end

