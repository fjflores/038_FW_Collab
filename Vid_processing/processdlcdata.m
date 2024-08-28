function procDLCData = processdlcdata( DLCData, bodyparts, params )
% PROCESSDLCDATA processes raw dlc data, including removing unlikely
% coordinates, calculating deltas, applying median filter, and
% removing coordinates with large distance jumps.
% 
% Usage:
% procDLCData = processdlcdata( DLCData, bodyparts, params )
% procDLCData = processdlcdata( DLCData, bodyparts )
% 
% Input:
% DLCData: table of DLC data in format output by loaddlccsv.m
% bodyparts: list of bodyparts
% params: struct containing parameters: pcutoff, value between 0 and 1, 
% coordinats with p values below this are removed; deltalim, cutoff value 
% (# of pixels) for removing unlikely distance jumps; filterType, only 
% 'median' works so far; filtOrder, integer indicating order of the median 
% filter; fps, frames per second of video (integer)
%
% Output:
% procDLCData: table of DLC data fully processed

if nargin < 3
    disp( 'Using default parameters.' )
    pcutoff = 0.9;
    deltalim = 20;
    filterType = 'median'; % only median works rn
    filtOrder = 8;
    fps = 30;
    dt = 0.5;
    
else
    % Unpack params.
    pcutoff = params.pcutoff;
    deltalim = params.deltalim;
    filterType = params.filterType; % only median works rn
    filtOrder = params.filterOrder;
    fps = params.fps;
    dt = params.dt;
    
end

% 1) remove coordinates with likelihood < pcutoff
procDLCData = removeunlikely( DLCData, bodyparts, pcutoff );

% % %2) DELTAS OF RAW
% rawOrFilt = 'raw';
% procDLCData = getdeltas( procDLCData, bodyparts, rawOrFilt );
% procDLCData = removejumps( procDLCData, bodyparts, deltalim, rawOrFilt );

switch filterType
    case { 'median', 'Median', 'med', 'Med' }
        % 2) apply median filter
        procDLCData = medfiltdlcdata( procDLCData, bodyparts, filtOrder );
        
        % 3) calculate deltas on filtered data
        rawOrFilt = 'filt';
        procDLCData = getdeltas( procDLCData, bodyparts, rawOrFilt );
        
        % 4) remove coordinates with deltas > deltacutoff
        rawOrFilt = 'filt';
        procDLCData = removejumps( procDLCData, bodyparts, deltalim, rawOrFilt );

        
    case { 'kalman', 'Kalman', 'kalmanpancho', 'KalmanPancho',...
            'kalmanff', 'KalmanFF' }
        % 2) apply FF's Kalman filter
        procDLCData = kalmanffdlcdata( procDLCData, bodyparts, dt );
                
        % 3) calculate deltas on filtered data
        rawOrFilt = 'filt';
        procDLCData = getdeltas( procDLCData, bodyparts, rawOrFilt );
               
    otherwise 
        disp( 'filtertype must be "median" or "kalman"' )
        
end

% 5) calculate speed of fully processed data
procDLCData = getspeed( procDLCData, bodyparts, fps );


end

