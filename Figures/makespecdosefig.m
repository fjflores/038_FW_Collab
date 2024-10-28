function makespecdosefig( dose )
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

figure
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
hAx( 1 ).Title.String = sprintf( "Dose: %u ug/kg", dose );

set( hAx( end - 1 : end ),...
    "XTick", [ -10 : 5 : 60 ],...
    "XTickLabel", [ -10 : 5 : 60 ] )
xlabel( hAx( end - 1 : end ), "time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )
