function makespecdosefig( dose, normFlag )
% Plot all specs for a given dose acros mice

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & fTab.dex_dose_ugperkg == dose;
expList = fTab.exp_id( expListIdx );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ 0 50 ];

figure( 'WindowState', 'maximized' )
colormap magma
nExps = length( expList );
csvFileSpec = "example_traces.csv";
for idxExp = 1 : nExps
    thisExp = expList( idxExp );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "ExampleFigData.mat";
    load( fullfile( resDir, f2load ), "spec", "info" );
    tsTab = readtable( fullfile( resDir, csvFileSpec ) );
    tabExpIdx = tsTab.dose == dose;
    S = spec( tabExpIdx ).L;
    t = ( spec( tabExpIdx ).t2plot - ...
        ( spec( tabExpIdx ).t2plot( 1 ) + 600 ) ) / 60;
    f = spec( tabExpIdx ).f2plot;
    
    hAx( idxExp ) = subtightplot( nExps, 1, idxExp,...
        opts{ : } );
    imagesc( t, f, pow2db( S' ) )
    axis xy
    clim( [ -35 -5 ])
    box off
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 2 ) - 5;
    tit = sprintf( '%s', metDat.subject );
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( 'Freq. (Hz)' )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : 50  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
hAx( 1 ).Title.String = sprintf( "Dose: %u %cg/kg", dose, 956 );

set( hAx( end ),...
    "XTick", [ -10 : 10 : 60 ],...
    "XTickLabel", [ -10 : 10 : 60 ] )
xlabel( hAx( end - 1 : end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )

% 
% 
% plotIdx = 1 : 2 : 2 * nExps;
% for i = 1 : nExps
%     thisSpecL = spec( i ).L;
%     thisSpecR = spec( i ).R;
%     tSpec = ( spec( i ).t2plot - ( spec( i ).t2plot( 1 ) + 300 ) ) / 60;
%     fSpec = spec( i ).f2plot;
% 
%     % Spectrogram figure
%     hAx( plotIdx( i ) ) = subtightplot( nExps, 2, plotIdx( i ),...
%         opts{ : } );
%     imagesc( tSpec, fSpec, pow2db( thisSpecL' ) )
%     axis xy
%     box off
%     clim( [ 0 35 ] )
%     xLims = get( gca, 'xlim' );
%     yLims = get( gca, 'ylim' );
%     posX = xLims( 1 ) + 0.5;
%     posY = yLims( 2 ) - 5;
%     tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
%     text( posX, posY, tit,...
%         'Color', 'w',...
%         'FontWeight', 'bold',...
%         'FontSize', 10 )
%     ylabel( "Freq. (Hz)" )
%     set( gca, 'YTick',  0 : 10 : 50  )
% 
%     % Plot EMG activation on top
%     % pos = get( hAx( plotIdx( i ) ), "Position" );
%     % hEmg = axes(...
%     %     "Position", pos, ...
%     %     "Ylim", [ 0 1 ], ...
%     %     "YAxisLocation", "right",...
%     %     "Color", "none" )
%     % plot( hEmg, emg( i ).t2plot, emg( i ).smooth, 'w' )
% 
%     hAx( plotIdx( i ) + 1 ) = subtightplot( nExps, 2, plotIdx( i ) + 1,...
%         opts{ : } );
%     imagesc( tSpec, fSpec, pow2db( thisSpecR' ) )
%     axis xy
%     box off
%     clim( [ 0 35 ] )
%     xLims = get( gca, 'xlim' );
%     yLims = get( gca, 'ylim' );
%     posX = xLims( 1 ) + 0.5;
%     posY = yLims( 2 ) - 5;
%     tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
%     text( posX, posY, tit,...
%         'Color', 'w',...
%         'FontWeight', 'bold',...
%         'FontSize', 10 )
% 
% end
% 

% 
% 
