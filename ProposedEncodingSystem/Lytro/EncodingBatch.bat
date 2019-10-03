setlocal EnableDelayedExpansion

@ECHO OFF
cls

REM ---------------- USer Input  Menu ------------------------

set qp=%~1
set SEQNO=%~2
set W=%~3
set H=%~4
set SeqPath=%~5
set PathEncoder=%~6

set XT=QP_
set slash=\
SET Exp=!XT!!qP!
set Expno=!XT!!QP!!slash!
set RESSTR=
set FolderPath=%~dp0
set ParentFolderPath=%~dp0..\..\

@ECHO ON
@Echo **********  Running QP %qp% for Input LF %SEQNO% ************
@Echo ******************************************************
@ECHO OFF

REM set the Name of Configuration File
set ConfigName=LytroConfig.cfg

set InputFolder=!SEQNO!!slash!

set Res=_%W%x%H%.yuv
set count=0
set NoOfSeq=13
set SourceWidth=%W%
set SourceHeight=%H%
set frameToencode=14

REM Define the layers of MVPS as an input for MVHEVC
set LIST=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9 l10 l11 l12)

Set l0=7
Set l1=4
Set l2=1
Set l3=6
Set l4=5
Set l5=3
Set l6=2
Set l7=10
Set l8=13
Set l9=8
Set l10=9
Set l11=11
Set l12=12

REM ------------------------------------------------------------



echo OFF


set BinFolder=Output_%SEQNO%\
set OutFolder=OutputofExperiments\

REM Setting input command handle for MVHEVC 
set Input=I_

REM Defining the extension of output files 
set BIN=.bit
set TXT=.txt
set YUV=.yuv


REM Paths where files will be generated

set CfgFile=!FolderPath!!ConfigName!
set ReconFilePath=%FolderPath%%BinFolder%%Expno%
set OutputFile=!FolderPath!!BinFolder!!EXP!!TXT!
mkdir !ReconFilePath!

set BinFile=!ReconFilePath!!EXP!!BIN!


REM Here Input and reconstruction files command is created for encoder
for %%G in %LIST% do (

REM Input command handle as suggested in HEVC user manual
set ArgnameInput=--InputFile_
set ArgnameRecon=--ReconFile_

set arghandle=!ArgnameInput!!count!
set arghandleRecon=!ArgnameRecon!!count!

set /a count+=1

set Inputname= !Input!!count!

set equalto==

set Fname=-17
set NameFile=!count!!Fname!

set spc= 

REM Setting input File name with full path
set Inputname=!ParentFolderPath!%SeqPath%%InputFolder%!%%G!%Res%

set Reconname=%ReconFilePath%!%%G!%Res%

set InpArg=!arghandle!!equalto!!Inputname!

set ReconArg=!arghandleRecon!!equalto!!Reconname!

set  InputCommand= !InputCommand!!InpArg!!Spc!

set  ReconCommand= !ReconCommand!!ReconArg!!Spc!

)


REM Calling the Encoder with the input arguments.

REM Stepping into encoder directory to run encoder file
cd !PathEncoder!

TAppEncoder_16.3_MIUN_MV_OPT_RLF.exe -c !CfgFile!  -b !BinFile! !ReconCommand! -wdt !SourceWidth! -hgt !SourceHeight! -f !frameToencode!  !InputCommand! -q !qP! > !OutputFile!


ECHO OFF

echo !OutputFilePath!
echo Input Path
echo !InputCommand!
echo Recon path
echo !ReconCommand!
echo Waqas Output path
echo !OutputFile!
echo Waqas Config File path
echo !CfgFile!
echo Waqas Bin Address
echo !BinFile!

REM Stepping out from Enocder director to the current directory of batch file
cd\
set returnPath=!FolderPath!
cd returnpath

