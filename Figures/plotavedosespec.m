function plotavedosespec( doses )
% Plot average spectra for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

yLims = [ 0 40 ];

figure
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    expListIdx = fTab.analyze == 1 & fTab.dex_dose_ugperkg == thisDose;
    expList = fTab.exp_id( expListIdx );
    
    nExps = length( expList );
    csvFileSpec = "example_traces.csv";
    for idxExp = 1 : nExps
        thisExp = expList( idxExp );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "ExampleFigData.mat";
        load( fullfile( resDir, f2load ), "spec", "info" );
        tsTab = readtable( fullfile( resDir, csvFileSpec ) );
        tabExpIdx = tsTab.dose == thisDose;
        S( :, :, idxExp ) = spec( tabExpIdx ).L;
        Sdose( :, : ) = median( S, 3 );

        if idxExp == 1
            t = ( spec( tabExpIdx ).t2plot - ...
            ( spec( tabExpIdx ).t2plot( 1 ) + 600 ) ) / 60;
            f = spec( tabExpIdx ).f2plot;

        end
        
    end

    hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    imagesc( t, f, pow2db( Sdose' ) )
    axis xy
    box off
    clim( [ -35 0 ] )
    ylabel( 'Freq. (Hz)' )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 2 ) - 5;
    tit = sprintf( "Dose: %u %cg/kg", thisDose, 956 );
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( 'Freq. (Hz)' )

    clear S Sdose

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : 40  )
ffcbar( gcf, hAx( end ), "Power (dB)" );

set( hAx( end ),...
    "XTick", [ -10 : 5 : 60 ],...
    "XTickLabel", [ -10 : 5 : 60 ] )
xlabel( hAx( end - 1 : end ), "time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )