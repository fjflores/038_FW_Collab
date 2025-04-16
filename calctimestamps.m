%% Little script to calculate timestamps in seconds based on times written
% in hh:mm:ss format.

% ccc

expID = 135;
dexTime = "5:22:50";
atiTime = "4:19:40";

% Get actual REC timestamp.
metDat = getmetadata( expID );
subj = metDat.subject;
nlynxDir = metDat.nlynxDir;
mDatDir = fullfile( getrootdir, 'Data', subj );

ephysLog = fileread( fullfile( mDatDir, nlynxDir, 'CheetahLogFile.txt' ) );
ephysRecTs = regexp( ephysLog,...
    [ '(\d{2})\:(\d{2})\:(\d{2}\.\d{3})',...
    '(?: - )\d+(?: - AcquisitionControl::StartRecording)' ],...
    'tokens' );
ephysRecTs = str2double( ephysRecTs{ : } );

% Calculate dex and ati injection timestamps.

% If want to input manually.
% rec = datetime( 1, 1, 1, 13, 36, 15 ); 
% dex = datetime( 1, 1, 1, 15, 47, 45 );
% ati = datetime( 1, 1, 1, 16, 48, 15 );

rec = datetime( 1, 1, 1,...
    ephysRecTs( 1 ), ephysRecTs( 2 ), ephysRecTs( 3 ) );
dexTmp = regexp( dexTime, "(\d+):(\d{2}):(\d{2})", "tokens" );
dexTmp = str2double( dexTmp{ : } );
if dexTmp( 1 ) < 10
    dexTmp( 1 ) = dexTmp( 1 ) + 12;
end
dex = datetime( 1, 1, 1,... 
    dexTmp( 1 ), dexTmp( 2 ), dexTmp( 3 ) );
atiTmp = regexp( atiTime, "(\d+):(\d{2}):(\d{2})", "tokens" );
atiTmp = str2double( atiTmp{ : } );
if atiTmp( 1 ) < 10
    atiTmp( 1 ) = atiTmp( 1 ) + 12;
end
ati = datetime( 1, 1, 1,... 
    atiTmp( 1 ), atiTmp( 2 ), atiTmp( 3 ) );

difDex = between( rec, dex );
difDex = time( difDex );
difDex = round( seconds( difDex ) );

difAti = between( rec, ati );
difAti = time( difAti );
difAti = round( seconds( difAti ) );

tsInj = [ difDex, difAti ];
fprintf( 'Dex: %i; Ati: %i\n', difDex, difAti )