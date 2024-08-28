function [ vidTs, tsOn, tsOff, lm ] = alignvidephys( ephysData,...
    vidData, check )
% ALIGNVIDEPHYS aligns video timestamps to ephys timestamps.
% 
% Usage:
% [ vidTs, tsOn, tsOff, lm ] = alignvidephys( ephysData, vidData )
% [ vidTs, tsOn, tsOff, lm ] = alignvidephys( ephysData, vidData, check )
% 
% Input:
% ephysData: structure with processed ephys data.
% vidData: structure with processed video data.
% check: Optional. if true, plots the aligned emg and snout speed. Default:
% false.
% 
% Output:
% vidTs: video timestamps aligned to electrophysiology.
% tsOn: timestamps at which led goes on in the video.
% tsOff: timestamps at which led goes off in the video.
% lm: linear regression model of offset and drift.

% Set default check to false.
if nargin < 3
    check = false;
    
end

% get ephys and video events for alignment
if isfield( ephysData.events, 'allTsOn' )
    ledEphys = sort( [ ephysData.events.allTsOn;...
        ephysData.events.allTsOff ] );
else
    ledEphys = sort( [ ephysData.events.tsOn;...
        ephysData.events.tsOff ] );
end
ledFrame = sort( vidData.events.ledFrame( : ) );
nFrames = vidData.nFrames;

% Define fps. Checked for every video, and it is the same.
fps = 30;

% create video timestamps and extract event times
dtVid = 1 / fps;
videoTsRaw = ( 1 : nFrames ) * dtVid;
ledVideo = videoTsRaw( ledFrame );

if isequal( length( ledEphys ), length( ledVideo ) )
    % get offset and possibly drift.
    lm = fitlm( ledVideo, ledEphys );
    vidTs = lm.predict( videoTsRaw' );
    
else
   warning( [ 'Aborted video ts alignment. Cannot run fitlm because ',...
       'ephys has %i and video has %i total events.' ],...
       length( ledEphys ), length( ledVideo ) );
    return

end

% Perform check to determine if video was started ~30 sec after ephys
% recording.
if vidTs( 1 ) < 25 || vidTs( 1 ) > 35
    warning( 'Video was started %.f sec after ephys recording.',...
        vidTs( 1 ) )
end

% get led on and off times just like in ephys.
ledTs = vidTs( ledFrame ) - ( dtVid / 2 ); % correct ledTs so are halfway 
% between ts of ledFrame and preceding frame
tsOn = ledTs( 1 : 2 : end );
tsOff = ledTs( 2 : 2 : end );

if check
    % Plot to check
    snout = vidData.DLC.procDLCData.snout_speed;
    emgS = ephysData.emg.smooth;
    emgTs = ephysData.emg.tSmooth;
    figure
    plot( emgTs, emgS )
    hold off
    yyaxis right
    plot( vidTs', snout )

end

