function varargout = loadprocdata( expID, dataType )
% LOADPROCDATA loads the processed data from the experiment.
%
% Usage:
% varargout = loadprocdata( expID, dataType );
%
% Thne output of this function uses varargout, so the output variables have
% to be specified in the correct order. best practive is juts copy paste
% from the help below. N.B.: emgSmooth is completely ignored in this
% version.
% 
% Inputs:
% expID: experiment ID from metadata table.
% dataType: character string specifying which data to load. 
%   'eeg' loads all EEG-related variables in alphabetic order: eegClean, 
%       eegFilt, eegRaw.
%
%   'emg' loads all EMG-related variables in alphabetic order: emgFilt, 
%       emgRaw.
%
%   'all' loads all variables in alphabetic order: coher, eegClean, 
%       eegFilt, eegRaw, emgFilt, emgRaw, events, info, spec.
%
%   'plot' loads variables for plotting in alphabetic order: coher, 
%       eegClean, eegFilt, emgFilt, emgRaw, events, spec.
%
%   Optionally, you can pass a single variable name and it will load just
%   that one.
%
% Output:
% A variable number of variables.

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

% Go over the different loading options
if isstring( dataType ) || ischar( dataType )
switch dataType
    case 'eeg'
        vars2load = { 'eegClean', 'eegFilt', 'eegRaw' };
        varargout = getvars( f2load, vars2load{ : } );

    case 'emg'
        vars2load = { 'emgFilt', 'emgRaw' };
        varargout = getvars( f2load, vars2load{ : } );

    case 'all'
        vars2load = { };
        varargout = getvars( f2load, vars2load{ : } );

    case 'plot'
        vars2load = { 'coher', 'eegClean', 'eegFilt', 'emgFilt',...
            'emgRaw', 'events', 'spec' };
        varargout = getvars( f2load, vars2load{ : } );

    otherwise
        error( "dataType must be either a string, char, or a cell array of those." )

end

elseif iscell( dataType )
    vars2load = string( dataType );
    varargout = getvars( f2load, vars2load{ : } );

else
    error( "dataType must be either a string, a char, or a cell array of those." )

end



% Helper function to gather vars as varargouts
function thisVars = getvars( f2load, varargin )

if ~isempty( varargin )
    tmp = load( f2load, varargin{ : } );

else
    tmp = load( f2load );

end

fields = fieldnames( tmp );
for i = 1 : length( fields )
    thisVars{ i } = tmp.( fields{ i } );

end
