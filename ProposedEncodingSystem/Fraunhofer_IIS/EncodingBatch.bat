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
set ICMESTR=HDCA_
set RESSTR=_%W%x%H%
set FolderPath=%~dp0
set ParentFolderPath=%~dp0..\..\


@Echo **********  Running QP %qp% Input %SEQNO% ************
@Echo ******************************************************

set ConfigName=Fraunhofer_IISConfig.cfg

set InputFolder=!SEQNO!!slash!

set Res=_%W%x%H%.yuv
set count=0
set NoOfSeq=11
set SourceWidth=%W%
set SourceHeight=%H%
set frameToencode=34


set LIST=(l0 l1 l2 l3 l4 l5 l6 l7 l8 l9 l10)

Set l0=6
Set l1=3
Set l2=1
Set l3=5
Set l4=4
Set l5=2
Set l6=8
Set l7=11
Set l8=7
Set l9=9
Set l10=10



REM ------------------------------------------------------------



echo OFF
set Input=I_

set BinFolder=Output_%SEQNO%\
set OutFolder=OutputofExperiments\


set Codec=MV-HEVC\
set BIN=.bit
set TXT=.txt
set YUV=.yuv


set InpSeqPath=%SeqPath%%InputFolder%

REM Paths where files will be generated

set CfgFile=!FolderPath!!ConfigName!
set ReconFilePath=%FolderPath%%BinFolder%%Expno%
set OutputFile=!FolderPath!!BinFolder!!EXP!!TXT!
mkdir !ReconFilePath!

set BinFile=!ReconFilePath!!EXP!!BIN!



REM Here Input and reconstruction files command is created for encoder
for %%G in %LIST% do (

set ArgnameInput=--InputFile_
set ArgnameRecon=--ReconFile_

set arghandle=!ArgnameInput!!count!
set arghandleRecon=!ArgnameRecon!!count!

set /a count+=1

set Inputname= !Input!!count!

set equalto==

set Fname=-17
set NameFile=!count!!Fname!
REM echo !Fname!
set spc= 

set Inputname=!ParentFolderPath!%InpSeqPath%!%%G!%Res%

set Reconname=%ReconFilePath%!%%G!%Res%

set InpArg=!arghandle!!equalto!!Inputname!

set ReconArg=!arghandleRecon!!equalto!!Reconname!

set  InputCommand= !InputCommand!!InpArg!!Spc!

set  ReconCommand= !ReconCommand!!ReconArg!!Spc!

)



REM Calling the Encoder with the input arguments.

REM cd\
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


cd\
set BatchFolder=BatchFiles4Experiments
set returnPath=!FolderPath!
cd returnpath

