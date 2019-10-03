% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved.

% This function performs two different tasks
% Part A) assign prediction level to input LF
% Part B) it create prediction structure (GOP) list for each frame
% Date 02/09/2019

function [Formatted_Prediction_List,DecodingOrder,Prediction_levels,L,D,RIndx,dRPS]=Prediction_level_GOP_Assignment(M,Max_Pred)

% ----------------------------- Parameters --------------------------------

disp('Generating Prediction structure...');
FlagLowlevelPredictor=1;    % This flag control weather the leaf frames can take from same level frames;
MaxPredictors=Max_Pred;     % total no. of predictor frames allowed for each frame
NoOfLeftPred=1;             % minimum value should be 1 (at least central frame should be used as predictor for right side

L{:}=[];                    % Cell Array that will maintain Prediction Levels
C=[];                       % List array used to perform intermediate processing
Flag=0;
i=1;                        % Represent the prediction level

% Level 1 is assigned to central frame.
L{0+1,0+1}=floor((M-1)/2);
% Central frame and two corners frames are updated in list C
C=[C; 0,L{0+1,0+1},M-1];
counter=0;

% Creating List of Decoding Order
ArrayL=[]; % maintains left side frames
ArrayR=[]; % maintains right side frames
MainArrayL=[];
MainArrayR=[];
Level_R=[];
Level_L=[];
%%--------------------------------- Part A --------------------------------

while(floor((M-1)/2^(i+1))>=2) % Check the partitioning of LF array
    Flag=1;
    for c=1:numel(C)-1
        L{i+1,c}=C(c)+floor((M-1)/(2^(i+1)));  % each frame in list C is traversed and offset is added to assign the prediction i
    end
    i=i+1;
    for x=1:size(L,2) % Fixed on 06.12.2018
        res=ismember(L{i,x},C);
        if(res==0)
            C=[C L{i,x}]; % here the list C is updated with frames recently assigned with prediction level
        end
    end
    C=sort(C); % Sorting the List C
    
end
% Test condition to handle some exceptions
if (Flag==0)
    i=i+1;
end

%---------- Special Case (L1) ------------------
L{1+1,2+1}=0; % the corner frames are assigned with prdictioin level 1
L{1+1,2+2}=M-1;


%-------------- Leaf frames are assigned to final prediciton level --------
for m=1:M-1
    
    res=ismember(m,C);
    
    if(res==0)
        counter=counter+1;
        L{i+1,counter}= m; % all the remaining frames are assigned with final prediction level
    end
end
%--------------------------------------------------------------------------s
Prediction_levels=zeros(1,M);
for kx=1:size(L,1)
    for ky=1:size(L,2)
        
        if(L{kx,ky}>=0)
            Prediction_levels(L{kx,ky}+1)=kx-1;
            kx-1;
        end
    end
end

%%--------------------------------- Part B --------------------------------
% Converting Cell array of prediction levels in to two 1D array's
for k=1:size(L,1)
    for l=1:size(L,2)
        
        if(~(isempty(L{k,l})))
            
            if(L{1,1}>=L{k,l})
                ArrayL=[ArrayL L{k,l}]; % This array will maintain Left side frames information
            else
                ArrayR=[ArrayR L{k,l}]; % This array will maintain Right side frames information
            end
        end
    end
    
    % Maintain the Left side frames decoding order and prediction level
%     if(~(isempty(ArrayL)))
%         LL(:,1)=ArrayL';
%         LL(:,2)=k;
%         LL=sort(LL,'descend');
%         MainArrayL=[MainArrayL LL(:,1)'];
%         Level_L=[Level_L LL(:,2)'];
%     end
    if(~(isempty(ArrayL)))
        ArrayL=sort(ArrayL,'descend');
        for Lindx=1:size(ArrayL,2)
        LL(Lindx,1)=ArrayL(Lindx)';
        LL(Lindx,2)=k;
%       LL=sort(LL,'descend');
        MainArrayL=[MainArrayL LL(Lindx,1)'];
        Level_L=[Level_L k];
        end
    end
    % Maintain the Right side frames decoding order and prediction level

    if(~(isempty(ArrayR)))
        for Rindx=1:size(ArrayR,2)
        RR(Rindx,1)=ArrayR(Rindx)';
        RR(Rindx,2)=k;
%         RR=sort(RR);
        MainArrayR=[MainArrayR RR(Rindx,1)'];
        Level_R=[Level_R k];    % Level_R=[Level_R RR(:,2)']; % 11-09-2019
        end
    end
    
    % Empty all the temporary arrays
    ArrayL=[];
    LL=[];
    RR=[];
    ArrayR=[];
end

% Final Decoding Order list
DecodingOrder=[MainArrayL MainArrayR];
% Final Prediction level list
LevelAssigned=[Level_L Level_R];

% Temporary Array that maintain Decoding and prediction level list for left side
Temp_DecodingOrderL=[MainArrayL];
Temp_LevelAssignedL=[Level_L Level_R];

% Temporary Array that maintain Decoding and prediction level list for right side
Temp_DecodingOrderR=[MainArrayL(1:NoOfLeftPred) MainArrayR];
Temp_LevelAssignedR=[Level_L(1:NoOfLeftPred) Level_R];


%-------------------------------------------------------------------------

Base=L{1,1};% This defines the Base frame
MaxPredLevel=size(L,1); % This represents the total no. of prediction levels
P_List_L=[]; % List that maintains the left side predictor list for each frame on left side
P_List_R=[]; % List that maintains the right side predictor list for each frame on right side

% Handling Left Side of input LF
for i=1:size(Temp_DecodingOrderL,2)
    % This condition check the total no. of predictor allowed for each frame
    if(i-1<=MaxPredictors)
        MPL=i-1;
    else
        MPL=MaxPredictors;
    end
    for c=1:1:MPL
        if(Temp_LevelAssignedL(c)~=MaxPredLevel || FlagLowlevelPredictor) % Low level predictor should be used for prediction
            if(Temp_LevelAssignedL(i)>=Temp_LevelAssignedL(c)) % Low level predictor should be used for prediction
                P_List_L{i,c}=Temp_DecodingOrderL(c);
            end
        end
    end
    
end

% Handling Right Side of input LF
for j=1+NoOfLeftPred:size(Temp_DecodingOrderR,2) % The loop will start from right side frames
    
    % This condition check the total no. of predictor allowed for each frame
    if(j-1<=MaxPredictors)
        MPR=j-1;
    else
        MPR=MaxPredictors;
    end
    
    
    for c=1:1:MPR
        if(Temp_LevelAssignedR(c)~=MaxPredLevel || FlagLowlevelPredictor) % Low level predictor should be used for prediction
            if(Temp_LevelAssignedR(j)>=Temp_LevelAssignedR(c)) % Low level predictor should be used for prediction
                P_List_R{j-NoOfLeftPred,c}=Temp_DecodingOrderR(c); % the index of right side list is adjusted
            end
        end
    end
    
end

% Combined prediction list
Prediction_List=[P_List_L;P_List_R];

% Now the reference placed in the prediction list are written as per MVHEVC config file syntax.
count=0;
D = []; % direct reference layer indices - Modified by Ali Tariq
for indx=1:size(Prediction_List,1)
    d_index=[];
    for indy=size(Prediction_List,2):-1:1
        
        if(~(isempty(Prediction_List{indx,indy})))
            count=count+1;
            %             [indx indy Prediction_List{indx,indy}]
            [Fr Fc]=find(DecodingOrder==Prediction_List{indx,indy});
            %Prediction_List_complaint{indx,count}=Fc(1)-indx;
            Prediction_List_complaint{indx,count}=Prediction_List{indx,indy}-DecodingOrder(indx);
            
            %direct reference layer indices
            d_index = [d_index Fc(1)-1];
        end
    end
    count=0;
    
    if indx>1
        D{indx-1} = d_index;
        if isempty(d_index)
            D{indx-1} = ' ';
        end
    end
end
D = D';

%% Following code is for formatting the Prediction list and also find the number of active references

P = []; % POC_Prediction_List
L = []; % no. of reference pictures active
for i=1:size(Prediction_List_complaint,1)
    list{i} = [Prediction_List_complaint{i,1:end}];
    L(i)= numel(list{i});
    
    if isempty(list{i})
        P{i} = ' ';
    else
        %sort neg. references in descending order; sort pos. references in
        %ascending order
        negPart=sort(list{i}(list{i}<0),'descend');
        posPart=sort(list{i}(list{i}>0),'ascend');
        
        %         refs = mat2str(list{i});
        refs = mat2str([negPart posPart]);
        
        if numel(list{i})>1
            refs = refs(2:end-1);
        end
        P{i} = refs;
    end
end
P=P';
Formatted_Prediction_List = P;


%% Following code creates the reference idcs

for i = 1:size(Prediction_List,1)
    refViews{i} =  DecodingOrder(i)+list{i};
end
RIndx{1} = ' ';
for i=2:size(Prediction_List,1)
    prev_Refs = refViews{i-1};
    prev_POC =DecodingOrder(i-1);
    curr_Refs = refViews{i};
    
    idc = [];
    %in case of previous view being kept as reference for current view
    if find(prev_POC==curr_Refs)
        for j=2:size(curr_Refs,2)
            idc(find(prev_Refs==curr_Refs(j))) = 1;
        end
        idc = [idc 1];%in case of previous view being kept as reference for current view
    else
        for j=1:size(curr_Refs,2)
            idc(find(prev_Refs==curr_Refs(j))) = 1;
        end
        idc = [idc 0];
    end
    %idc;
    RIndx{i} =idc;
end
RIndx=RIndx';
%%
% Create Delta RPS
dRPS = [0;-diff(DecodingOrder')];

end



