function varargout = setupephys( expID, win, params, smoothEmg )
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

% Extract raw eeg.
eeg = cscData.data( :, 1 : 2 ); % get raw eeg data.
eegFs = cscData.Fs( :, 1 : 2 );
eegTs = ( cscData.relTs( :, 1 : 2 ) / 1e6 ) + ( 1 / eegFs( 1 ) );

% Extract raw EMG
emgTmp = cscData.data( :, 3 ); % get raw emg data.
emgFs = cscData.Fs( :, 3 );
emgTs = ( cscData.relTs( :, 3 ) / 1e6 ) + ( 1 / eegFs( 1 ) );

% Add 1/Fs to tsOn and tsOff (output from SETUPEVENTS).
tsOnCorrection = 1 / eegFs( 1 );
tsOn = tsOn + tsOnCorrection;
tsOff = tsOff + tsOnCorrection;

% Get channels names for safeguarding.
names = cscData.labels;

% Filter data below 40 Hz for ease of viewing.
% fprintf( 'Filtering data... ' )
% fBandEeg = params.filtEeg;
% eegFiltTmp = eegemgfilt( eeg, fBandEeg, eegFs( 1 ) );

% Downsample filtered eeg to ~80 Hz
fprintf( 'Downsampling EEG... ' )
eegFsFilt = 2 * params.filtEeg( 2 );     % Target sampling frequency in Hz
dnFactor = round( eegFs( 1 ) / eegFsFilt );
eegDn = downsample( eeg, dnFactor );
tEegFilt = ( 0 : length( eegDn ) - 1 ) / eegFsFilt;
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

% % Smooth EMG.
% if smoothEmg
%     fprintf( 'Smoothing EMG... ' )
%     tStart = tic;
%     [ emgAct, tAct, fpassEmg, FsSmooth ] = smoothemg( emg, emgFs );
%     tElaps = toc( tStart );
%     fprintf( 'Done. Smoothing took %s.\n', humantime( tElaps ) )
% 
% else
%     fprintf( 'Skipped smoothing EMG.\n' )
% 
% end
% 
% % tsOnOg = tsOn;
% % tsOffOg = tsOff;
  

% Create the data structures.
% info.drugDose = [];

eegRaw.data = eeg;
eegRaw.Fs = eegFs;
eegRaw.ts = eegTs;
eegRaw.names = names( 1 : 2 );
varargout{ 1 } = eegRaw;

eegFilt.data = eegDn;
eegFilt.band = params.filtEeg( 2 );
eegFilt.Fs = eegFsFilt;
eegFilt.ts = tEegFilt;
eegFilt.names = names( 1 : 2 );
varargout{ 2 } = eegFilt;

eegClean.data = cleanEEG;
eegClean.detWin = win;
eegClean.Fs = eegFs;
eegClean.ts = eegTs;
eegClean.names = names( 1 : 2 );
varargout{ 3 } = eegClean;

spec.S = cat( 3, S1, S2 );
spec.f = f;
spec.t = t;
spec.params = params;
spec.win = win;
spec.names = names( 1 : 2 );
varargout{ 4 } = spec;

coher.C = C;
coher.f = f;
coher.t = t;
coher.phi = phi;
coher.confC = confC;
coher.phistd = phistd;
coher.Cerr = Cerr;
coher.params = params;
coher.win = win;
varargout{ 5 } = coher;

emgRaw.data = emgTmp;
emgRaw.Fs = emgFs;
emgRaw.ts = emgTs;
emgRaw.names = names( 1 : 2 );
varargout{ 6 } = emgRaw;

events.tsOn = tsOn;
events.tsOff = tsOff;
varargout{ 7 } = events;

% if smoothEmg
%     emgSmooth.data = emgAct;
%     emgSmooth.ts = tAct;
%     emgSmooth.Fs = FsSmooth;
%     emgSmooth.band = fpassEmg;
%     emgSmooth.names = names( 3 );
%     varargout{ 9 } = emgSmooth;
% 
% end

fprintf( 'Done processing data.\n' )

end

