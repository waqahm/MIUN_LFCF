% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved.[02-09-2019].

function [] = write_file(S)
%% This function writes the configuration file used for LF encoding using MV-HEVC

%Generate the QP offset for each frame.
[S]=generate_QPMatFile(S);

intro_line = "# Add personal note about configuration file here";

disp('Writing config file...');

fileID = fopen(strcat(sprintf('%s\\',S.pathCFG),S.configFileName),'w');


fprintf(fileID,'%s \n#======== Legend for comments ===================== \n# (m) specification per layer/dimension/layerset possible\n# (c) cyclic repetition of values, if not given for all layers/dimensions/layersets. (e.g. 5 layers and 1 2 3 -> 1 2 3 1 2  )\n\n#======== Proposed motion optimization flags ==============\n',intro_line);
%======== Proposed motion optimization flags =================
fprintf(fileID,'DummyFrame                    : 1          # This this flag indicates whether the first frame in the LF is a dummy frame.\n');
fprintf(fileID,'									       # It must be enabled since we have used dummy frame in the proposed work to handle enoding of the central frame first.\n');

fprintf(fileID,'Rectified                     : %s          # Enable this flag to perform restricted motion search in horizontal or vertical direction (1D search),\n',num2str(S.Rectified));
fprintf(fileID,'										   # otherwise use default 2D search.\n');
fprintf(fileID,'LFMotionSearchRange           : %s          # Enable this flag to adapt search range with respect to max motion found in central LF column.\n',num2str(S.LFMotionSearchRange));
fprintf(fileID,'Horizontal_StepSize           : %s          # This flag specifies the horizontal distance between adjacent cameras/lenses(requried if LFMotionSearchRange == 1)\n',num2str(S.Horizontal_StepSize));
fprintf(fileID,'Vertical_StepSize             : %s          # This flag specifies the vertical distance between adjacent cameras/lenses (requried if LFMotionSearchRange == 1)\n\n',num2str(S.Vertical_StepSize));



%======== File I/O =====================
fprintf(fileID,'#======== File I/O =====================\n');
fprintf(fileID,'FrameRate                     : %s          # Frame Rate per second\n',num2str(S.FrameRate));
fprintf(fileID,'NumberOfLayers                : %s          # Number of layers\n',num2str(S.NumberOfLayers));
fprintf(fileID,'TargetEncLayerIdList          :             # Layer Id in Nuh to be encoded, (empty:-> all layers will be encode) \n');
fprintf(fileID,'ConformanceWindowMode         : 1           # 1 for Automatic Padding   \n');
%======== VPS ============================
fprintf(fileID,'#======== VPS ============================\n');
fprintf(fileID,'ScalabilityMask               : 2           # Scalability Mask             ( Scalability Mask: 2: Multiview, 8: Auxiliary, 10: Multiview + Auxiliary )\n');
fprintf(fileID,'DimensionIdLen                : 5           # Number of bits to store Ids,  per scalability dimension, (m)\n');
voi=mat2str(S.framesVID);
fprintf(fileID,'ViewOrderIndex                : %s          # ViewOrderIndex, per layer (m)\n',voi(2:end-1));
fprintf(fileID,'AuxId                         :             # Auxiliary Id, per layer (m)\n');
fprintf(fileID,'LayerIdInNuh                  : 0           # Layer Id in NAL unit header, (0: no explicit signalling, otherwise per layer ) (m)\n');
fprintf(fileID,'SplittingFlag                 : 0           # Splitting Flag \n');
vid=mat2str(S.VIDArray);
fprintf(fileID,'ViewId                        : %s          # ViewId, per ViewOrderIndex (m)\n',vid(2:end-1));
fprintf(fileID,'OutputVpsInfo                 : 0           # Output VPS information\n\n');
fprintf(fileID,'ChromaFormatIDC               : 420         \n');

%======== VPS/ Layer sets ================
fprintf(fileID,'#======== VPS/ Layer sets ================\n');
fprintf(fileID,'VpsNumLayerSets               : 4           # Number of layer sets    \n');
fprintf(fileID,'LayerIdsInSet_0               : 0           # Indices in VPS of layers in layer set 0\n');
fprintf(fileID,'LayerIdsInSet_1               : 0 1         # Indices in VPS of layers in layer set 1\n');
fprintf(fileID,'LayerIdsInSet_2               : 0 1 2       # Indices in VPS of layers in layer set 2\n');
LayerIdsInSet_3 = mat2str(0:(S.NumberOfLayers-1));
fprintf(fileID,'LayerIdsInSet_3               : %s         # Indices in VPS of layers in layer set 3\n',LayerIdsInSet_3(2:end-1));
for i=4:S.NumberOfLayers-1
    if i>9 % for correct formatting
        fprintf(fileID,'LayerIdsInSet_%s              :             # Indices in VPS of layers in layer set %s\n',num2str(i),num2str(i));
    else
        fprintf(fileID,'LayerIdsInSet_%s               :             # Indices in VPS of layers in layer set %s\n',num2str(i),num2str(i));
    end
    
end
fprintf(fileID,'\nNumAddLayerSets               : 0            # Specifies the number of additional layer sets\n');
for i=1:S.NumberOfLayers
    if i>10 % for correct formatting
        fprintf(fileID,'HighestLayerIdxPlus1_%s       : -1           # Highest layer idx plus 1 for the %s-th additional layer set, per independent layer (m) (first value will be ignored)\n',num2str(i-1),num2str(i-1));
    else
        fprintf(fileID,'HighestLayerIdxPlus1_%s        : -1           # Highest layer idx plus 1 for the %s-th additional layer set, per independent layer (m) (first value will be ignored)\n',num2str(i-1),num2str(i-1));
    end
end

%======== VPS / Output layer sets ================
fprintf(fileID,'\n\n#======== VPS / Output layer sets ================\n\n');
fprintf(fileID,'DefaultTargetOutputLayerIdc   : 0            # Specifies output layers of layer sets, 0: output all layers, 1: output highest layer, 2: specified by LayerIdsInDefOutputLayerSet\n');
for i=1:S.NumberOfLayers
    if i>10 % for correct formatting
        fprintf(fileID,'LayerIdsInDefOutputLayerSet_%s:              # Indices in VPS of output layers in layer set %s (when DefaultTargetOutputLayerIdc is equal to 2) \n',num2str(i-1),num2str(i-1));
    else
        fprintf(fileID,'LayerIdsInDefOutputLayerSet_%s :              # Indices in VPS of output layers in layer set %s (when DefaultTargetOutputLayerIdc is equal to 2) \n',num2str(i-1),num2str(i-1));
    end
end
fprintf(fileID,'\n\nOutputLayerSetIdx             :              # Indices of layer sets used to derive additional output layer sets\n');
for i=1:S.NumberOfLayers
    if i>10 % for correct formatting
        fprintf(fileID,'LayerIdsInAddOutputLayerSet_%s:              # Indices in VPS of output layers in additional output layer set %s\n',num2str(i-1),num2str(i-1));
    else
        fprintf(fileID,'LayerIdsInAddOutputLayerSet_%s :              # Indices in VPS of output layers in additional output layer set %s\n',num2str(i-1),num2str(i-1));
    end
    
end

%======== VPS / PTLI ================
fprintf(fileID,'\n#======== VPS / PTLI ================\n\n');
fprintf(fileID,'Profile                       : main main multiview-main   # Profile indication in VpsProfileTierLevel, per VpsProfileTierLevel syntax structure  (m) \n');
fprintf(fileID,'Level                         : none none none             # Level   indication in VpsProfileTierLevel, per VpsProfileTierLevel syntax structure  (m) \n');
fprintf(fileID,'Tier                          : main main main             # Tier    indication in VpsProfileTierLevel, per VpsProfileTierLevel syntax structure  (m) \n');
fprintf(fileID,'InblFlag                      : 0    0    0                # Inbl    indication in VpsProfileTierLevel, per VpsProfileTierLevel syntax structure  (m) \n\n');
for i=1:S.NumberOfLayers
    if i==1%
        fprintf(fileID,'ProfileTierLevelIdx_%s         : 1                         # VpsProfileTierLevel indices of layers in output layer set %s (m) (should be -1, when layer is not necessary)\n',num2str(i-1),num2str(i-1));
    elseif i>10 % for correct formatting
        fprintf(fileID,'ProfileTierLevelIdx_%s        : 1 2                        # VpsProfileTierLevel indices of layers in output layer set %s (m) (should be -1, when layer is not necessary)\n',num2str(i-1),num2str(i-1));
    else
        fprintf(fileID,'ProfileTierLevelIdx_%s         : 1 2                        # VpsProfileTierLevel indices of layers in output layer set %s (m) (should be -1, when layer is not necessary)\n',num2str(i-1),num2str(i-1));
    end
end

%======== VPS / Dependencies ================
D = S.dirRefLayerInd;
max_len = max(cellfun('size',D,2));% find largest cell... for formatting
fprintf(fileID,'\n#======== VPS / Dependencies ================\n');
for i=1:S.NumberOfLayers-1
    refLayer = mat2str(D{i});
    if numel(refLayer)>1
        refLayer = refLayer(2:end-1);
    end
    if i>9% for correct formatting
        fprintf(fileID,'DirectRefLayers_%s            : %s%s# Indices in VPS of direct reference layers  \n',num2str(i),refLayer,repmat(' ',1,((max_len*4)-(size(refLayer,2)-1))));%(max_len*4) in repmat function represents the max distance after writing refLayer
    else
        fprintf(fileID,'DirectRefLayers_%s             : %s%s# Indices in VPS of direct reference layers  \n',num2str(i),refLayer,repmat(' ',1,((max_len*4)-(size(refLayer,2)-1))));
    end
end
fprintf(fileID,'\n');
for i=1:S.NumberOfLayers-1
    dependency_types=mat2str(repmat(2,1,size(D{i},2)));
    if size(D{i},2)>1
        dependency_types = dependency_types(2:end-1);
    end
    if i>9 % for correct formatting
        fprintf(fileID,'DependencyTypes_%s            : %s%s# Dependency types of direct reference layers, 0: Sample 1: Motion 2: Sample+Motion \n',num2str(i),dependency_types,repmat(' ',1,((max_len*4)-(size(dependency_types,2)-1))));
    else
        fprintf(fileID,'DependencyTypes_%s             : %s%s# Dependency types of direct reference layers, 0: Sample 1: Motion 2: Sample+Motion \n',num2str(i),dependency_types,repmat(' ',1,((max_len*4)-(size(dependency_types,2)-1))));
    end
end


%======== Unit definition ================
fprintf(fileID,'\n\n#======== Unit definition ================\n');
fprintf(fileID,'MaxCUWidth                    : %s          # Maximum coding unit width in pixel\n',num2str(S.MaxCUWidth));
fprintf(fileID,'MaxCUHeight                   : %s          # Maximum coding unit height in pixel\n',num2str(S.MaxCUHeight));
fprintf(fileID,'MaxPartitionDepth             : %s           # Maximum coding unit depth\n',num2str(S.MaxPartitionDepth));
fprintf(fileID,'QuadtreeTULog2MaxSize         : %s           # Log2 of maximum transform size for quadtree-based TU coding (2...6)\n\n',num2str(S.QuadtreeTULog2MaxSize));
fprintf(fileID,'QuadtreeTULog2MinSize         : %s           # Log2 of minimum transform size for quadtree-based TU coding (2...6)\n\n',num2str(S.QuadtreeTULog2MinSize));
fprintf(fileID,'QuadtreeTUMaxDepthInter       : %s\n',num2str(S.QuadtreeTUMaxDepthInter));
fprintf(fileID,'QuadtreeTUMaxDepthIntra       : %s\n',num2str(S.QuadtreeTUMaxDepthIntra));


%======== Coding Structure =============
if rem(S.NumberOfFrames,2)
    GOPSize = S.NumberOfFrames+1;
else
    GOPSize = S.NumberOfFrames;
end

fprintf(fileID,'\n#======== Coding Structure =============\n');
fprintf(fileID,'IntraPeriod                   : -1          # Period of I-Frame ( -1 = only first)\n');
fprintf(fileID,'DecodingRefreshType           : 1           # Random Accesss 0:none, 1:CRA, 2:IDR, 3:Recovery Point SEI\n');
fprintf(fileID,'GOPSize                       : %s          # GOP Size (number of B slice = GOPSize-1)\n\n',num2str(GOPSize));%dummyFrame included

fprintf(fileID,'#                         CbQPoffset    QPfactor     betaOffsetDiv2   #ref_pics_active  reference pictures     deltaRPS     reference idcs          ilPredLayerIdc       refLayerPicPosIl_L1\n');
fprintf(fileID,'#            Type  POC QPoffset  CrQPoffset  tcOffsetDiv2      temporal_id      #ref_pics                 predict     #ref_idcs        #ActiveRefLayerPics     refLayerPicPosIl_L0     \n');

 
fprintf(fileID,'\n');
write_GOP_structure(S,fileID);

%=========== Motion Search =============
fprintf(fileID,'\n\n\n\n\n#=========== Motion Search =============\n');

fprintf(fileID,'FastSearch                    : 1           # 0:Full search  1:TZ search\n');
fprintf(fileID,'SearchRange                   : 64          # (0: Search range is a Full frame)\n');
fprintf(fileID,'BipredSearchRange             : 4           # Search range for bi-prediction refinement\n');
fprintf(fileID,'HadamardME                    : 1           # Use of hadamard measure for fractional ME\n');
fprintf(fileID,'FEN                           : 1           # Fast encoder decision\n');
fprintf(fileID,'FDM                           : 1           # Fast Decision for Merge RD cost\n');
fprintf(fileID,'DispSearchRangeRestriction    : 1           # Limit Search range for vertical component of disparity vector\n');
fprintf(fileID,'VerticalDispSearchRange       : 56          # Vertical Search range in pixel\n');

%======== Quantization =============
fprintf(fileID,'\n#======== Quantization =============\n');
fprintf(fileID,'QP                            :             # quantization parameter (mc)\n');
fprintf(fileID,'MaxDeltaQP                    : 0           # CU-based multi-QP optimization\n');
fprintf(fileID,'MaxCuDQPDepth                 : 0           # Max depth of a minimum CuDQP for sub-LCU-level delta QP\n');
fprintf(fileID,'DeltaQpRD                     : 0           # Slice-based multi-QP optimization\n');
fprintf(fileID,'RDOQ                          : 1           # RDOQ\n');
fprintf(fileID,'RDOQTS                        : 1           # RDOQ for transform skip\n');
fprintf(fileID,'SliceChromaQPOffsetPeriodicity: 0           # Used in conjunction with Slice Cb/Cr QpOffsetIntraOrPeriodic. Use 0 (default) to disable periodic nature.\n');
fprintf(fileID,'SliceCbQpOffsetIntraOrPeriodic: 0           # Chroma Cb QP Offset at slice level for I slice or for periodic inter slices as defined by SliceChromaQPOffsetPeriodicity. Replaces offset in the GOP table.\n');
fprintf(fileID,'SliceCrQpOffsetIntraOrPeriodic: 0           # Chroma Cr QP Offset at slice level for I slice or for periodic inter slices as defined by SliceChromaQPOffsetPeriodicity. Replaces offset in the GOP table.\n');

%=========== Deblock Filter ============
fprintf(fileID,'\n#=========== Deblock Filter ============\n\n');
fprintf(fileID,'LoopFilterOffsetInPPS         : 1           # Dbl params: 0=varying params in SliceHeader, param = base_param + GOP_offset_param; 1 (default) =constant params in PPS, param = base_param)\n');
fprintf(fileID,'LoopFilterDisable             : 0           # Disable deblocking filter (0=Filter, 1=No Filter) (mc)\n');
fprintf(fileID,'LoopFilterBetaOffset_div2     : 0           # base_param: -6 ~ 6 \n');
fprintf(fileID,'LoopFilterTcOffset_div2       : 0           # base_param: -6 ~ 6\n');
fprintf(fileID,'DeblockingFilterMetric        : 0           # blockiness metric (automatically configures deblocking parameters in bitstream). Applies slice-level loop filter offsets (LoopFilterOffsetInPPS and LoopFilterDisable must be 0)\n');

%=========== Misc. ============
fprintf(fileID,'\n#=========== Misc. ============\n');
fprintf(fileID,'InternalBitDepth              : 8           # codec operating bit-depth\n');

fprintf(fileID,'\n#=========== Coding Tools =================\n');
fprintf(fileID,'SAO                           : 1           # Sample adaptive offset  (0: OFF, 1: ON) (mc)\n');
fprintf(fileID,'AMP                           : 1           # Asymmetric motion partitions (0: OFF, 1: ON)\n');
fprintf(fileID,'TransformSkip                 : 1           # Transform skipping (0: OFF, 1: ON)\n');
fprintf(fileID,'TransformSkipFast             : 1           # Fast Transform skipping (0: OFF, 1: ON)\n');
fprintf(fileID,'SAOLcuBoundary                : 0           # SAOLcuBoundary using non-deblocked pixels (0: OFF, 1: ON)\n');

fprintf(fileID,'\n#============ Slices ================\n');
fprintf(fileID,'SliceMode                : 0                # 0: Disable all slice options.\n');
fprintf(fileID,'                                            # 1: Enforce maximum number of LCU in a slice,\n');
fprintf(fileID,'                                            # 2: Enforce maximum number of bytes in a slice\n');
fprintf(fileID,'                                            # 3: Enforce maximum number of tiles in a slice\n');
fprintf(fileID,'SliceArgument            : 1500             # Argument for ''SliceMode''.\n');
fprintf(fileID,'                                            # If SliceMode==1 it represents max. SliceGranularity-sized blocks per slice.\n');
fprintf(fileID,'                                            # If SliceMode==2 it represents max. bytes per slice.\n');
fprintf(fileID,'                                            # If SliceMode==3 it represents max. tiles per slice.\n');

fprintf(fileID,'\nLFCrossSliceBoundaryFlag : 1                # In-loop filtering, including ALF and DB, is across or not across slice boundary.\n');
fprintf(fileID,'                                            # 0:not across, 1: across\n');

fprintf(fileID,'\n#============ PCM ================\n');
fprintf(fileID,'PCMEnabledFlag                      : 0                # 0: No PCM mode\n');
fprintf(fileID,'PCMLog2MaxSize                      : 5                # Log2 of maximum PCM block size.\n');
fprintf(fileID,'PCMLog2MinSize                      : 3                # Log2 of minimum PCM block size.\n');
fprintf(fileID,'PCMInputBitDepthFlag                : 1                # 0: PCM bit-depth is internal bit-depth. 1: PCM bit-depth is input bit-depth.\n');
fprintf(fileID,'PCMFilterDisableFlag                : 0                # 0: Enable loop filtering on I_PCM samples. 1: Disable loop filtering on I_PCM samples.\n');

fprintf(fileID,'\n#============ Tiles ================\n');
fprintf(fileID,'TileUniformSpacing                  : 0                # 0: the column boundaries are indicated by TileColumnWidth array, the row boundaries are indicated by TileRowHeight array\n');
fprintf(fileID,'                                                       # 1: the column and row boundaries are distributed uniformly\n');
fprintf(fileID,'NumTileColumnsMinus1                : 0                # Number of tile columns in a picture minus 1\n');
fprintf(fileID,'TileColumnWidthArray                : 2 3              # Array containing tile column width values in units of CTU (from left to right in picture)   \n');
fprintf(fileID,'NumTileRowsMinus1                   : 0                # Number of tile rows in a picture minus 1\n');
fprintf(fileID,'TileRowHeightArray                  : 2                # Array containing tile row height values in units of CTU (from top to bottom in picture)\n');

fprintf(fileID,'\nLFCrossTileBoundaryFlag           : 1                  # In-loop filtering is across or not across tile boundary.\n');
fprintf(fileID,'                                                       # 0:not across, 1: across                                        \n');               

fprintf(fileID,'\n#============ WaveFront ================\n');
fprintf(fileID,'WaveFrontSynchro                    : 0                # 0:  No WaveFront synchronisation (WaveFrontSubstreams must be 1 in this case).\n');
fprintf(fileID,'                                                       # >0: WaveFront synchronises with the LCU above and to the right by this many LCUs.\n');

fprintf(fileID,'\n#=========== Quantization Matrix =================\n');
fprintf(fileID,'ScalingList                   : 0                      # ScalingList 0 : off, 1 : default, 2 : file read\n');
fprintf(fileID,'ScalingListFile               : scaling_list.txt       # Scaling List file name. If file is not exist, use Default Matrix.\n');

fprintf(fileID,'\n#============ Lossless ================\n');
fprintf(fileID,'TransquantBypassEnableFlag: 0  # Value of PPS flag.\n');
fprintf(fileID,'CUTransquantBypassFlagForce: 0 # Constant lossless-value signaling per CU, if TransquantBypassEnableFlag is 1.\n');

fprintf(fileID,'\n#============ Rate Control ======================\n');
fprintf(fileID,'RateControl                         : 0                # Rate control: enable rate control\n');
fprintf(fileID,'TargetBitrate                       : 1000000          # Rate control: target bitrate, in bps\n');
fprintf(fileID,'KeepHierarchicalBit                 : 1                # Rate control: keep hierarchical bit allocation in rate control algorithm\n');
fprintf(fileID,'LCULevelRateControl                 : 1                # Rate control: 1: LCU level RC; 0: picture level RC\n');
fprintf(fileID,'RCLCUSeparateModel                  : 1                # Rate control: use LCU level separate R-lambda model\n');
fprintf(fileID,'InitialQP                           : 0                # Rate control: initial QP\n');
fprintf(fileID,'RCForceIntraQP                      : 0                # Rate control: force intra QP to be equal to initial QP\n');


fprintf(fileID,'\n\n#============== SEI ================================\n');
for i=1:S.NumberOfLayers
    if i>10% for correct formatting
        fprintf(fileID,'SeiCfgFileName_%s                   :                      \n',num2str(i-1));
    else
        fprintf(fileID,'SeiCfgFileName_%s                    :                      \n',num2str(i-1));
    end
end

fprintf(fileID,'\n### DO NOT ADD ANYTHING BELOW THIS LINE ###\n');
fprintf(fileID,'### DO NOT DELETE THE EMPTY LINE BELOW ###\n');


fclose(fileID);

disp('.... Config File Written .....')

end

