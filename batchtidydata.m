function batchtidydata( miceList, drug, csvFile, tLims, saveFlag )

totTime = 0;
nMice = length( miceList );
for mIdx = 1 : nMice
    mouseId = miceList{ mIdx };
    t1 = tic; 
    gettidydata( mouseId, drug, csvFile, tLims, saveFlag );
    totTime = totTime + toc( t1 );

end
fprintf( "Total processing took %s\n", humantime( totTime ) )


