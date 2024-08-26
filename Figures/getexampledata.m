function getexampledata( presDir )
% GETEXAMPLEDATA picks data from full experiments and saves it.
% 
% Usage:
% [ specData, traceData ] = getexampledata( dexId, sleepId, figPath )
% 
% Input:
% figPath: path to where the timestamps table is and where the data will 
% be stored.

% ccc
path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );
f2load = "ExampleTs.csv";
tsTab = readtable( fullfile( path2load, f2load ) );


% matObj = matfile( fullfile( path2load, f2load ), 'Writable', false );

% Get Spectrogram, EMG, and EEG traces
% exp 8 (10 ug/kg dex injection @ ~3150 seconds)
% baseline (awake): 2560 to 2390 seconds (2365 - 2375)
% dex stuff: 5015 to 5045 seconds (5020 - 5030)
%
% exp 1
% baseline (NREM): 3900 to 3930 seconds (3915 - 3925)
%% load dex experiment
dexIdx = strcmp( tsTab.expType, 'dex' );
expId = tsTab.expId( dexIdx );
tic
ephysData = loadprocdata( expId );
toc

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
% idxBase = ts >= tBase1 & ts <= tBase1 + 10;
idxBase = getepochidx( ts, tBase1, 10 );
eegBase = ephysData.eeg.filt( idxBase, : );
tsBase = ts( idxBase );

tDex1 = tsTab.tsDex1( dexIdx );
% idxDex = ts >= tDex1 & ts <= tDex1 + 10;
idxDex = getepochidx( ts, tDex1, 10 );
eegDex = ephysData.eeg.filt( idxDex, : );
tsDex = ts( idxDex );

%% Load sleep experiment
clear ephysData
sleepIdx = strcmp( tsTab.expType, 'sleep' );
expId = tsTab.expId( sleepIdx );
tic
ephysData = loadprocdata( expId );
toc

tSleep1 = tsTab.tsBase1( sleepIdx );
idxSleep = ts >= tSleep1 & ts <= tSleep1 + 10;
eegSleep = ephysData.eeg.filt( idxSleep, : );
tsSleep = ts( idxSleep );

%% Save data for plotting to figures folder
spec.specL = specL;
spec.specR = specR;
spec.t2plot = t2plot;
spec.f2plot = f2plot;

emg.emg2plot = emg2plot;
emg.t2plot = tEmg2plot;

eeg.eegBase = eegBase;
eeg.eegDex = eegDex;
eeg.t2plot = ( tsBase - tsBase( 1 ) ) / 60;


