%% Plot example exp at each dose

% CONVERT TO FX
doses = [ 0 10 30 50 100 150 ];

exampleTab = table( doses',...
    [ 35; 63; 73; 36; 14; 37 ],...
    VariableNames = { 'dose', 'expID' } );


% Plot example spec for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

yLims = [ 0.5 40 ];

figure
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    thisExp = exampleTab.expID( exampleTab.dose == thisDose );
    tsInj1 = masterTab{ masterTab.exp_id == thisExp, 'ts_inj1' };
    metDat = getmetadata( thisExp );

    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    load( fullfile( resDir, f2load ), "spec", "notes" );
    tabExpIdx = find( [ notes.expId ] == thisExp );
    Sdose( :, : ) = spec( tabExpIdx ).SL;

    t = ( spec( tabExpIdx ).t - tsInj1 ) / 60;
    f = spec( tabExpIdx ).f;

    hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    imagesc( t, f, pow2db( Sdose' ) )
    axis xy
    box off
    clim( [ -35 -5 ] )
    ylim( yLims )
    ylabel( 'Freq. (Hz)' )
    xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 1.5;
    posY = yLims( 2 ) - 5;

    if thisDose == 0
        tit = "Saline";
        title( "Example spectrogram per dose")

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, 956 );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )
    ylabel( 'Freq. (Hz)' )

    clear S Sdose spec info

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTick', [],...
    'YTick',  0 : 10 : 30  )
ffcbar( gcf, hAx( end ), "Power (dB)" );

set( hAx( end ),...
    "XTick", -10 : 10 : 70,...
    "XTickLabel", -10 : 10 : 60 )
xlabel( hAx( end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )