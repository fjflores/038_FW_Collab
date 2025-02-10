%% Make plot of multiple experiments with parietal spec and EMG.
% TO DO: turn into fx.

clear all

exps = [ 88 89 86 ];
doses = { '0.3' '3' '30' };
injTime = [ 1525 2404 1035 ];

for expIdx = 1 : length( exps )
    expID = exps( expIdx );
    [ spec, emg ] = loadprocdata( expID, { 'spec', 'emgRaw' } );    
    specDat{ expIdx } = spec.S( :, :, 2 );
    specT{ expIdx } = ( spec.t - injTime( expIdx ) ) / 60; 
    f = spec.f;
    emgDat{ expIdx } = emg.data;
    emgT{ expIdx } = ( emg.ts - injTime( expIdx ) ) / 60;
    
end

nDoses = length( doses );
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

figure
for doseIdx = 1 : nDoses
    thisDose = doses{ doseIdx };

    thisAxes = [ ( doseIdx * 3 - 2 ) : ( doseIdx * 3 ) ];
    hAx( thisAxes( 1 : 2 ) ) = subtightplot( 9, 1, thisAxes( 1 : 2 ), opts{ : } );
    imagesc( specT{ doseIdx }, f, pow2db( specDat{ doseIdx }' ) )
    axis xy
    ylabel( 'Freq. (Hz)' )
    hold on
    ffcbar( gcf, hAx( thisAxes( 1 ) ), 'Power (db)' );
    clim( [ 0 35 ] )
    ylim( [ 0.5 60 ] )
    xline( 0, 'k', 'LineWidth', 2 )
    text( -9, 55, sprintf( 'Dex: %s %cg/kg i.v.', thisDose, 956 ),...
        'Color', 'w', 'FontWeight', 'bold' )
    xlim( [ -10 130 ] )

    hAx( thisAxes( 3 ) ) = subtightplot( 9, 1, thisAxes( 3 ), opts{ : } );
    plot( emgT{ doseIdx }, emgDat{ doseIdx }, 'Color', [ 0.2 0.2 0.2 ] )
    ylim( [ - 1800 1800 ] )
    xlim( [ -10 130 ] )
    ylabel( 'Amp. (\muV)' )

end


%%

set( hAx( 1 : nDoses * 3 - 1 ), 'xTick', [] ) 
set( hAx, 'FontSize', 11 )
set( hAx, 'box', 'off' )

linkaxes( hAx, 'x' )
linkaxes( hAx( [ 1 2 4 5 7 8 ] ), 'y' )
hLink = linkprop( hAx( [ 1 2 4 5 7 8 ] ), 'CLim' );
linkaxes( hAx( [ 3 6 9 ] ), 'y' )


xlabel( 'Time (min)' )

colormap magma

