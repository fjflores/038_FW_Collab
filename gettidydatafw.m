function gettidydatafw( mouseId, drug, tLims, saveFlag )
% GETEXAMPLEDATA picks data from full experiments and saves it.
%
% Usage:
% gettidydata( mouseId, drug, tLims, saveFlag, csvFile )
%
% Input:
% mouseId: mouse ID.
% drug: name of the drug to extract (dex, ketamine, etc).
% tLims: epoch to extract around time of injection.
% saveFlag: boolean to flag whether to save the figure data. Default: true.
% csvFile: name of csvFile to use.
%
% Output:
% file saved to the corresponding mouse results folder.

t1 = tic;
% Set defaults
if ~exist( "tLims", "var" )
    tLims = [ 300 3600 ];

end

if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

drug = lower( string( drug ) );

root = getrootdir( );
resDir = fullfile( root, "Results" );
tab2read = fullfile( resDir, "abc_experiment_list.xlsm" );
masterTab = safereadtable( tab2read );
tab2read = fullfile( resDir, "Copy of FW_collab_exp_details.xlsx" );
fwTab = safereadtablefw( tab2read );

% get experiments to load
switch drug
    case { "combo", "combo_heatpad", "combo_w_dex", "combo_w_ket" }
        col = "pd_dose_inj1";

    case "ket"
        col = "ket_dose_inj1";

    case "dex"
        col = "dex_dose_inj1";

    otherwise
        error( fprintf( "No such drug or combo %s", drug )  )

end

doseSortTab = sortrows( fwTab, col );
exps2proc = doseSortTab.exp_id( ...
    doseSortTab.dose_msg == drug & ...
    strcmp( mouseId, doseSortTab.mouse_id ) );
% 
% if sum( exps2procIdx ) == 0
%     fprintf( ...
%         "There are no experiments to process" )
%     return
% 
% end

% exps2proc = ( exps2procIdx );
% doses = doseSortTab.drug_dose_inj1( exps2procIdx );
% dosesVp = doseSortTab.vaso_dose_inj1( exps2procIdx );

% load experiments
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    masterExpIdx = masterTab.exp_id == thisExp;
    fwExpIdx = fwTab.exp_id == thisExp;
    mouseId = masterTab.mouse_id( masterExpIdx );
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    [ eegClean, emgRaw ] = loadprocdata(...
        thisExp, { "eegClean", "emgRaw" } );
    fprintf( 'done.\n' )

    % get rid of offline to injection period.
    fprintf( " Removing pre injection period..." )
    % tOffInj1 = masterTab.ts_offline_inj1( thisExpIdx );
    tInj1 = masterTab.ts_inj1( masterExpIdx );
    % tOnInj1 = masterTab.ts_online_inj1( thisExpIdx );
    tsOrig = emgRaw.ts;
    sigs = [ eegClean.data emgRaw.data ];

    % if ~isnan( tOffInj1 ) && ~isempty( tOffInj1 )
    %     preIdx = tsOrig <= tOffInj1;
    %     postIdx = tsOrig >= tInj1;
    %     preData = sigs( preIdx, : );
    %     postData = sigs( postIdx, : );
    %     preTs = tsOrig( preIdx );
    %     postTs = tsOrig( postIdx );
    %     postWoArt = replaceartifact(...
    %         postData, postTs, [ postTs( 1 ) tOnInj1 ], 'zeros' );
    %     newSigs = cat( 1, preData, postWoArt );
    %     newTs = linspace(...
    %         preTs( 1 ) + ( tInj1 - tOffInj1 ), postTs( end ), size( newSigs, 1 ) );
    % 
    % else
    %     tOffInj1 = nan;
    %     tOnInj1 = nan;
    %     newTs = tsOrig - tInj1;
    %     newSigs = sigs;
    % 
    % end

    if ~isnan( tInj1 )
        newTs = tsOrig - tInj1;
        newSigs = sigs;
        clear sigs

    else
        error( "PD injection time is a NaN! Check." )

    end


    % Remove second injection (e.g., atipamezole) artifact time (if needed).
    % tInj2 = masterTab.ts_inj2( thisExpIdx );
    % if ~isnan( tInj2 ) || ~isempty( tInj1 )
    %     tOffInj2 = masterTab.ts_offline_inj2( thisExpIdx );
    %     tOnInj2 = masterTab.ts_online_inj2( thisExpIdx );
    %     newSigs = replaceartifact(...
    %         newSigs, newTs, [ tOffInj2 tOnInj2 ], 'zeros' );
    % 
    % else
    %     tOffInj2 = nan;
    %     tOnInj2 = nan;
    % 
    % end

    fprintf( "done.\n" )

    % Define epoch to extract
    tEpochStart = tInj1 - tLims( 1 ); % epoch before
    tEpochEnd = tInj1 + tLims( 2 ); % epoch after

    % Downsample adn filter emg
    fprintf( " Processing emg..." )
    decFactor = 3;
    chunkIdx = newTs >= tEpochStart & newTs <= tEpochEnd;
    tEmg = downsample( newTs( chunkIdx ), decFactor );
    emgTmp = eegemgfilt( newSigs( :, 3 ), [ 10 900 ], emgRaw.Fs );
    emgTmp( ~chunkIdx ) = [ ];
    analyzeEmgFlag = masterTab{ masterExpIdx, { 'analyze_EMG' } };

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
        masterTab{ masterExpIdx, { 'analyze_EEG_L', 'analyze_EEG_R' } } );

    for eegIdx = 1 : 2
        if analyzeEegFlag( eegIdx )
            eegDecTmp = decimate( eegTmp( chunkIdx, eegIdx ), decFactor );

            % if ~isnan( tOffInj1 ) && ~isempty( tOffInj1 )
            %     tBaseZIdx = tEeg <= tOffInj1;
            % 
            % else
                tBaseZIdx = tEeg <= tInj1;

            % end

            mu = mean( eegDecTmp( tBaseZIdx ) );
            sigma = std( eegDecTmp( tBaseZIdx ) );
            % sprintf( "EEG: %u, Size(eegAll) %u x %u, Size(eegZAll) %u x %u \n",...
            %     eegIdx, )
            eegZdata( :, eegIdx) = ( eegDecTmp - mu ) ./ sigma;
            eegDec( :, eegIdx ) = eegDecTmp;

        else
            fprintf( 'one bad eeg channel...')
            eegZdata( :, eegIdx ) = nan(...
                ceil( sum( chunkIdx ) ./ decFactor ), 1 );
            eegDec( :, eegIdx ) = nan(...
                ceil( sum( chunkIdx ) ./ decFactor ), 1 );

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
    [ C, phi, ~, S1, S2, tStmp, f ] = cohgramc(...
        eegZdata( :, 1 ), eegZdata( :, 2 ), params.win, params );
    tS = tStmp + tEmg( 1 );
    fprintf( "done.\n" )

    % Get emg rms values
    emgChunks = makesegments( emgFilt, emgFs, params.win );
    rmsValsRaw = sqrt( mean( emgChunks .^ 2 ) );
    rmsValsStd = minmaxscaling( rmsValsRaw );
    tRms = median( makesegments( tEmg, emgFs, params.win ), 1 );
    
    notes( expIdx ).mouseId = mouseId;
    notes( expIdx ).expId = thisExp;
    notes( expIdx ).pdDose = fwTab.pd_dose_inj1( fwExpIdx );
    notes( expIdx ).vpDose = fwTab.vaso_dose_inj1( fwExpIdx );
    notes( expIdx ).dexDose = fwTab.dex_dose_inj1( fwExpIdx );
    notes( expIdx ).ketDose = fwTab.ket_dose_inj1( fwExpIdx );
    notes( expIdx ).tInj1 = tInj1;
    % notes( expIdx ).tOffInj1 = tOffInj1;
    % notes( expIdx ).tOnInj1 = tOnInj1;
    % notes( expIdx ).doseInj2 = dosesVp( expIdx );
    % notes( expIdx ).drugInj2 = masterTab.drug_inj2{ masterExpIdx };
    % notes( expIdx ).tInj2 = tInj2;
    % notes( expIdx ).tOffInj2 = tOffInj2;
    % notes( expIdx ).tOnInj2 = tOnInj2;
    notes( expIdx ).params = params;
    notes( expIdx ).sex = masterTab.sex{ masterExpIdx };

    eeg( expIdx ).dataL = eegDec( :, 1 );
    eeg( expIdx ).dataR = eegDec( :, 2 );
    eeg( expIdx ).t = tEeg;
    eeg( expIdx ).Fs = eegFs;
    eeg( expIdx ).eegLocs = {...
        masterTab.EEG_L_location{ masterExpIdx },...
        masterTab.EEG_R_location{ masterExpIdx } };
    eeg( expIdx ).valid = analyzeEegFlag;

    eegZ( expIdx ).dataL = eegZdata( :, 1 );
    eegZ( expIdx ).dataR = eegZdata( :, 2 );
    eegZ( expIdx ).t = tEeg;
    eegZ( expIdx ).Fs = eegFs;
    eegZ( expIdx ).eegLocs = {...
        masterTab.EEG_L_location{ masterExpIdx },...
        masterTab.EEG_R_location{ masterExpIdx } };
    eegZ( expIdx ).valid = analyzeEegFlag;

    emg( expIdx ).data = emgFilt;
    emg( expIdx ).t = tEmg;
    emg( expIdx ).Fs = emgFs;
    emg( expIdx ).valid = analyzeEmgFlag;

    emgRms( expIdx ).data = rmsValsStd';
    emgRms( expIdx ).t = tRms';
    emgRms( expIdx ).Fs = mean( 1 ./ diff( tS ) );
    emgRms( expIdx ).valid = analyzeEmgFlag;

    spec( expIdx ).SL = S1;
    spec( expIdx ).SR = S2;
    spec( expIdx ).t = tS';
    spec( expIdx ).f = f';
    spec( expIdx ).params = params;
    spec( expIdx ).valid = analyzeEegFlag;

    coher( expIdx ).C = C;
    coher( expIdx ).phi = phi;
    coher( expIdx ).t = tS;
    coher( expIdx ).f = f;
    coher( expIdx ).valid = and( analyzeEegFlag( 1 ), analyzeEegFlag( 2 ) );

    clear eegZdata eegDec

end

% Save data for plotting to figures folder
if saveFlag
    fprintf( " Saving tidy data..." )
    f2save = strcat( "TidyData_", drug, ".mat" );
    save( fullfile( resDir, mouseId, f2save ), ...
        "notes", "eeg", "eegZ", "spec", "emg", "emgRms", "coher", "-v7.3" )
    fprintf( "done.\n\n" )

end

eTime = toc( t1 );
fprintf( 'Done processing %s in %s.\n\n', mouseId, humantime( eTime ) )
