function batchtidydata( miceList, csvFile, tLims, saveFlag )

nMice = length( miceList );
for mIdx = 1 : nMice
    mouseId = miceList{ mIdx };
    gettidydata( mouseId, csvFile, tLims, saveFlag )

end
