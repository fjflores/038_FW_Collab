function maketracefig( eventTab )


tab = readtable( eventTab, 'ReadRowNames', 1 );

% Gather timeseries and specs for Dex
dexInj = 2015;
expId = tab{ "expID", : };
eventsDex = tab{ 4 : 7, 1 };
[ eegClean, spec ] = loadprocdata( expId, { "eegClean", "spec" } );
dataEeg = eegClean.data( :, 1 );
tEeg = eegClean.ts;
Fs = eegClean.Fs( 1 );
dataEeg = eegemgfilt( dataEeg,[ 0.1 50 ], Fs );
dexSegs = createdatamatc( dataEeg, eventsDex, Fs, [ 0 10 ], tEeg );
tSpecDex = spec.t;
specIdx = find( tSpecDex > ( dexInj - 600 ) & tSpecDex < ( dexInj + 3300 ) );
dexSpec = squeeze( spec.S( specIdx, :, 1 ) );
t2plotSpecDex = tSpecDex( specIdx );
f = spec.f;

% gather timeseries and specs for sleep
expId = tab{ "sleep_expID", : };
eventSleep = tab{ "time_NREM", : };
[ eegClean, spec ] = loadprocdata( expId, { "eegClean", "spec" } );
dataEeg = eegClean.data( :, 1 );
tEeg = eegClean.ts;
Fs = eegClean.Fs( 1 );
dataEeg = eegemgfilt( dataEeg,[ 0.1 50 ], Fs );
sleepSegs = createdatamatc( dataEeg, eventSleep, Fs, [ 0 10 ], tEeg );
tSpecSleep = spec.t;
specIdx = find( tSpecSleep > ( eventSleep - 900 ) & tSpecSleep < ( eventSleep + 600 ) );
sleepSpec = squeeze( spec.S( specIdx, :, 1 ) );
t2plotSpecSleep = tSpecSleep( specIdx );
% Set up data to plot
mat2plot = [ dexSegs sleepSegs ];


cols = repmat( 99, 1, 3 ) / 255;
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ -900 400 ];
xLims = [ 0 10 ];

% Plot figure with traces
figure
nExps = size( mat2plot, 2 );
for i = 1 : nExps
    t2plot = linspace( 0, 10, size( mat2plot, 1 ) );
    disp( [ t2plot( 1 ) t2plot( end ) ] )

    % EEG example figure
    hAx( i ) = subtightplot( 1, nExps, i,...
        opts{ : } );
    plot( t2plot, mat2plot( :, i ), 'Color', cols( 1, : ) )
    ylim( yLims )

    box off
    hold off
    xlim( xLims )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [] )
set( hAx( 1 ), 'YTick', [ -400 0 400 ] )
set( hAx( 2 : 5 ), 'YTickLabel', [] )
set( hAx, 'XTick', [] )
hAx( 1 ).YLabel.String = "Amp. (\muV)";
% set( hAx( end ),...
%     "XTick", [ 0, 2, 4, 6, 8, 10 ],...
%     "XTickLabel", [ 0, 2, 4, 6, 8, 10 ] )
hAx( end ).XLabel.String = "time (s)";
set( gcf, "Units", "normalized", "Position", [ 0.27 0.63 0.68 0.1 ] )


% Plot spectrograms
figure
yLims = [ 0 50 ];
cLims = [ 0 35 ];
hAx( 1 ) = subplot( 1, 4, 1 : 3 );
imagesc( t2plotSpecDex, f, pow2db( dexSpec' ) )
axis xy
ylim( yLims )
clim( cLims )
box off
hold on
plotevents( eventsDex, yLims, "lines" )
title( "Dexmedetomidine 100 ug/kg, M103")

hAx( 2 ) = subplot( 1, 4, 4 );
imagesc( t2plotSpecSleep, f, pow2db( sleepSpec' ) )
axis xy
ylim( yLims )
clim( cLims)
box off
set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTick', dexInj - 600 : 600 : dexInj + 3899,...
    'XTickLabel', [ -10 0  10 20 30 40 50 60 ] )
set( gcf, "Units", "normalized", "Position", [ 0.24 0.23 0.71 0.34 ] )
ffcbar( gcf, gca, "Power (dB)" )
colormap magma
plotevents( eventSleep, yLims, "lines" )
set( hAx( 2 ), 'YTickLabel', [] )