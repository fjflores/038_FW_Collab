%% Batch-process the ephys data.
ccc

% Define experiment of interest.
expList = 22;

% Set parameters.
specWin = [ 10 1 ];
params = struct(...
    'specWin', specWin,...
    'detWin', [ 2 1.8 ],...
    'tapers', [ 3 5 ],...
    'pad', 0,...
    'err', [ 2 0.05 ],...
    'fpass', [ 1 / specWin( 1 ) 100 ],...
    'filtEeg', [ 1 40 ],...
    'filtEmg', [ 200 700 ] );
smoothEmg = false;
overwrite = true;

% Read and save processed data.
% exps2proc = getexp2proc( expList ); % only includes to-analyze experiments
% batchprocephys( exps2proc, params, smoothEmg, overwrite )
batchprocephys( expList, params, smoothEmg, overwrite )


%% Plot entire experiment.
clear all
% close all
% clc

% Define experiment of interest.
expId = 52;

% expData = loadmixdata( expID );

figure( 'Name', sprintf( 'Exp. %i', expId ), 'WindowState', 'maximized' )
[ hAx, hLink ] = plotexp( expId,...
    'SetShowEeg', 'raw',...
    'SetAmpEeg', [ -400 400 ],...
    'SetFreqSpec', [ 0.5 80 ],...
    'SetCAxis', [ 0 30 ],...
    'SetShowEmg', 'raw',... % choose raw, filt, or smooth
    'MinOrSec', 'sec' ); 

% TEMPORARY: turn this chunk into an option within plotexp
metTab = readtable( fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' ) );
tsTab = table2array( metTab( :, 28 : 33 ) );
xline( hAx( 1 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
xline( hAx( 1 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )
xline( hAx( 3 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
xline( hAx( 3 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )


%% Batch process and save DLC and video data.
close all
clear all
clc

addpath( '.\Vid_processing' )

expList = 14; 

params = struct(...
    'pcutoff', 0.9,...
    'deltalim', 20,...
    'filterType', 'kalmanff',... % 'median' or 'kalmanFF'
    'filterOrder', 15,... % for median filt
    'dt', 0.5,... % for kalman filt
    'fps', 30 );
    
overwrite = false;

% expList = getexp2proc( expList ); % only includes to-analyze experiments
% Batch process DLC data AND batch align and save all video timestamps.
% batchprocdlc( expList, params, overwrite );
% batchvidts( expList, overwrite );

% OR Batch process DLC and align video ts all at once.
batchprocvid( expList, params, overwrite );

% rmpath( '.\Vid_processing\' )

%% Save the data for sleep scoring
ccc
warning off

mouseId = "M106";
savesleepdata( mouseId )

%% Batchprocess mice to get tidy data
ccc
addpath(".\DoseEffect\")

mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108" };
% mList = { "M107" };
csvFile = "abc_experiment_list.xlsm";
tLims = [ 600 3600 ];
warning off
batchexampledata( mList, csvFile, tLims, true )
warning on