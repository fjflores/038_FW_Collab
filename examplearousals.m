%% 2025-03-18 Follow up on NSRL meeting re: arousal periods during dex
%% Plot example saline and 50 ug/kg.

clear hAx

% doses = [ 0 10 30 50 100 150 ];
doses = [ 0 50];
% doses = 0;

% exampleTab = table( doses',...
%     [ 35; 63; 73; 36; 14; 37 ],...
%     VariableNames = { 'dose', 'expID' } );
exampleTab = table( doses',...
    [ 68; 36 ],...
    VariableNames = { 'dose', 'expID' } );
% exampleTab = table( doses',...
%     [ 68],...
%     VariableNames = { 'dose', 'expID' } );

% Plot example spec for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

yLims = [ 0.5 60 ];

figure
subP = 1;
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    thisExp = exampleTab.expID( exampleTab.dose == thisDose );
    tsInj = masterTab{ masterTab.exp_id == thisExp, 'drug_ts_inj' };
    metDat = getmetadata( thisExp );

    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    load( fullfile( resDir, f2load ), "spec", "notes", "eeg" );
    tabExpIdx = find( [ notes.expId ] == thisExp );
    Sdose( :, : ) = spec( tabExpIdx ).SL;
    eegDose = eeg( tabExpIdx ).dataL;
    
    tEeg = ( eeg( tabExpIdx ).t - tsInj ) / 60;
    tSpec = ( spec( tabExpIdx ).t - tsInj ) / 60;
    f = spec( tabExpIdx ).f;

    hAx( subP ) = subtightplot( 6, 1, doseIdx * 3 - 2 : doseIdx * 3 - 1, opts{ : } );
    imagesc( tSpec, f, pow2db( Sdose' ) )
    axis xy
    box off
    clim( [ -35 0 ] )
    ylim( yLims )
    ylabel( 'Freq. (Hz)' )
    xLims = [ tSpec( 1 ) tSpec( end ) ];
    xlim( xLims );
    % xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 1.5;
    posY = yLims( 2 ) - 5;
    ffcbar( gcf, gca, "Power (dB)" );

    if thisDose == 0
        tit = "Saline";
        % title( "Example spectrogram per dose")

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, 956 );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 12 )
    ylabel( 'Freq. (Hz)' )

    patch( [ 59.88 59.88 60.76 60.76 ], [ 0 100 100 0 ], [ 0.1 0.1 0.1 ], 'EdgeColor', 'none')
    subP = subP + 1;

    hAx( subP ) = subtightplot( 6, 1, doseIdx * 3, opts{ : } );
    artIdx = tEeg > 59.88 & tEeg < 60.76;
    eegDose( artIdx ) = 0;
    plot( tEeg, eegDose );
    ylim( [ -12 8.5 ] )
    xlim( xLims );
    box off
    subP = subP + 1;

    clear S Sdose spec info eeg eegDose


end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTick', [] )
set( hAx( [ 1 3 ] ),...
    'YTick',  0 : 10 : 50  )
% ffcbar( gcf, hAx( end - 1 ), "Power (dB)" );
set( hAx( [ 2 4 ] ),...
    'YColor', 'none')
set( hAx( 2 ),...
    'XColor', 'none' )
set( hAx( end ),...
    "XTick", 0 : 10 : 60,...
    "XTickLabel", 0 : 10 : 60 )
xlabel( hAx( end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
linkaxes( hAx, 'x' )
linkaxes( hAx( [ 1 3 ] ), 'y' )
linkaxes( hAx( [ 2 4 ] ), 'y' )
hLink = linkprop( hAx( [ 1 3 ] ), 'CLim' );


% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )

% exTs = [ -274 1432 471 1140 ]; % wake, NREM, dex A, dex B
% xline( hAx( 1 ), [ exTs( 1 : 2 ) ] / 60, 'g', { 'Wake', 'NREM' }, 'LineWidth', 2 )
% xline( hAx( 2 ), [ exTs( 1 : 2 ) ] / 60, 'g', 'LineWidth', 2 )
% xline( hAx( 3 ), [ exTs( 3 : 4 ) ] / 60, 'g', { 'Dex A', 'Dex B' }, 'LineWidth', 2 )
% xline( hAx( 4 ), [ exTs( 3 : 4 ) ] / 60, 'g', 'LineWidth', 2 )

exTs = [ 3218 1229 ]; % arousals
% exTs = [ 2092 1229 ]; % arousals
xline( hAx( 1 ), [ exTs( 1 ) exTs( 1 ) + 100 ] / 60, 'g', 'LineWidth', 2 )
xline( hAx( 2 ), [ exTs( 1 ) exTs( 1 ) + 100 ] / 60, 'g', 'LineWidth', 2 )
xline( hAx( 3 ), [ exTs( 2 ) exTs( 2 ) + 100 ] / 60, 'g', 'LineWidth', 2 )
xline( hAx( 4 ), [ exTs( 2 ) exTs( 2 ) + 100 ] / 60, 'g', 'LineWidth', 2 )


%% Plot example saline or 50 ug/kg arousals.

% doses = [ 0 10 30 50 100 150 ];
doses = [0 50 ];

% exampleTab = table( doses',...
%     [ 35; 63; 73; 36; 14; 37 ],...
%     VariableNames = { 'dose', 'expID' } );
exampleTab = table( doses',...
    [ 68; 36 ],...
    VariableNames = { 'dose', 'expID' } );

dur = 10;
exXLims = [ exTs( 1 ) exTs( 1 ) + dur; exTs( 2 ) exTs( 2 ) + dur ];
% dur = 10;
% exXLims = [ exTs( 1 ) exTs( 1 ) + dur; exTs( 2 ) exTs( 2 ) + dur;...
%     exTs( 3 ) exTs( 3 ) + dur; exTs( 4 ) exTs( 4 ) + dur ];


% Plot example spec for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

tits = { 'Wake', 'NREM', 'Dex A', 'Dex B' };
figure
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    thisExp = exampleTab.expID( exampleTab.dose == thisDose );
    tsInj = masterTab{ masterTab.exp_id == thisExp, 'drug_ts_inj' };
    metDat = getmetadata( thisExp );

    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    load( fullfile( resDir, f2load ), "emg", "notes", "eeg" );
    tabExpIdx = find( [ notes.expId ] == thisExp );
    % Sdose( :, : ) = spec( tabExpIdx ).SL;
    eegDose = eeg( tabExpIdx ).dataL;
    emgDose = emg( tabExpIdx ).data;
    
    tEeg = ( eeg( tabExpIdx ).t - tsInj );
    tEmg = ( emg( tabExpIdx ).t - tsInj );
    % tSpec = ( spec( tabExpIdx ).t - tsInj );
    % f = spec( tabExpIdx ).f;

    hAx( 2 * doseIdx - 1 ) = subtightplot( 4, 1, 2 * doseIdx - 1, opts{ : } );
    plot( tEeg, eegDose );
    ylim( [ -12 8.5 ] )
    % xlim( exXLims( 2 * doseIdx - 1, : ) );
    xlim( exXLims( doseIdx, : ) );
    box off
    % subP = subP + 1;
    set( gca, 'YColor', 'none', 'XColor', 'none' );
    % text( gca, exXLims( 2 * doseIdx - 1 ) + 0.1, 7, tits{ 2 * doseIdx - 1 },...
    %     'Color', 'k', 'FontWeight', 'Bold', 'FontSize', 12 )

    % hAx( 2 * doseIdx ) = subtightplot( 4, 1, 2 * doseIdx, opts{ : } );
    % plot( tEeg, eegDose );
    % ylim( [ -12 8.5 ] )
    % xlim( exXLims( 2 * doseIdx, : ) );
    % box off
    % % subP = subP + 1;
    % set( gca, 'YColor', 'none', 'XColor', 'none' );
    % text( gca, exXLims( 2 * doseIdx ) + 0.1, 7, tits{ 2 * doseIdx },...
    %     'Color', 'k', 'FontWeight', 'Bold', 'FontSize', 12 )

    hAx( 2 * doseIdx ) = subtightplot( 4, 1, 2 * doseIdx, opts{ : } );
    plot( tEmg, emgDose, 'k' );
    ylim( [ -1100 1100 ] )
    xlim( exXLims( doseIdx, : ) );
    box off
    % subP = subP + 1;
    % set( gca, 'YColor', 'none' );
    ylabel( sprintf( 'Amp. (%cV)', 956 ) )
   
    
    clear S Sdose spec info eeg eegDose emg emgDose

end

set( hAx( [ 2 4 ] ),...
    'XColor', 'none' )
% set( hAx( end ),...
%     'XLabel', 'Time (sec)')



% set( hAx,...
%     'FontSize', 12,...
%     'TickDir', 'out',...
%     'XTick', [] )
% set( hAx( [ 1 3 ] ),...
%     'YTick',  0 : 10 : 50  )
% ffcbar( gcf, hAx( end - 1 ), "Power (dB)" );
% set( hAx( [ 2 4 ] ),...
%     'YColor', 'none')
% set( hAx( 2 ),...
%     'XColor', 'none' )
% set( hAx( end ),...
%     "XTick", 0 : 10 : 60,...
%     "XTickLabel", 0 : 10 : 60 )
% xlabel( hAx( end ), "Time (min)" );
% set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% linkaxes( hAx, 'x' )
% linkaxes( hAx( [ 1 3 ] ), 'y' )
% linkaxes( hAx( [ 2 4 ] ), 'y' )
% hLink = linkprop( hAx( [ 1 3 ] ), 'CLim' );


% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )

