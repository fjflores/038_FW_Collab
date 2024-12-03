function eTime = gettidydata( mouseId, csvFile, tLims, saveFlag )
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

t1 = tic;
% load dex experiment
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    thisExpIdx = masterTab.exp_id == thisExp;
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    [ eegClean, emgRaw ] = loadprocdata( thisExp, { "eegClean", "emgRaw" } );
    fprintf( 'done.\n' )
    
    % get rid of offline to injection period.
    fprintf( " Removing pre injection period..." )
    tOff = masterTab.dex_ts_offline( thisExpIdx );
    tInj = masterTab.dex_ts_inj( thisExpIdx );
    tOn = masterTab.dex_ts_online( thisExpIdx );
    tsOrig = emgRaw.ts;
    sigs = [ eegClean.data emgRaw.data ];
    preIdx = tsOrig <= tOff;
    postIdx = tsOrig >= tInj;
    preData = sigs( preIdx, : );
    postData = sigs( postIdx, : );
    preTs = tsOrig( preIdx );
    postTs = tsOrig( postIdx );
    postWoArt = replaceartifact( postData, postTs, [ postTs( 1 ) tOn ], 'zeros' );
    newSigs = cat( 1, preData, postWoArt );
    % newTs = cat( 1, , postTs );
    newTs = linspace( preTs( 1 ) + ( tInj - tOff ), postTs( end ), size( newSigs, 1 ) );
    fprintf( "done.\n" )

    % Define epoch to extract
    tEpochStart = masterTab.dex_ts_inj( thisExpIdx ) - tLims( 1 ); % epoch before
    tEpochEnd = masterTab.dex_ts_inj( thisExpIdx ) + tLims( 2 ); % epoch after

    % Downsample adn filter emg
    fprintf( " Processing emg..." )
    decFactor = 3;
    chunkIdx = newTs >= tEpochStart & newTs <= tEpochEnd;
    tEmg = downsample( newTs( chunkIdx ), decFactor ) - tInj;
    emgTmp = eegemgfilt( newSigs( :, 3 ), [ 10 900 ], emgRaw.Fs );
    emgTmp( ~chunkIdx ) = [ ];
    emgFilt = downsample( emgTmp, decFactor );
    fprintf( "done.\n" )
    emgFs = emgRaw.Fs ./ decFactor;

    % Downsample and filter eeg
    fprintf( " Processing eeg..." )
    decFactor = 10;
    tEeg = downsample( newTs( chunkIdx ), decFactor ) - tInj;
    eegTmp = eegemgfilt( newSigs( :, 1 : 2 ), [ 0.5 110 ], eegClean.Fs( 1 ) );
    eegFs = eegClean.Fs( 1 ) ./ decFactor;

    % isolate baseline and compute z-score
    for eegIdx = 1 : 2
        eegFilt = decimate( eegTmp( chunkIdx, eegIdx ), decFactor );
        tBaseZIdx = tEmg <= 0;
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
        'Fs', eegFs,...
        'fpass', [ 0.5 100 ],...
        'pad', 1 );
    win = [ 15 1.5 ];
    [ S, tStmp, f ] = mtspecgramc( eegZ, win, params );
    tS = tStmp + tEmg( 1 );
    fprintf( "done.\n" )

    info( expIdx ).expId = thisExp;
    info( expIdx ).dose = doses( expIdx );
    info( expIdx ).type = masterTab.drug{ thisExpIdx };
    info( expIdx ).injDex = masterTab.dex_ts_inj( thisExpIdx );
    info( expIdx ).injOff = tOff;
    info( expIdx ).injOn = tOn;

    eeg( expIdx ).dataL = eegZ( :, 1 );
    eeg( expIdx ).dataR = eegZ( :, 2 );
    eeg( expIdx ).t = tEeg;
    eeg( expIdx ).Fs = eegFs;

    emg( expIdx ).data = emgFilt;
    emg( expIdx ).t = tEmg;
    emg( expIdx ).Fs = emgFs;

    spec( expIdx ).SL = squeeze( S( :, :, 1 ) );
    spec( expIdx ).SR = squeeze( S( :, :, 2 ) );
    spec( expIdx ).t = tS;
    spec( expIdx ).f = f;

end

%% Save data for plotting to figures folder
if saveFlag
    fprintf( " Saving tidy data..." )
    f2save = "TidyData.mat";
    save( fullfile( resDir, mouseId, f2save ), ...
        "info", "eeg", "spec", "emg", "-v7.3" )
    fprintf( "done.\n" )

end

eTime = toc( t1 );
fprintf( 'Done processing %s in %s.\n\n', mouseId, humantime( eTime ) )


