function mdls = fitfeats( timeFeats, colsIdxs )

ops = statset( 'fitglme' );
opts.MaxIter = 1000;

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

        switch col2check
            case { "rmsEmg", "df", "mf", "sef" }
                mdls( epochIdx ).( col2check ) = fitglme( tabClean,...
                    mdlFormula,...
                    'Distribution', 'Gamma',...
                    'Link', 'log',...
                    'OptimizerOptions', opts );

            case { "Pdelta", "Pspindle", "PdeltaDB", "PspindleDB" }
                mdls( epochIdx ).( col2check ) = fitglme( tabClean,...
                    mdlFormula,...
                    'Distribution', 'Normal',...
                    'Link', 'identity',...
                    'OptimizerOptions', opts );

        end


    end
    disprog( epochIdx, nEpochs, 10 )

end
