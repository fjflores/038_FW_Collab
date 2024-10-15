function varargout = loadprocdata( expID, dataType )
% LOADPROCDATA loads the processed data from the experiment.
%
% Usage:
% ephysData = loadprocdata( expID, dataType );
%
% Inputs:
% expID: experiment ID from metadata table.
% dataType: which data to load. 'eeg' loads all EEG-related variables:
% 'eegRaw', 'eegFilt', 'eegClean', in that order.
% 'emg' loads all EMG related variables: 'emgRaw', 'emgFilt', 'emgSmooth',
% in that order.
% 'all' loads all variables: 'info', 'eegRaw', 'eegFilt', 'eegClean',
% 'emgRaw', 'emgFilt', 'emgSmooth', 'spec', 'coher', 'events', in that
% order.
%
% Output:
% procData: Matlab structure with either ephys data or video data.
% Define directories.

rootDir = getrootdir;
resDir = 'Results';
metDat = getmetadata( expID );
dir2load = fullfile( rootDir, resDir, metDat.subject );
f2load = fullfile( dir2load, [ metDat.expName '_new.mat' ] );

if exist( dir2load, 'dir' ) ~= 7 % Check if subject folder exists.
    error( 'Subject %s folder does not exist. Please check.',...
        metDat.subject )

end

if exist( f2load, 'file' ) ~= 2
    error( 'Results not gathered for Exp %d. Please process data.',...
        expID )

end

dataType = lower( dataType );
switch dataType
    case 'eeg'
        vars2load = { 'eegRaw', 'eegFilt', 'eegClean' };
        varargout = getvars( f2load, vars2load );

    case 'emg'
        vars2load = { 'emgRaw', 'emgFilt', 'emgSmooth' };
        varargout = getvars( f2load, vars2load );

    case 'all'
        vars2load = { };
        varargout = getvars( f2load, vars2load );

    otherwise
        vars2load = dataType;
        varargout = getvars( f2load, vars2load );

end


% Helper function to gather vars as varargouts
function thisVars = getvars( f2load, vars2load )

if ~isempty( vars2load )
    tmp = load( f2load, vars2load{ : } );

else
    tmp = load( f2load );

end

fields = fieldnames( tmp );
for i = 1 : length( fields )
    thisVars{ i } = tmp.( fields{ i } );

end
