function expData = loadmixdata( expID, fullVid )
% LOADMIXDATA loads ephys and video data together.
% 
% Usage:
% expData = loadmixdata( expID, fullVid )
% expData = loadmixdata( expID )
% 
% Input:
% expID: experiment ID number as per database.
% fullVid: indicates whether to load full vidData or abbreviated
% vidData (optional). Default is abbreviated vidData.
% 
% Output:
% expData: structure with both ephys and video data. If fullVid is 'full',
% expData will contain full ephysData and vidData structures; if not,
% will be a single struct containing all of ephysData plus abbreviated 
% vidData. 

if nargin < 2
    fullVid = [];    
end

if strcmpi( fullVid, 'full' )
    expData.ephysData = loadprocdata( expID );
else
    expData = loadprocdata( expID );
end

try
    vidData = loadprocdata( expID, 'vidData' );
    
    if strcmpi( fullVid, 'full' )
        expData.vidData = vidData;
        
    else
        snoutPos = vidData.DLC.procDLCData{ :,...
            { 'snout_x_filt', 'snout_y_filt' } };
        snoutSpeed = vidData.DLC.procDLCData{ :, 'snout_speed' };
        hipsPos = vidData.DLC.procDLCData{ :,...
            { 'hips_x_filt', 'hips_y_filt' } };
        hipsSpeed = vidData.DLC.procDLCData{ :, 'hips_speed' };
        expData.dlc.snoutPos = snoutPos;
        expData.dlc.snoutSpeed = snoutSpeed;
        expData.dlc.hipsPos = hipsPos;
        expData.dlc.hipsSpeed = hipsSpeed;
        expData.dlc.tDlc = vidData.vidTs;
        
    end
    
catch
    return
    
end

