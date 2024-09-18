function getexampledata( resDir, maxFreq, csvFile, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% [ specData, traceData ] = getexampledata( dexId, sleepId, figPath )
%
% Input:
% figPath: path to where the timestamps table is and where the data will
% be stored.
% saveFlag: boolean to flag whether to save the figure data. Ddefault:
% true.

% Set defaults
if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

% path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );


if isempty( csvFile )
    csvFile = "example_traces.csv";
    tsTab = readtable( fullfile( resDir, csvFile ) );

else
    tsTab = readtable( fullfile( resDir, csvFile ) );

end

%% load dex experiment
% allExpIdx = strcmp( tsTab.expType, 'dex' );
% expId = tsTab.expId( allExpIdx );
nExps = height( tsTab );
for expIdx = 1 : nExps
    thisExp = tsTab.expId( expIdx );
    fprintf( 'Loading exp %u...', thisExp )
    t1 = tic;
    ephysData = loadprocdata( thisExp );
    t2 = toc( t1 );
    fprintf( 'done in %s.\n', humantime( t2 ) )

    tSpec = ephysData.spec.t;
    f = ephysData.spec.f;

    tInj1 = tsTab.tInjDex( tsTab.expId == thisExp ) - 300; % 5 min before
    tInj2 = tsTab.tInjDex( tsTab.expId == thisExp ) + 900; % 10 min after
    idxSpec = tSpec >= tInj1 & tSpec <= tInj2;
    fIdx = f <= maxFreq;
    f2plot = f( fIdx );
    t2plot = tSpec( idxSpec );
    t2plot = ( t2plot - t2plot( 1 ) ) / 60;
    specL = squeeze( ephysData.spec.S( idxSpec, fIdx, 1 ) );
    specR = squeeze( ephysData.spec.S( idxSpec, fIdx, 2 ) );

    tEmg = ephysData.emg.tSmooth;
    idxEmg = tEmg >= tInj1 & tEmg <= tInj2;
    tEmg2plot = tEmg( idxEmg );
    tEmg2plot = ( tEmg2plot - tEmg2plot( 1 ) ) / 60;
    emg2plot = ephysData.emg.smooth( idxEmg );

    ts = ephysData.eeg.ts( :, 1 );
    tBase1 = tsTab.tsBase1( tsTab.expId == thisExp );
    idxBase = getepochidx( ts, tBase1, 10 );
    eegBase = ephysData.eeg.filt( idxBase, : );
    tsBase = ts( idxBase );

    tExp1 = tsTab.tsExp1( tsTab.expId == thisExp );
    idxExp = getepochidx( ts, tExp1, 10 );
    eegExp = ephysData.eeg.filt( idxExp, : );
    tsExp = ts( idxExp );

    % Pad eeg and ts vectors
    [ eegBaseL, eegExpL ] = padvectors(...
        eegBase( :, 1 ), eegExp( :, 1 ), "nans" );
    [ eegBaseR, eegExpR ] = padvectors(...
        eegBase( :, 2 ), eegExp( :, 2 ), "nans" );
    [ tsBase1, tsExp1 ] = padvectors( tsBase, tsExp, "linear" );

    %% Save data for plotting to figures folder
    if saveFlag
        fprintf( "Saving figure data..." )
        info( expIdx ).expId = thisExp;
        info( expIdx ).dose = tsTab.dose( tsTab.expId == thisExp );
        info( expIdx ).type = tsTab.expType{ tsTab.expId == thisExp };

        eeg( expIdx ).base.L = eegBaseL;
        eeg( expIdx ).base.R = eegBaseR;
        eeg( expIdx ).exp.L = eegExpL;
        eeg( expIdx ).exp.R = eegExpR;
        eeg( expIdx ).t2plot.base = tsBase1;
        eeg( expIdx ).t2plot.exp = tsExp1;

        emg( expIdx ).smooth = emg2plot;
        emg( expIdx ).t2plot = tEmg2plot;

        spec( expIdx ).L = specL;
        spec( expIdx ).R = specR;
        spec( expIdx ).t2plot = t2plot;
        spec( expIdx ).f2plot = f2plot;

        f2save = "ExampleFigData.mat";
        save( fullfile( resDir, f2save ), "info", "eeg", "emg", "spec" )

        fprintf( "Done!\n" )

    end

end


