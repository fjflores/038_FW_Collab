function plottidydata( mouseId, drug, fLims, vars2plot )


tidyDir = fullfile( getrootdir, "Results", mouseId );
vars2load = [ vars2plot(:)', { "notes" } ];
thisData = load( fullfile( tidyDir, "TidyData.mat" ), vars2load{ : } );
nVars = length( vars2plot );
nExps = length( thisData.( vars2plot{ 1 } ) );
colors = brewermap( 2, 'Set1' );

for varIdx = 1 : nVars
    figure
    colormap magma
    thisVar = vars2plot{ varIdx };

    for plotIdx = 1 : nExps
        tInj = thisData.notes( plotIdx ).tInj1;
        
        switch thisVar
            case { "eeg", "eegZ" }
                ploteegxmouse( mouseId, drug, thisVar )

            case "emg"
                t = thisData.( thisVar )( plotIdx ).t - tInj;
                dat = thisData.( thisVar )( plotIdx ).data;
                hAx( plotIdx ) = subplot( nExps, 1, plotIdx );
                plot( t, dat, 'Color', colors( 1 , : ) )

            case { "spec", "coher" }
                if strcmp( thisVar, "spec" )
                    plotspecxmouse( mouseId, drug, fLims )

                else
                    plotcoherxmouse( mouseId, drug, fLims )

                end
                
            otherwise
                error( "Wrong variable name" )

        end

    end

end