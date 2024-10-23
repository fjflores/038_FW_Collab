function getexampledata( mouseId, maxFreq, csvFile, tLims, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% getexampledata( resDir, maxFreq, csvFile, tLims, saveFlag )
%
% Input:
% mouseId: mouse ID.
% maxFreq: maximu frequency to extrcat for spectrogram.
% csvFile: name of cscvFile to use.
% tLims: epoch to extract around time of injection.
% saveFlag: boolean to flag whether to save the figure data. Ddefault:
% true.

% Set defaults
if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

if isempty( tLims )
    tLims = [ 300 1800 ];

end

if isempty( csvFile )
    csvFile = "example_traces.csv";

end

root = getrootdir( );
resDir = fullfile( root, "Results", mouseId );
tsTab = readtable( fullfile( resDir, csvFile ) );

% load dex experiment
nExps = height( tsTab );
for expIdx = 1 : nExps
    thisExp = tsTab.expId( expIdx );
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    t1 = tic;
    ephysData = loadprocdata( thisExp );
    t2 = toc( t1 );
    fprintf( 'done in %s.\n', humantime( t2 ) )

    tSpec = ephysData.spec.t;
    f = ephysData.spec.f;
    
    % Spec for plotting
    tInj1 = tsTab.tInjDex( tsTab.expId == thisExp ) - tLims( 1 ); % 5 min before
    tInj2 = tsTab.tInjDex( tsTab.expId == thisExp ) + tLims( 2 ); % 10 min after
    idxSpec = tSpec >= tInj1 & tSpec <= tInj2;
    fIdx = f <= maxFreq;
    f2plot = f( fIdx );
    t2plot = tSpec( idxSpec );
    specL = squeeze( ephysData.spec.S( idxSpec, fIdx, 1 ) );
    specR = squeeze( ephysData.spec.S( idxSpec, fIdx, 2 ) );

    % Spec for normalization
    tBaseSpec = tsTab.tsBase1( tsTab.expId == thisExp );
    idxNorm = tSpec >= tBaseSpec & tSpec <= tBaseSpec + 30;
    tmp = squeeze( ephysData.spec.S( idxNorm, fIdx, 1 ) );
    spec2normL = median( tmp, 1 );

    if isfield( ephysData.emg, "smooth" )
        tEmg = ephysData.emg.tSmooth;
        idxEmg = tEmg >= tInj1 & tEmg <= tInj2;
        tEmg2plot = tEmg( idxEmg );
        emg2plot = ephysData.emg.smooth( idxEmg );

    else
        warning( " EMG does not exist. Setting to empty" )
        emg2plot = [ ];
        tEmg2plot = [ ];

    end

    ts = ephysData.eeg.ts( :, 1 );
    tAllIdx = ts >= tInj1 & ts <= tInj2;
    tsAll = ts( tAllIdx );
    eegAll = ephysData.eeg.filt( tAllIdx, : );
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
        info( expIdx ).injDex = tsTab.tInjDex( tsTab.expId == thisExp );
        info( expIdx ).injOff = tsTab.tOfflineDex( tsTab.expId == thisExp );
        info( expIdx ).injOn = tsTab.tOnlineDex( tsTab.expId == thisExp );
        
        eeg( expIdx ).all.L = eegAll( :, 1 );
        eeg( expIdx ).all.R = eegAll( :, 2 );
        eeg( expIdx ).all.t2plot = tsAll;
        eeg( expIdx ).base.L = eegBaseL;
        eeg( expIdx ).base.R = eegBaseR;
        eeg( expIdx ).base.t2plot = tsBase1;
        eeg( expIdx ).exp.L = eegExpL;
        eeg( expIdx ).exp.R = eegExpR;
        eeg( expIdx ).exp.t2plot = tsExp1;

        emg( expIdx ).smooth = emg2plot;
        emg( expIdx ).t2plot = tEmg2plot;

        spec( expIdx ).L = specL;
        spec( expIdx ).R = specR;
        spec( expIdx ).t2plot = t2plot;
        spec( expIdx ).f2plot = f2plot;
        spec( expIdx ).S2norm = spec2normL;

        f2save = "ExampleFigData.mat";
        save( fullfile( resDir, f2save ), ...
            "info", "eeg", "spec", "emg" )
        fprintf( "Done!\n" )

    end

end
disp( 'Done processing everything.' )


