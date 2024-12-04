function makespecdosefig( dose )
% Plot all specs for a given dose acros mice

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & fTab.drug_dose == dose & fTab.drug == "dex";
expList = fTab.exp_id( expListIdx );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ 0 40 ];

figure( 'WindowState', 'maximized' )
colormap magma
nExps = length( expList );

for idxExp = 1 : nExps
    thisExp = expList( idxExp );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    load( fullfile( resDir, f2load ), "spec", "notes" );
    % tsTab = readtable( fullfile( resDir, csvFileSpec ) );
    tabExpIdx = find( [ notes.expId ] == thisExp );
    S = spec( tabExpIdx ).SL;
    t = spec( tabExpIdx ).t ./ 60;
    f = spec( tabExpIdx ).f;
    
    hAx( idxExp ) = subtightplot( nExps, 1, idxExp, opts{ : } );
    imagesc( t, f, pow2db( S' ) )
    axis xy
    clim( [ -35 -5 ])
    box off
    xLims = get( gca, 'xlim' );
    ylim( yLims )
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
hAx( 1 ).Title.String = sprintf(...
    "Spectrograms at %u %cg/kg in each mouse", dose, 956 );

set( hAx( end ),...
    "XTick", [ -10 : 10 : 60 ],...
    "XTickLabel", [ -10 : 10 : 60 ] )
xlabel( hAx( end - 1 : end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )
