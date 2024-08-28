function batchprocvid( expList, params, overwrite )
% BATCHPROCVID is equivalent to calling both BATCHPROCDLC and BATCHVIDTS,
% but only loads and saves each experiment once to increase efficiency.
%
% Usage:
% batchprocvid( expList, overwrite )
% batchprocvid( expList )
% 
% Input:
% expList: list of experiments to process.
% overwrite: if true, overwrites exiting data. If false, skips processing.
% 
% Output:
% Saves vidData structure to its respective file and folder.

t1 = tic;

nExps = length( expList );
failList = [];
msg = sprintf( 'Processing exp %u (%u/%u)',...
    expList( 1 ), 1, nExps );
hWait = waitbar( 0, msg, 'Name', 'Batch processing data...' );
for expIdx = 1 : nExps
    expID = expList( expIdx );
    msg = sprintf(...
        'Processing exp %u (%u/%u)',...
        expID, expIdx, nExps );
    waitbar(...
        ( expIdx - 1 ) / nExps,...
        hWait,...
        msg )

    try
        exStat = saveprocvid( expID, params, overwrite );
%         allSkipped( expIdx, 1 ) = exStat;
    
    catch me
        warning( [ 'Failed due to ',... 
            getReport( me, 'basic', 'hyperlinks', 'on' ) ] )
        failList = [ failList, expID ];
        
    end
    
    disp( ' ' )
        
end

waitbar(...
    1,...
    hWait,...
    msg )

t2 = round( toc( t1 ) );
% nSkip = sum( allSkipped );
nSuccs = nExps - length( failList );
printdoneproc( nSuccs, t2 )
warnprocfail( failList )
disp( ' ' )

pause( 2 )
delete( hWait )


end


function exitStatus = saveprocvid( expID, params, overwrite )
% SAVEPROCVID combines SAVEPROCDLC and SAVEVIDTS into a single, efficient
% function that only loads and saves the experiment once.

dateProc = datestr( now, 'yyyy-mm-dd HH:MM' );

% Define 'root' directories.
rootDir = getrootdir;
dataDir = 'Data';
resDir = 'Results';

% Get experiment metadata.
metDat = getmetadata( expID );
subject = metDat.subject;
expName = metDat.expName;
analyzeMask = metDat.analyzeMask;
expType = metDat.expType;

% Creating read and save directories.
mouseDatDir = fullfile( rootDir, dataDir, subject );
mouseResDir = fullfile( rootDir, resDir, subject );
DLCFile = strcat( expName,...
    '_vidDLC_dlcrnetms5_ephys_cohortOct16shuffle1_100000_el.csv' );
DLCDir = fullfile( mouseResDir, DLCFile );
LEDDir = fullfile( mouseDatDir, strcat( expName, '_led.csv' ) );
f2save = fullfile( mouseResDir, strcat( expName, '.mat' ) );
exitStatus = 0;

% if analyzeMask == 0
%     error( [ '%s not in list of experiments to analyze so ',...
%         'no DLC data to process.' ], expName )
% end

% Check if containing folder exists.
assert( exist( mouseResDir, 'dir' ) == 7,...
    sprintf( '%s does not exist.', mouseResDir ) )

% Check if experiment's .mat exists.
ephysData = loadprocdata( expID );

% Check if vidData exists.
try 
    warning off
    vidData = loadprocdata( expID, 'vidData' );
    warning on
    
    if isfield( vidData, 'events' ) && isfield( vidData, 'DLC' )
        fprintf( 'Exp %i''s vidData already processed. ', expID )
        if overwrite
            fprintf( 'Overwriting...\n' )
            
        else
            fprintf( 'Aborted re-processing.\n' )
            exitStatus = 1;
            return
            
        end
        
    else 
        fprintf( [ 'Exp %i''s vidData already exists but is ',...
            'incomplete, so overwriting...\n' ], expID )
        
    end
    
catch
    % Don't need to do anything if vidData doesn't yet exist.
          
end

% Pack experiment info into vidData struct.
vidData.expID = expID;
vidData.subject = subject;
vidData.schedType = expType;
vidData.laterality = uniOrBi;
vidData.consciousness = consciousness;

% Set variables that depend on experiment type.
switch expType
    case 'continuous'
        tsPerStim = 1;
        nRealStimEvs = length( stimFreqs );
        
    case 'intermittent'
        tsPerStim = 6;
        nRealStimEvs = length( stimFreqs ) * tsPerStim;
        
    otherwise
        nRealStimEvs = [];
        
end

% Load and process DLC data (see PROCESSDLCDATA and PIX2CM).
fprintf( 'Processing DLC data for exp %u...\n', expID )
[ DLCData, bodyparts ] = loaddlccsv( DLCDir );
meanBP2add = { 'head', 'body1', 'body2' };
bodyparts = [ bodyparts, meanBP2add ];
DLCData = addmeanbp( DLCData, meanBP2add );
procDLCData = processdlcdata( DLCData, bodyparts, params );
procDLCData = pix2cm( procDLCData );

% Add DLC data to vidData struct.
vidData.DLC.procDLCData = procDLCData;
vidData.DLC.bodyparts = bodyparts;
vidData.DLC.params = params;
vidData.DLC.dateProcessed = dateProc;
vidData.DLC.dateConvertPix2cm = dateProc;

% Get LED frames from led.csv (see SAVEVIDTS).
fprintf( 'Getting LED times for exp %u... ', expID )
lumDat = readtable( LEDDir, 'ReadVariableNames', false );
nFrames = length( lumDat.Var1 );
ledFrame = getledtimes( lumDat.Var1 );

% Perform checks.
if isfield( vidData, 'DLC' ) && isfield( vidData.DLC, 'procDLCData' )
    % Handle experiments with known difference in total number of frames.
    if ismember( expID, [ 13, 26 ] ) &&...
            height( vidData.DLC.procDLCData ) ~= nFrames
        vidData.DLC.procDLCData( end, : ) = [];        
    end
    
    assert( height( vidData.DLC.procDLCData ) == nFrames,...
        'DLC data and _led.csv have different number of frames.' )
    
else
    warning( [ 'vidData.DLC.procDLCData doesn''t exist so ',...
        'cannot check if DLC data and _led.csv have same ',...
        'number of frames.' ] )
    
end

% Pack LED data into vidData struct.
vidData.events.ledFrame = ledFrame;
vidData.nFrames = nFrames;
fprintf( 'Done.\n' )

% Align video and ephys timestamps (see ALIGNVIDEPHYS).
fprintf( 'Aligning video ts to ephys ts for exp %u... ',...
    expID )
[ vidTs, tsOn, tsOff, ~ ] = alignvidephys( ephysData, vidData );

% Fix event ts to only include "real" (to-analyze) stim events.
tsOnOg = tsOn;
tsOffOg = tsOff;
if expID == 26
    tsOn = tsOnOg( 2 : end );
    tsOff = tsOffOg( 2 : end );
    
elseif ~isempty( nRealStimEvs )
    tsOn = tsOnOg( 1 : nRealStimEvs );
    tsOff = tsOffOg( 1 : nRealStimEvs );

end

% Perform checks.
if ~strcmp( expType, 'titration' ) && length( tsOn ) ~= tsPerStim * length( stimFreqs )
    error( 'Uh oh! Mismatching number of epochs!' )
end

% Pack data into vidData struct.
vidData.events.tsOn = tsOn;
vidData.events.tsOff = tsOff;
vidData.events.dateProcessed = dateProc;
vidData.vidTs = vidTs;
fprintf( 'Done.\n' )

% Save processed data.
fprintf( 'Saving... ' )
try
    save( f2save, 'vidData', '-append' )
    
catch
    warning( 'Directory did not exist. Creating...' )
    mkdir( mouseResDir );
    save( f2save, 'vidData', '-append' );
    
end

fprintf( 'Done.\n' )


end

