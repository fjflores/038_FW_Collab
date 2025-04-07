function plotavedosespec( doses )
% Plot average spectra for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

yLims = [ 0 40 ];

figure
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    expListIdx = masterTab.analyze == 1 &...
        masterTab.drug_dose == thisDose;
    expList = masterTab.exp_id( expListIdx );
    fprintf( "Processing dose %u %cg/kg...\n", thisDose, 956 )
    
    nExps = length( expList );
    nInvalid = 0;
    for idxExp = 1 : nExps
        thisExp = expList( idxExp );
        tsInj = masterTab{ masterTab.exp_id == thisExp, 'drug_ts_inj' };
        metDat = getmetadata( thisExp );

        if metDat.chValid( 1 ) == 0 % right now, fx is hard coded to only 
            % avg SL (left parietal EEG), so skip if not valid
            nInvalid = nInvalid + 1;
            continue
        else
            resDir = fullfile( root, "Results", metDat.subject );
            f2load = "TidyData.mat";
            load( fullfile( resDir, f2load ), "spec", "notes" );
            tabExpIdx = find( [ notes.expId ] == thisExp );
            S( :, :, idxExp ) = spec( tabExpIdx ).SL;
            Sdose( :, : ) = median( S, 3 );

            if idxExp == 1
                t = ( spec( tabExpIdx ).t - tsInj ) / 60;
                f = spec( tabExpIdx ).f;

            end

        end

        disprog( idxExp, nExps, 10 )
        
    end

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
        title( "Average spectrogram per dose")

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, 956 );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )
    text( xLims( 2 ) - 4, posY, sprintf( 'n = %i', nExps - nInvalid ),...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )
    ylabel( 'Freq. (Hz)' )

    clear S Sdose spec info
    disp( ' ' )

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