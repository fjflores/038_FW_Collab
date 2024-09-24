%% Load relevant data.

ccc

expID = 16;
metDat = getmetadata( expID );
subj = metDat.subject;
nlynxDir = metDat.nlynxDir;
topLedFile = metDat.vidFileList{ 3 };
sideLedFile = metDat.vidFileList{ 4 };
vidTsFile = metDat.vidFileList{ 5 }; % Beginning with exp 12.
mDatDir = fullfile( getrootdir, 'Data', subj );

% Load ephys event timestamps.
ephysDat = loadprocdata( expID );
evTs = sort( [ ephysDat.events.tsOn; ephysDat.events.tsOff ] );
clear ephysDat

% Load LED CSV's.
topLed = readtable( fullfile( mDatDir, topLedFile ),...
    'ReadVariableNames', false );
sideLed = readtable( fullfile( mDatDir, sideLedFile ),...
    'ReadVariableNames', false );


%% Compare ephys log REC start time v. vid start time.

ephysLog = fileread( fullfile( mDatDir, nlynxDir, 'CheetahLogFile.txt' ) );
ephysStartTs = regexp( ephysLog,...
    [ '(?<hr>\d{2})\:(?<min>\d{2})\:(?<sec>\d{2}\.\d{3})',...
    '(?: - )\d+(?: - AcquisitionControl::StartRecording)' ],...
    'names' );

vidStartFile = readtable( fullfile( mDatDir, vidTsFile ),...
    'ReadVariableNames', false );
vidStartFile = vidStartFile.Var2{ 1 };
vidStartTs = regexp( vidStartFile,...
    '\D(?<hr>\d{2})\:(?<min>\d{2})\:(?<sec>\d{2}\.\d{4})',...
    'names' );

ephHr = str2double( ephysStartTs.hr );
ephMin = str2double( ephysStartTs.min );
ephSec = str2double( ephysStartTs.sec );
vidHr = str2double( vidStartTs.hr );
vidMin = str2double( vidStartTs.min );
vidSec = str2double( vidStartTs.sec );

startT = datetime( [ 1 1 ], [ 1 1 ], [ 1 1 ],...
    [ ephHr vidHr ], [ ephMin vidMin ], [ ephSec vidSec ] );

difRecTs = between( startT( 1 ), startT( 2 ) );
difRecTs = time( difRecTs );
difRecTs = seconds( difRecTs );


%% Get LED frames from CSV's.

% Plot LED CSV's.
figure
plot( topLed.Var1 )
title( 'Top' )

figure
plot( sideLed.Var1 )
title( 'Side' )

% Set fps.
fps = 30; % Should actually load both videos to double check this.

% Get LED frames.
ledFrames = getledtimes( topLed.Var1 ); % Testing with top led.
ledTimesRaw = ledFrames / fps - ( 1 / ( 2 * fps ) );


%% Compare offset between recorded start times (from computer clocks) to 
% offset between first TTL time and first LED time.

offset = evTs( 1 ) - ledTimesRaw( 1 );

% if abs( offset - difRecTs ) > 0.3
    warning( [ 'The difference between the recorded start ',...
        'timestamps and the offset between first TTL and first LED are',...
        ' %.2f seconds off!' ], abs( offset - difRecTs ) )
% end


%% Compare ephys event timestamps v. LED times.

% Adjust LED times to be in ephys timestamp universe.
ledTimes = ledTimesRaw + offset;

landmarks = evTs( 1 : 60 : end );
for i = 1 : length( landmarks )
 
    [ a( i, 1 ), idx( i, 1 ) ] = min( abs( ephysTs - landmarks( i ) ) );
    [ a( i, 2 ), idx( i, 2 ) ] = min( abs( ledTimesRaw - landmarks( i ) ) );
    
    if a( i, 1 ) > 0.5 || a( i, 2 ) > 0.5
        idx( i, : ) = [ nan; nan ];
    end
    
end

rows2rm = isnan( idx );
idx( rows2rm( :, 1 ), : ) = [];
actual( :, 1 ) = ephysTs( idx( :, 1 ) );
actual( :, 2 ) = ledTimesRaw( idx( :, 2 ) );
actual( :, 3 ) = actual( :, 1 ) - actual( :, 2 );

