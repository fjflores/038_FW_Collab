function plotavedosespec( doses, drug )
% Plot average spectra for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

switch lower( drug )
    case "dex"
        fLims = [ 0 40 ];
        units = 956; % micro
        fTickSkip = 10;
        tTickSkip = 10;

    case { "ket", "pro" }
        fLims = [ 0 80 ];
        units = 109; % milli
        fTickSkip = 20;
        tTickSkip = 20;

    otherwise
        fLims = [ 0 50 ];
        units = 32; % blank space
        fTickSkip = 10;
        tTickSkip = 20;

end

figure( 'Visible', 'off' )
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    expListIdx = masterTab.analyze == 1 &...
        masterTab.drug_dose_inj1 == thisDose &...
        masterTab.drug_inj1 == drug;
    expList = masterTab.exp_id( expListIdx );
    fprintf( "Processing dose %u %cg/kg...\n", thisDose, 956 )

    nExps = length( expList );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        tsInj1 = masterTab{ masterTab.exp_id == thisExp, 'ts_inj1' };
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData_" + drug + ".mat";
        load( fullfile( resDir, f2load ), "spec", "notes" );
        tabExpIdx = find( [ notes.expId ] == thisExp );

        if expIdx == 1
            t = ( spec( tabExpIdx ).t - tsInj1 ) / 60;
            f = spec( tabExpIdx ).f;

        end

        if spec( tabExpIdx ).valid( 1 ) % right now, fx is hard coded to only
            SL( :, :, expIdx ) = spec( tabExpIdx ).SL;

        else
            % avg SL (left parietal EEG), so skip if not valid
            nInvalid = nInvalid + 1;

        end

        if spec( tabExpIdx ).valid( 2 ) % right now, fx is hard coded to only
            SR( :, :, expIdx ) = spec( tabExpIdx ).SR;

        else
            % avg SL (left parietal EEG), so skip if not valid
            nInvalid = nInvalid + 1;

        end

    end

    SLdose = median( SL, 3 );
    SRdose = median( SR, 3 );

    subIdx = ( doseIdx * 2 ) - 1;
    hAx( subIdx ) = subtightplot( nDoses, 2, subIdx, opts{ : } );
    plotspecgram( SLdose, t, f, "log" )
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
    % text( xLims( 2 ) - 4, posY, sprintf( 'n = %i', nExps - nInvalid ),...
    %     'Color', 'w',...
    %     'FontWeight', 'bold',...
    %     'FontSize', 12 )
    ylabel( 'Freq. (Hz)' )

    subIdx = doseIdx * 2;
    hAx( subIdx ) = subtightplot( nDoses, 2, subIdx, opts{ : } );
    plotspecgram( SRdose, t, f, "log" )
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
    % text( xLims( 2 ) - 4, posY, sprintf( 'n = %i', nExps - nInvalid ),...
    %     'Color', 'w',...
    %     'FontWeight', 'bold',...
    %     'FontSize', 12 )
    % ylabel( 'Freq. (Hz)' )
    % clear t f SLdose SRdose

end

set( gcf, 'Visible', 'on' )
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
sgtitle( "Average spectrogram per dose")
title( hAx( 1 ), "Left EEG" )
title( hAx( 2 ), "Right EEG" )



