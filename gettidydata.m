function getexampledata( mouseId, csvFile, tLims, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% getexampledata( resDir, maxFreq, csvFile, tLims, saveFlag )
%
% Input:
% mouseId: mouse ID.
% maxFreq: maximu frequency to extrcat for spectrogram.
% csvFile: name of csvFile to use.
% tLims: epoch to extract around time of injection.
% saveFlag: boolean to flag whether to save the figure data. Ddefault:
% true.

% Set defaults
if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

if isempty( tLims )
    tLims = [ 300 3600 ];

end

if isempty( csvFile )
    csvFile = "abc_experiment_list.xlsm";

end

root = getrootdir( );
resDir = fullfile( root, "Results" );
masterTab = readtable( fullfile( resDir, csvFile ) );

% get experiments to load
doseSortTab = sortrows( masterTab, "dex_dose_ugperkg" );
exps2procIdx = doseSortTab.analyze == 1 & doseSortTab.mouse_id == mouseId;
exps2proc = doseSortTab.exp_id( exps2procIdx );
doses = doseSortTab.dex_dose_ugperkg( exps2procIdx );

% load dex experiment
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    thisExpIdx = masterTab.exp_id == thisExp;
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    t1 = tic;
    ephysData = loadprocdata( thisExp );
    t2 = toc( t1 );
    fprintf( 'done in %s.\n', humantime( t2 ) )
    
    tInj1 = masterTab.dex_ts_inj( thisExpIdx ) - tLims( 1 ); % epoch before
    tInj2 = masterTab.dex_ts_inj( thisExpIdx ) + tLims( 2 ); % epoch after
    tEmg = ephysData.emg.tRaw;
    idxEmg = tEmg >= tInj1 & tEmg <= tInj2;
    tEmg2plot = tEmg( idxEmg );
    emg2proc = ephysData.emg.filt( idxEmg );

    % filter and downsample emg.
    


    % Get all EEG.
    % Spec for plotting
    ts = ephysData.eeg.ts( :, 1 );
    tAllIdx = ts >= tInj1 & ts <= tInj2;
    tsAll = ts( tAllIdx );
    eegAll = ephysData.eeg.clean( tAllIdx, : );
    
    % isolate baseline and compute z-score
    tOff = masterTab.dex_ts_offline( thisExpIdx );
    tOn = masterTab.dex_ts_online( thisExpIdx );
    tBaseZIdx = ts <= tOff;
    params = struct(...
        'tapers', [ 3 5 ],...
        'Fs', ephysData.eeg.Fs( 1 ),...
        'fpass', [ 0.5 40 ],...
        'pad', 1 );
    win = [ 15 1.5 ];
    eegZAll = zeros( size( eegAll ) );
    for eegIdx = 1 : 2
        mu = mean( ephysData.eeg.clean( tBaseZIdx, eegIdx ) );
        sigma = std( ephysData.eeg.clean( tBaseZIdx, eegIdx ) );
        % sprintf( "EEG: %u, Size(eegAll) %u x %u, Size(eegZAll) %u x %u \n",...
        %     eegIdx, )
        eegZAll( :, eegIdx) = ( eegAll( :, eegIdx ) - mu ) ./ sigma;

    end

    % Get new spectrogram
    [ S, t, f ] = mtspecgramc( eegZAll, win, params );

    %% Save data for plotting to figures folder
    if saveFlag
        fprintf( "Saving figure data..." )
        info( expIdx ).expId = thisExp;
        info( expIdx ).dose = doses( expIdx );
        info( expIdx ).type = masterTab.drug{ thisExpIdx };
        info( expIdx ).injDex = masterTab.dex_ts_inj( thisExpIdx );
        info( expIdx ).injOff = tOff;
        info( expIdx ).injOn = tOn;
        
        eeg( expIdx ).all.L = eegAll( :, 1 );
        eeg( expIdx ).all.R = eegAll( :, 2 );
        eeg( expIdx ).all.t2plot = tsAll;
        eeg( expIdx ).all.ZL = eegZAll;

        emg( expIdx ).filt = emg2plot;
        emg( expIdx ).t2plot = tEmg2plot;

        spec( expIdx ).L = squeeze( S( :, :, 1 ) );
        spec( expIdx ).R = squeeze( S( :, :, 2 ) );
        spec( expIdx ).t2plot = t;
        spec( expIdx ).f2plot = f;

        f2save = "ExampleFigData.mat";
        save( fullfile( resDir, mouseId, f2save ), ...
            "info", "eeg", "spec", "emg", "-v7.3" )
        fprintf( "Done!\n" )

    end

end
disp( 'Done processing everything.' )


