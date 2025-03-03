function mdls = fitfeats( allFeats, colsIdxs )

opts = statset( 'fitglme' );
opts.MaxIter = 200;
opts.TolFun = 1e-8;

epochList = unique( allFeats{ :, 'epochOrdinal' } );
epochList( end ) = [ ]; 
nEpochs = height( epochList );
for epochIdx = 1 : nEpochs
    thisEpoch = epochList( epochIdx );
    thisTab = allFeats( allFeats.epochOrdinal == thisEpoch, : );

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
                    'Link', 'log', ...
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
