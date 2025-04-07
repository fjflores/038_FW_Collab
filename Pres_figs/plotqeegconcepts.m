%% Plot an example dex exp (100 ug/kg, exp 14) to illustrate the concepts 
% of dominant, median, and spectral edge frequencies.

% Gather timeseries and specs for Dex
dexInj = 2015;
expId = 14;
[ spec ] = loadprocdata( expId, { "spec" } );
tSpecDex = spec.t;
specIdx = find( tSpecDex > ( dexInj - 600 ) & tSpecDex < ( dexInj + 3300 ) );
dexSpec = squeeze( spec.S( specIdx, :, 1 ) );
t2plotSpecDex = tSpecDex( specIdx );
f = spec.f;

% Calculate quantitative EEG features.
[ mf, sef, df ] = qeegspecgram( dexSpec, f, [ 0.5 18 ] );

% Plot spectrogram 3 times, to illustrate each concept.
figure
xLims = [ dexInj - 600 dexInj + 3300 ];
yLims = [ 0 30 ];
cLims = [ 0 35 ];
freqFeats = [ df mf sef ];
tits = { 'Dominant Frequency',...
    'Median Frequency',...
    'Spectral Edge Frequency' };
cols = { 'k', 'k', 'w' };

for plotIdx = 1 : 3
    hAx( 1 ) = subplot( 3, 1, plotIdx );
    hold on
    imagesc( t2plotSpecDex, f, pow2db( dexSpec' ) )
    plot( t2plotSpecDex, freqFeats( :, plotIdx ),...
        cols{ plotIdx }, 'LineWidth', 1.5 )
    axis xy
    xlim( xLims )
    ylim( yLims )
    clim( cLims )
    if plotIdx == 3
        xlabel( 'Time (min)' )
    end
    ylabel( 'Frequency (Hz)' )
    ffcbar( gcf, gca, "Power (dB)" );
    set( hAx,...
        'FontSize', 12,...
        'TickDir', 'out',...
        'XTick', dexInj - 600 : 600 : dexInj + 3600,...
        'XTickLabel', [ -10 : 10 : 60 ] )
    title( tits{ plotIdx } )
    box off

end

colormap magma