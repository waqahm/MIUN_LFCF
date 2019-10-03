      @echo off


    echo "Press Any Key to Start the Simulations"
    pause > nul

      
    set W=624
    set H=434 
    set InpSeqPath=MPVS_Sequences\Lytro\
    set PAthEncoder=EncoderExe\

    set qp=45
    	
    set InputSeq=Bikes
    
    for %%i in (%qp%) do (

    call EncodingBatch.bat %%i %InputSeq% %W% %H% %InpSeqPath% %PAthEncoder%
    
    )

    echo "Press any Key to Exit the Simulations"
    pause > nul