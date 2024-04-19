function procData = loadprocdata( expID, dataType )
% LOADPROCDATA loads the processed data from the experiment.
% 
% Usage:
% ephysData = loadprocdata( expID, dataType );
% 
% Inputs:
% expID: experiment ID from metadata table.
% dataType: which data to load. Default 'ephysData'. Could also be
% 'vidData'.
% 
% Output:
% procData: Matlab structure with either ephys data or video data.

if nargin < 2
    dataType = 'ephysData';
    
end

% Define directories.
rootDir = getrootdir;
resDir = 'Results';
metDat = getmetadata( expID );
dir2load = fullfile( rootDir, resDir, metDat.subject );
f2load = fullfile( dir2load, [ metDat.expName '.mat' ] );

if exist( dir2load, 'dir' ) ~= 7 % Check if containing folder exists.
    disp( 'Containing folder does not exist.' )
    disp( 'Please check subject.' )
    
else % Check if results exist, and load.
    if exist( f2load, 'file' ) ~= 2
        error( 'Results not gathered for Exp %d. Please process data.',...
            expID )
        
    else
        dummy = load( f2load, dataType );
        procData = getfield( dummy, dataType );
        
    end
    
end


end

