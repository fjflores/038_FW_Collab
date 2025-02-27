%% Plot an example dex exp (100 ug/kg, exp 14) to illustrate the concepts
% of dominant, median, and spectral edge frequencies.
ccc
% Gather timeseries and specs for Dex
dexInj = 2015;
expId = 28;
[ spec, emg ] = loadprocdata( expId, { 'spec', 'emgRaw' } );
tSpecDex = spec.t;
specIdx = find( tSpecDex > ( dexInj - 600 ) & tSpecDex < ( dexInj + 3300 ) );
dexSpec = squeeze( spec.S( specIdx, :, 1 ) );
tSpec = tSpecDex( specIdx );
f = spec.f;

tEmgRaw = emg.ts;
emgIdx = find( tEmgRaw > ( dexInj - 600 ) & tEmgRaw < ( dexInj + 3300 ) );
tEmg = tEmgRaw( emgIdx );

% Calculate quantitative EEG features.
% [ mf, sef, df ] = qeegspecgram( dexSpec, f, [ 0.5 18 ] );

% Plot spectrogram 3 times, to illustrate each concept.
figure
xLims = [ dexInj - 600 dexInj + 3300 ];
yLims = [ 0 30 ];
cLims = [ 0 35 ];
% freqFeats = [ df mf sef ];
tits = { '100 ug/kg Dex' };
% cols = { 'k', 'k', 'w' };
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };


% for plotIdx = 1 : 3
hAx( 1 ) = subtightplot( 3, 1, [ 1 2 ], opts{ : } );
hold on
imagesc( tSpec, f, pow2db( dexSpec' ) )
% plot( t2plotSpecDex, freqFeats( :, plotIdx ),...
%     cols{ plotIdx }, 'LineWidth', 1.5 )
axis xy
xlim( xLims )
ylim( yLims )
clim( cLims )


ylabel( 'Frequency (Hz)' )
ffcbar( gcf, gca, "Power (dB)" );
title( tits )
box off

plotBand = true;
if plotBand
    hold on
    % patch delta
    patch(...
        [ tSpec( 1 ) tSpec( 1 ) tSpec( end ) tSpec( end ) ],...
        [ 0.5 4 4 0.5 ],...
        [0.5 0.5 0.5],...
        'FaceAlpha', 0.5,...
        'EdgeColor', 'none' )

    patch(...
        [ tSpec( 1 ) tSpec( 1 ) tSpec( end ) tSpec( end ) ],...
        [ 12 18 18 12 ],...
        [0.5 0.5 0.5],...
        'FaceAlpha', 0.5,...
        'EdgeColor', 'none' )

end

hAx( 2 ) = subtightplot( 3, 1, 3, opts{ : } );
plot( tEmg, emg.data( emgIdx ), 'k' )
ylabel( 'Amp. (uV)' )
set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTick', dexInj - 600 : 600 : dexInj + 3600,...
    'XTickLabel', [ -10 : 10 : 60 ] )
xlabel( 'Time (min)' )

% compute rms
segments = makesegments( emg.data( emgIdx ), 271.3, [ 1 1 ] );
tSegs = median( makesegments( tEmg, 271.3, [ 1 1 ] ) );
rmsVals = rms( segments );

rmsPlot = true;
if rmsPlot
    hold on
    plot( tSegs, rmsVals, 'b' )

end




linkaxes( hAx, 'x' )
axis tight

colormap magma