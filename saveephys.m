function exitStatus = saveephys( expID, win, params, smoothEmg,...
    dateProc, overwrite )
% SAVEEPHYS reads and saves processed data from an experiment.
%
% Usage:
% exitStatus = saveephys( expID, win, params, smoothEmg, dateProc,...
% overwrite )
%
% Inputs:
% expID: experiment ID from table.
% win: window for spectrogram processing.
% params: all parameters in chronux format.
% smoothEmg: if true, smooths EMG. If false, skips smoothing.
% dateProc: timestamp for file processing.
% overwrite: if true, overwrites exiting data. If false, skips processing.
%
% Output:
% exitStatus: 0 if processing happened, 1 if processing aborted.

% Set defaults.
if nargin < 4
    smoothEmg = true;
    
end

if nargin < 5 || isempty( dateProc )
    dateProc = datestr( now, 'yyyy-mm-dd HH:MM' );
    
end

if nargin < 6
    overwrite = true;
    
end

% Define 'root' directories.
rootDir = getrootdir;
dataDir = 'Data';
resDir = 'Results';

% Get experiment metadata.
metDat = getmetadata( expID );
subject = metDat.subject;
nlynxDir = metDat.nlynxDir;
expName = metDat.expName;
analyzeMask = metDat.analyzeMask;
drugDose = metDat.dexDose;

% Creating read and save directories.
dir2read = fullfile( rootDir, dataDir, subject );
dir2save = fullfile( rootDir, resDir, subject );
f2save = fullfile( dir2save, strcat( expName, '_new.mat' ) );
exitStatus = 0;
flagAppend = false;

% Check if containing folder exists.
assert( exist( dir2read, 'dir' ) == 7,...
    sprintf( '%s does not exist.', dir2read ) )

% Check if experiment's .mat exists.
if exist( f2save, 'file' ) == 2
    fprintf( 'Exp %i''s results already gathered. ', expID )
    if overwrite
        fprintf( 'Overwriting...\n' )
        flagAppend = true;
        
    else
        fprintf( 'Aborted re-processing.\n' )
        exitStatus = 1;
        return
        
    end
    
end

% Process experiment's ephys data.
fprintf( 'Processing exp %u: %s...\n', expID, expName )
[...
    eegRaw,...
    eegFilt,...
    eegClean,...
    spec,...
    coher,...
    emgRaw,...
    emgFilt,...
    events ] = setupephys( expID, win, params, smoothEmg );

% Save experiment info to struct.
info.expID = expID;
info.subject = subject;
info.drugDose = drugDose;
info.dateProcessed = dateProc;

% Save processed data.
fprintf( 'Saving... ' )
try
    if flagAppend
        save( f2save, ...
            'coher',...
            'eegClean',...
            'eegFilt',...
            'eegRaw', ...
            'emgFilt',...
            'emgRaw',...
            'events',...
            'info',...    
            'spec',...
            '-append' );
        
    else
        save( f2save, ...
            'coher',...
            'eegClean',...
            'eegFilt',...
            'eegRaw', ...
            'emgFilt',...
            'emgRaw',...
            'events',...
            'info',...    
            'spec' );
        
    end
    
catch
    warning( 'Directory did not exist. Creating... ' )
    mkdir( dir2save );
    save( f2save,...
            'coher',...
            'eegClean',...
            'eegFilt',...
            'eegRaw', ...
            'emgFilt',...
            'emgRaw',...
            'events',...
            'info',...    
            'spec' );
    
end

fprintf( 'Done.\n' )

end

