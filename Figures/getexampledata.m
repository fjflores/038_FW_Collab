function getexampledata( resDir, saveFlag )
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
f2load = "example_traces.csv";
tsTab = readtable( fullfile( resDir, f2load ) );

%% load dex experiment
dexIdx = strcmp( tsTab.expType, 'dex' );
expId = tsTab.expId( dexIdx );
nExps = length( expId );
for expIdx = 1 : nExps
    thisExp = expId( expIdx );
    fprintf( 'Loading exp %u...', thisExp )
    t1 = tic;
    ephysData = loadprocdata( thisExp );
    t2 = toc( t1 );
    fprintf( 'done in %s\n', humantime( t2 ) )

    tSpec = ephysData.spec.t;
    f = ephysData.spec.f;

    tSpec1 = tsTab.tsSpec1( dexIdx );
    tSpec2 = tsTab.tsSpec2( dexIdx );
    idxSpec = tSpec >= tSpec1 & tSpec <= tSpec2;
    fIdx = f <= 40;
    f2plot = f( fIdx );
    t2plot = tSpec( idxSpec );
    t2plot = ( t2plot - t2plot( 1 ) ) / 60;
    specL = squeeze( ephysData.spec.S( idxSpec, fIdx, 1 ) );
    specR = squeeze( ephysData.spec.S( idxSpec, fIdx, 2 ) );

    tEmg = ephysData.emg.tSmooth;
    idxEmg = tEmg >= tSpec1 & tEmg <= tSpec2;
    tEmg2plot = tEmg( idxEmg );
    tEmg2plot = ( tEmg2plot - tEmg2plot( 1 ) ) / 60;
    emg2plot = ephysData.emg.smooth( idxEmg );

    ts = ephysData.eeg.ts( :, 1 );
    tBase1 = tsTab.tsBase1( dexIdx );
    idxBase = getepochidx( ts, tBase1, 10 );
    eegBase = ephysData.eeg.filt( idxBase, : );
    tsBase = ts( idxBase );

    tDex1 = tsTab.tsDex1( dexIdx );
    idxDex = getepochidx( ts, tDex1, 10 );
    eegDex = ephysData.eeg.filt( idxDex, : );
    tsDex = ts( idxDex );

    %% Load sleep experiment
    if expIdx == nExps
        clear ephysData
        sleepIdx = strcmp( tsTab.expType, 'sleep' );
        expId = tsTab.expId( sleepIdx );
        fprintf( 'Loading exp %u...', thisExp )
        t1 = tic;
        ephysData = loadprocdata( expId );
        t2 = toc( t1 );
        fprintf( 'done in %s\n', humantime( t2 ) )

        tSleep1 = tsTab.tsBase1( sleepIdx );
        idxSleep = ts >= tSleep1 & ts <= tSleep1 + 10;
        eegSleep = ephysData.eeg.filt( idxSleep, : );
        tsSleep = ts( idxSleep );
    end

    %% Pad eeg and ts vectors
    [ eegBaseL, eegSleepL, eegDexL ] = padvectors(...
        eegBase( :, 1 ), eegSleep( :, 1 ), eegDex( :, 1 ),...
        "nans" );
    [ eegBaseR, eegSleepR, eegDexR ] = padvectors(...
        eegBase( :, 2 ), eegSleep( :, 2 ), eegDex( :, 2 ),...
        "nans" );
    [ tsBase1, tsSleep1, tsDex1 ] = padvectors( tsBase, tsSleep, tsDex,...
        "linear" );

    %% Save data for plotting to figures folder
    if saveFlag
        fprintf( "Saving figure data..." )
        eeg( expIdx ).base.L = eegBaseL;
        eeg( expIdx ).base.R = eegBaseR;
        eeg( expIdx ).dex.L = eegDexL;
        eeg( expIdx ).dex.R = eegDexR;
        eeg( expIdx ).sleep.L = eegSleepL;
        eeg( expIdx ).sleep.R = eegSleepR;
        eeg( expIdx ).t2plot.base = tsBase1;
        eeg( expIdx ).t2plot.dex = tsDex1;
        eeg( expIdx ).t2plot.sleep = tsSleep1;

        emg( expIdx ).smooth = emg2plot;
        emg( expIdx ).t2plot = tEmg2plot;

        spec( expIdx ).L = specL;
        spec( expIdx ).R = specR;
        spec( expIdx ).t2plot = t2plot;
        spec( expIdx ).f2plot = f2plot;

        f2save = "ExampleFigData.mat";
        save( fullfile( resDir, f2save ), "eeg", "emg", "spec" )

        fprintf( "Done!\n" )

    end

end


