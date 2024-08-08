function ephysData = setupephys( expID, win, params, smoothEmg )
% SETUPEPHYS reads the csc data, processes it, and converts it
% to a matlab structure.
%
% Usage:
% ephysData = setupephys( expID, win, params, smoothEmg );
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
ephysFList = metDat.ephysFileList;

% Set Nlynx folder path.
dataPath = fullfile( rootDir, dataDir, subject, nlynxDir );

% Read Nlynx data.
fprintf( 'Reading data... ' )
cscData = readallcsc( dataPath, ephysFList );
fprintf( 'Done.\n' )

% Perform checks.
assert( isequal( cscData.Fs( 1 ), cscData.Fs( 2 ), cscData.Fs( 3 ) ),...
    'Yikes! Channels have different sampling frequencies!' )
assert( isequal( cscData.relTs( :, 1 ), cscData.relTs( :, 2 ),...
           cscData.relTs( :, 3 ) ),...
       'Uh oh! Channels'' relative timestamp vectors do not match!' )
assert( cscData.relTs( 1, 1 ) == 0, [ 'Oh no! The original relative ',...
    'timestamp vectors don''t start at zero!' ] )

% Get events from nlynx.
fprintf( 'Reading events... ' )
[ tsOn, tsOff ] = setupevents( expID );
fprintf( 'Done.\n' )

% Extract raw data.
eeg = cscData.data( :, 1 : 2 ); % get raw eeg data.
emg = cscData.data( :, 3 ); % get raw emg data.
eegFs = cscData.Fs( :, 1 : 2 );
emgFs = cscData.Fs( :, 3 );
eegTs = ( cscData.relTs( :, 1 : 2 ) / 1e6 ) + ( 1 / eegFs( 1 ) );
emgTs = ( cscData.relTs( :, 3 ) / 1e6 ) + ( 1 / eegFs( 1 ) );
tsOnCorrection = 1 / eegFs( 1 );

% Add 1/Fs to tsOn and tsOff (output from SETUPEVENTS).
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

