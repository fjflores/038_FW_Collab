function hAx = plottidydata( mouseId, vars2plot )


tidyDir = fullfile( getrootdir, "Results", mouseId );
vars2load = { vars2plot{ : }, "notes" };
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
                t = thisData.( thisVar )( plotIdx ).t - tInj;
                datL = thisData.( thisVar )( plotIdx ).dataL;
                datR = thisData.( thisVar )( plotIdx ).dataR;
                
                subIdx = ( 2 * plotIdx )  - 1;
                hAx( subIdx ) = subplot( nExps, 2, subIdx );
                plot( t, datL, "Color", colors( 1, : ) );
                
                subIdx = 2 * plotIdx;
                hAx( subIdx ) = subplot( nExps, 2, subIdx );
                plot( t, datR, "Color", colors( 2, : ) );

            case "emg"
                t = thisData.( thisVar )( plotIdx ).t - tInj;
                dat = thisData.( thisVar )( plotIdx ).data;
                hAx( plotIdx ) = subplot( nExps, 1, plotIdx );
                plot( t, dat, 'Color', colors( 1 , : ) )

            case { "spec", "coher" }
                t = thisData.( thisVar )( plotIdx ).t - tInj;
                f = thisData.( thisVar )( plotIdx ).f;

                if strcmp( thisVar, "spec" )
                    datL = thisData.( thisVar )( plotIdx ).SL;
                    datR = thisData.( thisVar )( plotIdx ).SR;

                    subIdx = ( 2 * plotIdx )  - 1;
                    hAx( subIdx ) = subplot( nExps, 2, plotIdx );
                    imagesc( t, f, pow2db( datL' ) )
                    axis xy

                    subIdx = 2 * plotIdx;
                    hAx( subIdx ) = subplot( nExps, 2, plotIdx );
                    imagesc( t, f, pow2db( datR' ) )
                    axis xy

                else
                    hAx( plotIdx ) = subplot( nExps, 1, plotIdx );
                    datC = thisData.( thisVar )( plotIdx ).C;
                    imagesc( t, f, datC' )
                    axis xy

                end
                

            otherwise
                error( "Wrong variable name" )

        end

    end
    set( hAx, 'Box', 'off' )

end