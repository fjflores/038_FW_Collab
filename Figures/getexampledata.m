function getexampledata( presDir, saveFlag )
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

path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );
f2load = "ExampleTs.csv";
tsTab = readtable( fullfile( path2load, f2load ) );

%% load dex experiment
dexIdx = strcmp( tsTab.expType, 'dex' );
expId = tsTab.expId( dexIdx );
t1 = tic;
ephysData = loadprocdata( expId );
t2 = toc( t1 );
fprintf( 'Loading exp data took %s\n', humantime( t2 ) )

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
clear ephysData
sleepIdx = strcmp( tsTab.expType, 'sleep' );
expId = tsTab.expId( sleepIdx );
t1 = tic;
ephysData = loadprocdata( expId );
t2 = toc( t1 );
fprintf( 'Loading sleep data took %s\n', humantime( t2 ) )

tSleep1 = tsTab.tsBase1( sleepIdx );
idxSleep = ts >= tSleep1 & ts <= tSleep1 + 10;
eegSleep = ephysData.eeg.filt( idxSleep, : );
tsSleep = ts( idxSleep );

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
    eeg.base.L = eegBaseL;
    eeg.base.R = eegBaseR;
    eeg.dex.L = eegDexL;
    eeg.dex.R = eegDexR;
    eeg.sleep.L = eegSleepL;
    eeg.sleep.R = eegSleepR;
    eeg.t2plot.base = tsBase1;
    eeg.t2plot.dex = tsDex1;
    eeg.t2plot.sleep = tsSleep1;

    emg.data = emg2plot;
    emg.t2plot = tEmg2plot;

    spec.L = specL;
    spec.R = specR;
    spec.t2plot = t2plot;
    spec.f2plot = f2plot;

    f2save = "FigData.mat";
    save( fullfile( path2load, f2save ), "eeg", "emg", "spec" )

end


