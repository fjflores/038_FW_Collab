function [ tsOn, tsOff ] = setupevents( expID )
% SETUPEVENTS offsets and labels nlynx events.

% Get nlynx directory.
metDat = getmetadata( expID );
subject = metDat.subject;
nlynxDir = metDat.nlynxDir;
dataPath = fullfile( getrootdir, 'Data', subject, nlynxDir );

% Get event timestamps from nlynx
T = readevnlynx( dataPath );
dummyTs = T.TimeStamp;
offset = dummyTs( 1 );
tsOn = ( dummyTs( 2 : 2 : end - 2 ) - offset ) / 1e6;
tsOff = ( dummyTs( 3 : 2 : end - 1 ) - offset ) / 1e6;











