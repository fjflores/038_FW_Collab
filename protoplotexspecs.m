rootDir = getrootdir;
resDir = fullfile( rootDir, 'Results' );

csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( resDir, csvFileMaster ) );

expList = [ 132 178 189 176 ];
drug = "ket";

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

fLims = [ 0 80 ];
        units = 109; % milli
        fTickSkip = 20;
        tTickSkip = 20;
nExps = length( expList );

figure
colormap magma
for expIdx = 1 : nExps
    thisExp = expList( expIdx );
    tsInj1 = masterTab{ masterTab.exp_id == thisExp, 'ts_inj1' };
    thisDose = masterTab{ masterTab.exp_id == thisExp, 'drug_dose_inj1' };
    metDat = getmetadata( thisExp );
    mouse = metDat.subject;
    f2load = "TidyData_" + drug + ".mat";
    load( fullfile( resDir, mouse, f2load ), "spec", "notes" );
    tabExpIdx = find( [ notes.expId ] == thisExp );

    t = ( spec( tabExpIdx ).t - tsInj1 ) / 60;
            f = spec( tabExpIdx ).f;
            SL = spec( tabExpIdx ).SL;
            SR = spec( tabExpIdx ).SR;

subIdx = expIdx * 2 - 1;
            hAx( subIdx ) = subtightplot( nExps, 2, subIdx, opts{ : } );
    plotspecgram( SL, t, f, "log" )
    box off
    clim( [ -35 -5 ] )
    ylim( fLims )
    ylabel( 'Freq. (Hz)' )
    xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 1.5;
    posY = fLims ( 2 ) - 5;

    if thisDose == 0
        tit = "Saline";
        title( "Average spectrogram per dose")

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, units );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )

    ylabel( 'Freq. (Hz)' )

    subIdx = expIdx * 2;
    hAx( subIdx ) = subtightplot( nExps, 2, subIdx, opts{ : } );
    plotspecgram( SR, t, f, "log" )
    box off
    clim( [ -35 -5 ] )
    ylim( fLims  )
    xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 1.5;
    posY = fLims ( 2 ) - 5;

    if thisDose == 0
        tit = "Saline";

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, units );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )



end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTick', [],...
    'YTick', [] );
set( hAx( 1 : 2 : end ), 'YTick', 0 : fTickSkip : fLims( 2 ) - fTickSkip );

set( hAx( end - 1 : end ),...
    "XTick", -tTickSkip : tTickSkip : t( end ) ); 
xlabel( hAx( end - 1 : end ), "Time (min)" );
ffcbar( gcf, hAx( end ), "Power (dB)" );

% set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.37 0.33 0.48 0.50 ] )
title( hAx( 1 ), "Parietal EEG" )
title( hAx( 2 ), "Frontal EEG" )