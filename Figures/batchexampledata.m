function batchexampledata( miceList, csvFile, tLims, saveFlag )

nMice = length( miceList );
for mIdx = 1 : nMice
    mouseId = miceList{ mIdx };
    getexampledata( mouseId, csvFile, tLims, saveFlag )

end
