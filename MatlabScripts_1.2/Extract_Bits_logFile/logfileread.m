% Author: Waqas Ahmad (waqas.ahmad@miun.se)
% Copyright(c) Realistic 3D Research Group,
%              Mid Sweden University, Sweden
%              http://https://www.miun.se/en/Research/research-centers/stc-researchcentre/about-stc/Research-Groups/Realistic-3D/
% All rights reserved [02-09-2019].

function [ dummyBits ] = logfileread( fname )

% This function extracts the encoded bits of the dummy POCs

fid=fopen(fname);
lineCounter=1;

startingLine = 0;
dummyEndLine = 0;
while ~feof(fid)
    %disp(tline)
    tline=fgetl(fid);
    if (strfind(tline,'Layer') & strfind(tline,'POC') & startingLine ==0)
        startingLine = lineCounter;
    end
    if ((strfind(tline,'B-SLICE') | (strfind(tline,'P-SLICE'))) & dummyEndLine ==0)
        dummyEndLine = lineCounter-1;
    end
    if not(isempty(tline))
        lineCounter = lineCounter+1;
    end
    if (strfind(tline,'Bytes written to file'))
        TotalBytesLine = lineCounter;
    end
    
end
fclose(fid);

a = importfile_MVHEVC(fname,startingLine,lineCounter);
dummyFrameStats = a(:,1:4);%discard unnecessary columns
dummyFrameStats(:,5) = a(:,14);
dummyFrameStats = dummyFrameStats(1:(dummyEndLine-startingLine),:);

dummyBits = table2array(dummyFrameStats(:,5));

dummyBits=sum(dummyBits);
end