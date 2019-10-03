      @echo off


    echo "Press Any Key to Start the Simulations"
    pause > nul

      
    set W=1024
    set H=1024
    set InpSeqPath=MPVS_Sequences\Stanford\
    set PAthEncoder=EncoderExe\

    set qp=47
    	
    set InputSeq=tarot
    
    for %%i in (%qp%) do (

    call EncodingBatch.bat %%i %InputSeq% %W% %H% %InpSeqPath% %PAthEncoder%
    
    )

    echo "Press any Key to Exit the Simulations"
    pause > nul