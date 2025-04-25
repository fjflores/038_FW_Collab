function gettidydata( mouseId, drug, csvFile, tLims, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% gettidydata( resDir, maxFreq, csvFile, tLims, saveFlag )
%
% Input:
% mouseId: mouse ID.
% drug: name of the drug to extract (dex, ketamine, etc).
% csvFile: name of csvFile to use.
% tLims: epoch to extract around time of injection.
% saveFlag: boolean to flag whether to save the figure data. Default: true.
% 
% Output:
% file saved to the corresponding mouse results folder.

t1 = tic;
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

drug = lower( string( drug ) );

root = getrootdir( );
resDir = fullfile( root, "Results" );
tab2read = fullfile( resDir, csvFile );
opts = detectImportOptions( tab2read );
% convert string timestamps to numbers
cols2num = getcols( opts, 'ts', 'begining' );
opts = setvartype( opts, ...
    cols2num, ...
    'double' ); % Set data types for specific columns
masterTab = readtable( tab2read, opts );

% get experiments to load
doseSortTab = sortrows( masterTab, "drug_dose_inj1" );
exps2procIdx = ...
    doseSortTab.analyze == 1 & ...
    doseSortTab.mouse_id == mouseId & ...
    doseSortTab.drug_inj1 == drug;
exps2proc = doseSortTab.exp_id( exps2procIdx );
dosesInj1 = doseSortTab.drug_dose_inj1( exps2procIdx );
dosesInj2 = doseSortTab.drug_dose_inj2( exps2procIdx );

% load experiments
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    thisExpIdx = masterTab.exp_id == thisExp;
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    [ eegClean, emgRaw ] = loadprocdata(...
        thisExp, { "eegClean", "emgRaw" } );
    fprintf( 'done.\n' )
    
    % get rid of offline to injection period.
    fprintf( " Removing pre injection period..." )
    tOffInj1 = masterTab.ts_offline_inj1( thisExpIdx );
    tInj1 = masterTab.ts_inj1( thisExpIdx );
    tOnInj1 = masterTab.ts_online_inj1( thisExpIdx );
    tOffInj2 = masterTab.ts_offline_inj2( thisExpIdx );
    tInj2 = masterTab.ts_inj2( thisExpIdx );
    tOnInj1 = masterTab.ts_online_inj2( thisExpIdx );
    tsOrig = emgRaw.ts;
    sigs = [ eegClean.data emgRaw.data ];
    preIdx = tsOrig <= tOffInj1;
    postIdx = tsOrig >= tInj1;
    preData = sigs( preIdx, : );
    postData = sigs( postIdx, : );
    preTs = tsOrig( preIdx );
    postTs = tsOrig( postIdx );
    postWoArt = replaceartifact(...
        postData, postTs, [ postTs( 1 ) tOnInj1 ], 'zeros' );
    newSigs = cat( 1, preData, postWoArt );
    newTs = linspace(...
        preTs( 1 ) + ( tInj1 - tOffInj1 ), postTs( end ), size( newSigs, 1 ) );

    % Remove second injection (e.g., atipamezole) artifact time (if needed).
    tInj2 = masterTab.ts_inj2( thisExpIdx );
    if ~isnan( tInj2 )
        tOffInj2 = masterTab.ts_offline_inj2( thisExpIdx );
        tOnInj2 = masterTab.ts_online_inj2( thisExpIdx );
        newSigs = replaceartifact(...
            newSigs, newTs, [ tOffInj2 tOnInj2 ], 'zeros' );

    else
        tOffInj2 = nan;
        tOnInj2 = nan;

    end


    fprintf( "done.\n" )

    % Define epoch to extract
    tEpochStart = masterTab.ts_inj1( thisExpIdx ) - tLims( 1 ); % epoch before
    tEpochEnd = masterTab.ts_inj1( thisExpIdx ) + tLims( 2 ); % epoch after

    % Downsample adn filter emg
    fprintf( " Processing emg..." )
    decFactor = 3;
    chunkIdx = newTs >= tEpochStart & newTs <= tEpochEnd;
    tEmg = downsample( newTs( chunkIdx ), decFactor );
    emgTmp = eegemgfilt( newSigs( :, 3 ), [ 10 900 ], emgRaw.Fs );
    emgTmp( ~chunkIdx ) = [ ];
    analyzeEmgFlag = logical( masterTab{ thisExpIdx, { 'analyze_EMG' } } );

    if analyzeEmgFlag
        emgFilt = downsample( emgTmp, decFactor );

    else
        fprintf( 'bad emg channel...')
        emgFilt = nan( ceil( sum( chunkIdx ) ./ decFactor ), 1 );

    end
    fprintf( "done.\n" )
    emgFs = emgRaw.Fs ./ decFactor;

    % Downsample and filter eeg
    fprintf( " Processing eeg..." )
    decFactor = 10;
    tEeg = downsample( newTs( chunkIdx ), decFactor );
    eegTmp = eegemgfilt( newSigs( :, 1 : 2 ), [ 0.5 110 ], eegClean.Fs( 1 ) );
    eegFs = eegClean.Fs( 1 ) ./ decFactor;

    % isolate baseline and compute z-score
    analyzeEegFlag = logical(...
        masterTab{ thisExpIdx, { 'analyze_EEG_L', 'analyze_EEG_R' } } );

    for eegIdx = 1 : 2

        if analyzeEegFlag( eegIdx )
            eegFilt = decimate( eegTmp( chunkIdx, eegIdx ), decFactor );
            tBaseZIdx = tEeg <= tOffInj1;
            mu = mean( eegFilt( tBaseZIdx ) );
            sigma = std( eegFilt( tBaseZIdx ) );
            % sprintf( "EEG: %u, Size(eegAll) %u x %u, Size(eegZAll) %u x %u \n",...
            %     eegIdx, )
            eegZdata( :, eegIdx) = ( eegFilt - mu ) ./ sigma;

        else
            fprintf( 'one bad eeg channel...')
            eegZdata( :, eegIdx ) = nan( ceil( sum( chunkIdx ) ./ decFactor ), 1 );

        end

    end
    
    fprintf( "done.\n" )

    % Get new spectrogram
    fprintf( " Processing spec..." )
    params = struct(...
        'tapers', [ 3 5 ],...
        'Fs', eegFs,...
        'fpass', [ 0.5 100 ],...
        'pad', 1,...
        'win', [ 15 1.5 ] );
    % [ S, tStmp, f ] = mtspecgramc( eegZ, params.win, params );
    [ C, phi, S12, S1, S2, tStmp, f ] = cohgramc(...
        eegZdata( :, 1 ), eegZdata( :, 2 ), params.win, params );
    tS = tStmp + tEmg( 1 );
    fprintf( "done.\n" )

    notes( expIdx ).expId = thisExp;
    notes( expIdx ).doseInj1 = dosesInj1( expIdx );
    notes( expIdx ).drugInj1 = masterTab.drug_inj1{ thisExpIdx };
    notes( expIdx ).tInj1 = tInj1;
    notes( expIdx ).tOffInj1 = tOffInj1;
    notes( expIdx ).tOnInj1 = tOnInj1;
    notes( expIdx ).doseInj2 = dosesInj2( expIdx );
    notes( expIdx ).drugInj2 = masterTab.drug_inj2{ thisExpIdx };
    notes( expIdx ).tInj2 = tInj2;
    notes( expIdx ).tOffInj2 = tOffInj2;
    notes( expIdx ).tOnInj2 = tOnInj2;
    notes( expIdx ).params = params;
    notes( expIdx ).sex = masterTab.sex{ thisExpIdx };

    eeg( expIdx ).dataL = eegTmp ( :, 1 );
    eeg( expIdx ).dataR = eegTmp ( :, 2 );
    eeg( expIdx ).t = tEeg;
    eeg( expIdx ).Fs = eegFs;
    eeg( expIdx ).eegLocs = {...
        masterTab.EEG_L_location{ thisExpIdx },...
        masterTab.EEG_R_location{ thisExpIdx } };
    eeg( expIdx ).valid = analyzeEegFlag;

    eegZ( expIdx ).dataL = eegZdata( :, 1 );
    eegZ( expIdx ).dataR = eegZdata( :, 2 );
    eegZ( expIdx ).t = tEeg;
    eegZ( expIdx ).Fs = eegFs;
    eegZ( expIdx ).eegLocs = {...
        masterTab.EEG_L_location{ thisExpIdx },...
        masterTab.EEG_R_location{ thisExpIdx } };
    eegZ( expIdx ).valid = analyzeEegFlag;

    emg( expIdx ).data = emgFilt;
    emg( expIdx ).t = tEmg;
    emg( expIdx ).Fs = emgFs;
    emg( expIdx ).valid = analyzeEmgFlag;

    spec( expIdx ).SL = S1;
    spec( expIdx ).SR = S2;
    spec( expIdx ).t = tS;
    spec( expIdx ).f = f;
    spec( expIdx ).params = params;
    spec( expIdx ).valid = analyzeEegFlag;

    coher( expIdx ).C = C;
    coher( expIdx ).phi = phi;
    coher( expIdx ).t = tS;
    coher( expIdx ).f = f;
    coher( expIdx ).valid = and( analyzeEegFlag( 1 ), analyzeEegFlag( 2 ) );

    clear eegZdata

end

% Save data for plotting to figures folder
if saveFlag
    fprintf( " Saving tidy data..." )
    f2save = "TidyData.mat";
    save( fullfile( resDir, mouseId, f2save ), ...
        "notes", "eeg", "spec", "emg", "coher", "-v7.3" )
    fprintf( "done.\n\n" )

end

eTime = toc( t1 );
fprintf( 'Done processing %s in %s.\n\n', mouseId, humantime( eTime ) )
