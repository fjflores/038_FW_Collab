function batchtidydata( miceList, csvFile, tLims, saveFlag )

totTime = 0;
nMice = length( miceList );
for mIdx = 1 : nMice
    mouseId = miceList{ mIdx };
    eTime = gettidydata( mouseId, csvFile, tLims, saveFlag );
    totTime = totTime + eTime;

end
fprintf( "Total processing took %s\n", humantime( totTime ) )


