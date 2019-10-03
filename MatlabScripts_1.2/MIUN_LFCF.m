% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved [03-10-2019]. Version 1.2

% If you use this code in your research, we kindly ask you to cite the following paper: 
%
% W. Ahmad, M. Ghafoor, A. Tariq, A. Hassan. M. Sjostrom, and R. Olsson,
% "Computationally Efficient Light Field Image Compression using a Multiview HEVC Framework", IEEE Access, 2019.

clc
clear all
close all

BasePath = 'F:\Journal_02_Data\FrameWorkCodes\MIUN_LFCF';

PathDataset=strcat(BasePath,'\Datasets');
pathEncodingSystem=strcat(BasePath,'\ProposedEncodingSystem');
pathCompressedMats=strcat(BasePath,'\Compressed_Mats');
pathMPVS_Sequences=strcat(BasePath,'\\MPVS_Sequences');
pathCFG=strcat(BasePath,'\cfg');


%% Select the Input LF and paths

DATASET             = 1;     % Specify the input LF: 1 For Lytro, 
                             %                       2 For Stanford 8 bpp PNG, 
                             %                       3 For Fraunhofer IIS
DATASET_NAMES = ["Lytro" "Stanford" "Fraunhofer_IIS" "Eight_Eight"];

Layers =[13 17 11 8]; % Number of Vertical views
Frames =[13 17 33 8]; % Number of Horizontal views

%% Proposed motion optimization flags
DummyFrame			= 1; %  This flag indicates whether the first frame in the LF is a dummy frame. This flag must be enabled since we have used dummy frame in the proposed work to handle encoding of the central frame first.
Rectified			= 0; %  Enable this flag to perform restricted motion search in horizontal or vertical directions (1D search), otherwise use default motion search (2D search)

LFMotionSearchRange	= 0; %  Enable this flag to adapt search range with respect to maximum motion found in central LF column, otherwise use default search range (64 pixels)
Horizontal_StepSize = 4; %  This flag specifies the horizontal distance(cm) between adjacent cameras/lenses(required if LFMotionSearchRange == 1)
Vertical_StepSize	= 4; %  This flag specifies the vertical distance (cm) between adjacent cameras/lenses (required if LFMotionSearchRange == 1)


%% Indicate the maximum number of predictor reference frames

Max_Pred_Array            = [3 5 5 3];     % This paramter sets the maximum number predictor reference frames used for the generation of prediction structure
                             % Recommended values: 3 for Lytro and HCI LFs
                             %                     5 for Stanford and HDCA LFs

Max_Pred                  = Max_Pred_Array(DATASET);     % This paramter sets the maximum number predictor reference frames used for the generation of prediction structure
                             % Recommended values: 3 for Lytro and HCI LFs
                             %                     5 for Stanford and HDCA LFs

%% Select the required outputs from the framework

Sequence_Generate   = 0;     % This flag enables the generation of multiView sequences of the selected input LF.(stores in ..\MIUN_LFCF\MPVS_Sequences\)
Config_Write        = 0;     % This flag enables the generation of the configuration file used for LF encoding using MV-HEVC.(stores in ..\MIUN_LFCF\cfg\)
MAT_Generation      = 1;     % This flag enables the generation of the Mat file from Multiple YUV file.(stores in ..\MIUN_LFCF\Compressed_Mats\)
Write_PPM           = 0;     % This flag enables the generation of .PPM files of each decoded views (stores in ..\MIUN_LFCF\Compressed_Mats\)

                            
%% --------------- Configuration Parameters --------------------------------
%check if path exists
if ~exist(BasePath,'dir')
    msgStr = strcat('Base path "',BasePath,'" does not exist');
    msgbox(msgStr,'Directory Error','error');
    error(msgStr);
end
addpath(genpath('.\'))
configFileName = DATASET_NAMES(DATASET)+'Config.cfg';      %save config file as
QP_mat_file_name = "QpMatfile_"+DATASET_NAMES(DATASET);         %Save qp mat file as


%% 
%======== File I/O =====================
FrameRate                     = 24;         %Frame Rate per second

NumberOfLayers                = Layers(DATASET);
NumberOfFrames                = Frames(DATASET);

framesVID=0:NumberOfLayers-1;
FramesPOC=0:NumberOfFrames-1;


%% MV-HEVC config file parameters
%======== Unit definition ================
MaxCUWidth                    = 64;          % Maximum coding unit width in pixel
MaxCUHeight                   = 64;          % Maximum coding unit height in pixel
MaxPartitionDepth             = 4;           % Maximum coding unit depth
QuadtreeTULog2MaxSize         = 5;           % Log2 of maximum transform size for quadtree-based TU coding (2...6)
QuadtreeTULog2MinSize         = 2;           % Log2 of minimum transform size for quadtree-based TU coding (2...6)
QuadtreeTUMaxDepthInter       = 3;
QuadtreeTUMaxDepthIntra       = 3;


%% ---------------- Generate Prediction Level List and GOP structure -----------------------
[POC_Prediction_List,POCArray,POCLevels,noActiveRef,dirRefLayerInd,RefIdcs,DeltaRPS]=Prediction_level_GOP_Assignment(NumberOfFrames,Max_Pred);
if(NumberOfLayers==NumberOfFrames)
    VID_Prediction_List=POC_Prediction_List;
    VIDArray=POCArray;
    VIDLevels=POCLevels;
    noActiveRef_VID=noActiveRef;
else
    [VID_Prediction_List,VIDArray,VIDLevels,noActiveRef_VID,dirRefLayerInd,RefIdcs_notused]=Prediction_level_GOP_Assignment(NumberOfLayers,Max_Pred);
end
disp('.... Prediction structure Generated .....')


%% -------------- Weightage estimation ---------------------------
POC_Levels=max(POCLevels)+1;
Vid_Levels=max(VIDLevels)+1;

for i=1:POC_Levels
    for k=1:Vid_Levels
        WeightMat(POC_Levels-i+1,Vid_Levels-k+1)=max(i,k);
    end
end


%% Parameters structure
P = struct('FrameRate',FrameRate,...
    'NumberOfLayers',NumberOfLayers,...
    'NumberOfFrames',NumberOfFrames,...
    'framesVID',framesVID,...
    'FramesPOC',FramesPOC,...
    'VIDLevels',VIDLevels,...
    'POCLevels',POCLevels,...
    'configFileName',configFileName,...
    'POCArray',POCArray,...
    'VIDArray',VIDArray,...
    'MaxCUWidth',MaxCUWidth,...
    'MaxCUHeight',MaxCUHeight,...
    'MaxPartitionDepth',MaxPartitionDepth,...
    'QuadtreeTULog2MaxSize',QuadtreeTULog2MaxSize,...
    'QuadtreeTULog2MinSize',QuadtreeTULog2MinSize,...
    'QuadtreeTUMaxDepthInter',QuadtreeTUMaxDepthInter,...
    'QuadtreeTUMaxDepthIntra',QuadtreeTUMaxDepthIntra,...
    'QP_mat_file_name',QP_mat_file_name,...
    'VID_Prediction_List',{VID_Prediction_List},...
    'POC_Prediction_List',{POC_Prediction_List},...
    'noActiveRef',noActiveRef,...
    'noActiveRef_VID',noActiveRef_VID,...
    'dirRefLayerInd',{dirRefLayerInd},...
    'MaxQPOffset',8,...
    'RefIdcs',{RefIdcs},...
    'WeightMat',WeightMat,...
    'DeltaRPS',DeltaRPS,...
    'PathDataset',PathDataset,...
    'pathCompressedMats',pathCompressedMats,...
    'pathEncodingSystem',pathEncodingSystem,...
    'Write_PPM',Write_PPM,...
    'pathMPVS_Sequences',pathMPVS_Sequences,...
    'pathCFG',pathCFG,...
    'DummyFrame',DummyFrame,...
    'Rectified',Rectified,...
    'LFMotionSearchRange',LFMotionSearchRange,...
    'Horizontal_StepSize',Horizontal_StepSize,...
    'Vertical_StepSize',Vertical_StepSize);


%% Generate Multiple Pseudo Video Sequences for Encoder
if(Sequence_Generate)
    generate_MPVS(DATASET,P);
end

%% Create config file
if(Config_Write)
    write_file(P);
end

%% Generate LF MAT file
if(MAT_Generation)    
    generate_MAT(DATASET,P);
end

