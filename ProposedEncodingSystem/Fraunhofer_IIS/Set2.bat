      @echo off


    echo "Press Any Key to Start the Simulations"
    pause > nul

      
    set W=1920
    set H=1080
	
    set InpSeqPath=MPVS_Sequences\Fraunhofer_IIS\
    set PAthEncoder=EncoderExe\


    set qp=46
    	
    set InputSeq=Set2
    
    for %%i in (%qp%) do (

    call EncodingBatch.bat %%i %InputSeq% %W% %H% %InpSeqPath% %PAthEncoder%
    
    )

    echo "Press any Key to Exit the Simulations"
    pause > nul