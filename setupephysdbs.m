function ephysData = setupephysdbs( expID, win, params, smoothEmg )
% SETUPEPHYSDBS reads the csc data, processes it, and converts it
% to a matlab structure.
%
% Usage:
% ephysData = setupephysdbs( expID, win, params, smoothEmg );
%
% Inputs:
% expID: experiment ID from metadata table.
% win: window for spectrogram processing.
% params: parameters in chronux format.
% smoothEmg: if true, smooths EMG. If false, skips smoothing.
%
% Output:
% ephysData: matlab structure with eeg data and spectrograms.

% Define 'root' directories.
rootDir = getrootdir;
dataDir = 'Data';

% Get experiment metadata.
metDat = getmetadata( expID );
subject = metDat.subject;
nlynxDir = metDat.nlynxDir;
fList = metDat.fileList;

% Set Nlynx folder path.
dataPath = fullfile( rootDir, dataDir, subject, nlynxDir );

% Read Nlynx data.
fprintf( 'Reading data... ' )
cscData = readallcsc( dataPath, fList );
fprintf( 'Done.\n' )

% Perform checks.
assert( isequal( cscData.Fs( 1 ), cscData.Fs( 2 ), cscData.Fs( 3 ) ),...
    'Yikes! Channels have different sampling frequencies!' )
assert( isequal( cscData.relTs( :, 1 ), cscData.relTs( :, 2 ),...
           cscData.relTs( :, 3 ) ),...
       'Uh oh! Channels'' relative timestamp vectors do not match!' )
assert( cscData.relTs( 1, 1 ) == 0, [ 'Oh no! The original relative ',...
    'timestamp vectors don''t start at zero!' ] )

switch expID
    case { 6 } % Handles joined experiment.
        % Create ts vector for entire Nlynx acquisition.
        tsTotal = cscData.relTs( :, 1 );
        
        % Get event timestamps from nlynx.
        T = readevnlynx( dataPath );
        dummyTs = T.TimeStamp;
        offset = dummyTs( 1 );
        recEvents = T.TimeStamp(...
            contains( T.Type, 'Recording' ) ) - offset ;
        
        % Create custom timestamps for parts 1 and 2 of experiment.
        evIdx1 = 2 : 43;
        evIdx2 = 46 : 103;
        evTs1 = dummyTs( evIdx1, : ) - offset;
        pauseDur = recEvents( 3 ) - recEvents( 2 );
        evTs2 = ( dummyTs( evIdx2, : ) - offset ) - pauseDur;
        evTs = cat( 1, evTs1, evTs2 );
        tsOn = evTs( 1 : 2 : end ) / 1e6;
        tsOff = evTs( 2 : 2 : end ) / 1e6;

        idx = getepochidx( tsTotal, recEvents( 1 ), recEvents( 2 ) );
        eeg1 = cscData.data( idx, 1 : 2 ); % get raw eeg data.
        emg1 = cscData.data( idx, 3 ); % get raw emg data.
        ts1 = tsTotal( idx, : );
        
        idx = tsTotal > recEvents( 3 );
        eeg2 = cscData.data( idx, 1 : 2 ); % get raw eeg data.
        emg2 = cscData.data( idx, 3 ); % get raw emg data.
        ts2 = tsTotal( idx, : ) - pauseDur;
        
        % Extract raw data.
        eeg = cat( 1, eeg1, eeg2 );
        emg = cat( 1, emg1, emg2 );
        eegFs = cscData.Fs( :, 1 : 2 );
        emgFs = cscData.Fs( :, 3 );
        ts = [ ts1; ts2 ] / 1e6 + ( 1 / eegFs( 1 ) );
        eegTs = [ ts, ts ];
        emgTs = ts;
        tsOnCorrection = 1 / cscData.Fs( 1 );
        
    case { 7, 8, 9, 10 } % Handles split experiments.
        % Create ts vector for entire Nlynx acquisition (both experiments).
        tsTotal = cscData.relTs( :, 1 ) / 1e6;
        
        % Get event timestamps from nlynx.
        T = readevnlynx( dataPath );
        startsTs = T.TimeStamp( contains( T.Type, 'Starting Recording' ) );
        stopsTs = T.TimeStamp( contains( T.Type, 'Stopping Recording' ) );
        startsIdx = T.idx( contains( T.Type, 'Starting Recording' ) );
        stopsIdx = T.idx( contains( T.Type, 'Stopping Recording' ) );
        dummyTs = T.TimeStamp;
        offset1 = dummyTs( 1 );
        startsSec = ( startsTs - offset1 ) / 1e6;
        stopsSec = ( stopsTs - offset1 ) / 1e6;
        
        % Create custom timestamps for first and second experiments.
        if expID == 7 || expID == 9 % First experiment in Nlynx file.
            tsOn = ( dummyTs(...
                2 : 2 : stopsIdx( 1 ) - 2 ) - offset1 ) / 1e6;
            tsOff = ( dummyTs(...
                3 : 2 : stopsIdx( 1 ) - 1 ) - offset1 ) / 1e6;
            
            idx = getepochidx( tsTotal, startsSec( 1 ), stopsSec( 1 ) );
            thisTs = ( cscData.relTs( idx, : ) / 1e6 );
            thisTs = thisTs + ( 1 / cscData.Fs( 1 ) );
            tsOnCorrection = 1 / cscData.Fs( 1 );
            
        elseif expID == 8 || expID == 10 % Second experiment in Nlynx file.
            offset2 = startsTs( 2 );
            tsOn = ( dummyTs(...
                startsIdx( 2 ) + 1 : 2 : end - 2 ) - offset2 ) / 1e6;
            tsOff = ( dummyTs(...
                startsIdx( 2 ) + 2 : 2 : end - 1 ) - offset2 ) / 1e6;
            
            dur2ndExp = ( stopsSec( 2 ) - startsSec( 2 ) );
            idx = getepochidx( tsTotal, startsSec( 2 ), dur2ndExp );
            thisTs = ( cscData.relTs( idx, : ) / 1e6 ) - startsSec( 2 );
            tsOnCorrection = 0; % No correction needed.
            
        end
        
        % Extract raw data.
        eeg = cscData.data( idx, 1 : 2 ); % get raw eeg data.
        emg = cscData.data( idx, 3 ); % get raw emg data.
        eegFs = cscData.Fs( :, 1 : 2 );
        emgFs = cscData.Fs( :, 3 );
        eegTs = thisTs( :, 1 : 2 ); % 1/Fs already added (only to 7 & 9)
        emgTs = thisTs( :, 3 ); % 1/Fs already added (only to 7 & 9)
        
    otherwise
        % Get events from nlynx.
        fprintf( 'Reading events... ' )
        [ tsOn, tsOff ] = setupeventsdbs( expID );
        fprintf( 'Done.\n' )
        
        % Extract raw data.
        eeg = cscData.data( :, 1 : 2 ); % get raw eeg data.
        emg = cscData.data( :, 3 ); % get raw emg data.
        eegFs = cscData.Fs( :, 1 : 2 );
        emgFs = cscData.Fs( :, 3 );
        eegTs = ( cscData.relTs( :, 1 : 2 ) / 1e6 ) + ( 1 / eegFs( 1 ) );
        emgTs = ( cscData.relTs( :, 3 ) / 1e6 ) + ( 1 / eegFs( 1 ) );
        tsOnCorrection = 1 / eegFs( 1 );
        
end

% Add 1/Fs to tsOn and tsOff (output from SETUPEVENTSDBS).
tsOn = tsOn + tsOnCorrection;
tsOff = tsOff + tsOnCorrection;

% Get channels names for safeguarding.
names = cscData.labels;

% Filter data below 40 Hz for ease of viewing.
fprintf( 'Filtering data... ' )
fBandEeg = params.filtEeg;
eegFilt = eegemgfilt( eeg, fBandEeg, eegFs( 1 ) );

fBandEmg = params.filtEmg;
emgFilt = eegemgfilt( emg, fBandEmg, eegFs( 1 ) );
fprintf( 'Done.\n' )

% Detrend and remove 60 Hz artifact.
[ ~, nCh ] = size( eeg );
fprintf( 'Detrending and removing 60 Hz line... ' )
warning off
params.Fs = eegFs( 1 );
for i = 1 : nCh
    detEEG( :, i ) = locdetrend( eeg( :, i ), params.Fs, win );
    tempEEG = ffrmlinesc( detEEG( :, i ), params.Fs );
    
    % fix shorter length of clean signal
    nClean = length( tempEEG );
    missSeg = detEEG( nClean + 1 : end, i );
    cleanEEG( :, i ) = cat( 1, tempEEG, missSeg );
    
end
warning on
fprintf( 'Done.\n' )

% Compute spectrogram and coherence.
fprintf( 'Computing specgrams and coherence... ' )
[ C, phi, ~, S1, S2, t, f, confC, phistd, Cerr ] = cohgramc(...
    cleanEEG( :, 1 ), cleanEEG( :, 2 ), win, params );
fprintf( 'Done.\n' )

% Smooth EMG.
if smoothEmg
    fprintf( 'Smoothing EMG... ' )
    tStart = tic;
    [ emgAct, tAct, fpassEmg, FsSmooth ] = smoothemg( emg, emgFs );
    tElaps = toc( tStart );
    fprintf( 'Done. Smoothing took %s.\n', humantime( tElaps ) )
    
else
    fprintf( 'Skipped smoothing EMG.\n' )
    
end

tsOnOg = tsOn;
tsOffOg = tsOff;
  
% Add eeg data to structure.
ephysData.expID = [];
ephysData.subject = '';
ephysData.schedType = '';
ephysData.laterality = '';
ephysData.consciousness = '';
ephysData.eeg.raw = eeg;
ephysData.eeg.filt = eegFilt;
ephysData.eeg.filtBand = params.filtEeg;
ephysData.eeg.det = detEEG;
ephysData.eeg.detWin = win;
ephysData.eeg.clean = cleanEEG;
ephysData.eeg.Fs = eegFs;
ephysData.eeg.ts = eegTs;
ephysData.eeg.names = names( 1 : 2 );
ephysData.spec.S = cat( 3, S1, S2 );
ephysData.spec.f = f;
ephysData.spec.t = t;
ephysData.spec.params = params;
ephysData.spec.win = win;
ephysData.spec.names = names( 1 : 2 );
ephysData.coher.C = C;
ephysData.coher.phi = phi;
ephysData.coher.confC = confC;
ephysData.coher.phistd = phistd;
ephysData.coher.Cerr = Cerr;
ephysData.emg.raw = emg;
ephysData.emg.FsRaw = emgFs;
ephysData.emg.tRaw = emgTs;
ephysData.emg.filt = emgFilt;
if smoothEmg
    ephysData.emg.smooth = emgAct;
    ephysData.emg.tSmooth = tAct;
    ephysData.emg.FsSmooth = FsSmooth;
    ephysData.emg.smoothBand = fpassEmg;
end
ephysData.emg.names = names( 3 );
ephysData.events.tsOn = tsOn;
ephysData.events.tsOff = tsOff;
ephysData.events.allTsOn = tsOnOg;
ephysData.events.allTsOff = tsOffOg;

fprintf( 'Done processing data.\n' )


end

