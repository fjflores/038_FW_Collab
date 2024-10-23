function batchexampledata( miceList, maxFreq, csvFile, tLims, saveFlag )

nMice = length( miceList );
for mIdx = 1 : nMice
    mouseId = miceList{ mIdx };
    getexampledata( mouseId, maxFreq, csvFile, tLims, saveFlag )

end
