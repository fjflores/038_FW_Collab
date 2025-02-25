function mdls = fitfeats( timeFeats, colsIdxs )

nEpochs = length( timeFeats );
for epochIdx = 1 : nEpochs
    thisTab = timeFeats( epochIdx ).featTab;

    if epochIdx == 1
        colNames = thisTab.Properties.VariableNames;

    end

    for varIdx = 1 : length( colsIdxs )
        col2check = colNames{ colsIdxs( varIdx ) };
        rows2keep = all( ~isnan( thisTab{ :, col2check } ), 2 );
        tabClean = thisTab( rows2keep, : );
        mdlFormula = sprintf(...
            '%s ~ dose + ( 1 + dose | mouseId )', col2check );
        mdls( epochIdx ).( col2check ) = fitlme( tabClean,...
            mdlFormula );

    end
    disprog( epochIdx, nEpochs, 10 )

end
