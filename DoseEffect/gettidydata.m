function gettidydata( mouseId, csvFile, tLims, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% getexampledata( resDir, maxFreq, csvFile, tLims, saveFlag )
%
% Input:
% mouseId: mouse ID.
% csvFile: name of csvFile to use.
% tLims: epoch to extract around time of injection.
% saveFlag: boolean to flag whether to save the figure data. Default: true.

% Set defaults
if ~exist( "csvFile", "var" )
    csvFile = "abc_experiment_list.xlsm";

end

if ~exist( "tLims", "var" )
    tLims = [ 300 3600 ];

end

if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

root = getrootdir( );
resDir = fullfile( root, "Results" );
masterTab = readtable( fullfile( resDir, csvFile ) );

% get experiments to load
doseSortTab = sortrows( masterTab, "drug_dose" );
exps2procIdx = ...
    doseSortTab.analyze == 1 & ...
    doseSortTab.mouse_id == mouseId & ...
    doseSortTab.drug == "dex";
exps2proc = doseSortTab.exp_id( exps2procIdx );
doses = doseSortTab.drug_dose( exps2procIdx );

% load dex experiment
t1 = tic;
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    thisExpIdx = masterTab.exp_id == thisExp;
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    [ eegRaw, emgRaw ] = loadprocdata( thisExp, { "eegClean", "emgRaw" } );
    fprintf( 'done.\n' )

    tInj1 = masterTab.dex_ts_inj( thisExpIdx ) - tLims( 1 ); % epoch before
    tInj2 = masterTab.dex_ts_inj( thisExpIdx ) + tLims( 2 ); % epoch after

    % Downsample adn filter emg
    fprintf( " Processing emg..." )
    decFactor = 3;
    chunkIdx = emgRaw.ts >= tInj1 & emgRaw.ts <= tInj2;
    tEmg = decimate( emgRaw.ts( chunkIdx ), decFactor );
    emgTmp = eegemgfilt( emgRaw.data, [ 10 900 ], emgRaw.Fs );
    emgTmp( ~chunkIdx ) = [ ];
    emgFilt = decimate( emgTmp, decFactor );
    fprintf( "done.\n" )

    % Downsample and filter eeg
    fprintf( " Processing eeg..." )
    decFactor = 10;
    tEeg = decimate( emgRaw.ts( chunkIdx ), decFactor );
    eegTmp = eegemgfilt( eegRaw.data, [ 0.5 100 ], eegRaw.Fs );

    % isolate baseline and compute z-score
    tOff = masterTab.dex_ts_offline( thisExpIdx );
    tOn = masterTab.dex_ts_online( thisExpIdx );

    % eegZ = zeros( size( eegFilt ) );
    for eegIdx = 1 : 2
        eegFilt = decimate( eegTmp( chunkIdx, eegIdx ), decFactor );
        tBaseZIdx = tEmg <= tOff;
        mu = mean( eegFilt( tBaseZIdx ) );
        sigma = std( eegFilt( tBaseZIdx ) );
        % sprintf( "EEG: %u, Size(eegAll) %u x %u, Size(eegZAll) %u x %u \n",...
        %     eegIdx, )
        eegZ( :, eegIdx) = ( eegFilt - mu ) ./ sigma;

    end
    fprintf( "done.\n" )

    % Get new spectrogram
    fprintf( " Processing spec..." )
    params = struct(...
        'tapers', [ 3 5 ],...
        'Fs', eegRaw.Fs( 1 ),...
        'fpass', [ 0.5 100 ],...
        'pad', 1 );
    win = [ 15 1.5 ];
    [ S, t, f ] = mtspecgramc( eegZ, win, params );
    fprintf( "done.\n" )

    info( expIdx ).expId = thisExp;
    info( expIdx ).dose = doses( expIdx );
    info( expIdx ).type = masterTab.drug{ thisExpIdx };
    info( expIdx ).injDex = masterTab.dex_ts_inj( thisExpIdx );
    info( expIdx ).injOff = tOff;
    info( expIdx ).injOn = tOn;

    eeg( expIdx ).L = eegZ( :, 1 );
    eeg( expIdx ).R = eegZ( :, 2 );
    eeg( expIdx ).t = tEeg;

    emg( expIdx ).filt = emgFilt;
    emg( expIdx ).t = tEmg;

    spec( expIdx ).L = squeeze( S( :, :, 1 ) );
    spec( expIdx ).R = squeeze( S( :, :, 2 ) );
    spec( expIdx ).t = t;
    spec( expIdx ).f = f;

end

%% Save data for plotting to figures folder
if saveFlag
    fprintf( " Saving tidy data..." )
    f2save = "TidyData.mat";
    save( fullfile( resDir, mouseId, f2save ), ...
        "info", "eeg", "spec", "emg", "-v7.3" )
    fprintf( "done.\n\n" )

end

fprintf( 'Done processing %s in %s.\n', mouseId, toc( t1 ) )


