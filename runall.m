%% Batch-process the ephys data.
ccc

% Define experiment of interest.
expList = 99;

% Set parameters.
specWin = [ 10 1 ];
params = struct(...
    'specWin', specWin,...
    'detWin', [ 2 1.8 ],...
    'tapers', [ 3 5 ],...
    'pad', 0,...
    'err', [ 2 0.05 ],...
    'fpass', [ 1 / specWin( 1 ) 300 ],...
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
expId = 99;

% expData = loadmixdata( expID );

figure( 'Name', sprintf( 'Exp. %i', expId ), 'WindowState', 'maximized' )
[ hAx, hLink ] = plotexp( expId,...
    'SetShowEeg', 'raw',...
    'SetAmpEeg', [ -700 700 ],...
    'SetFreqSpec', [ 0.5 150 ],...
    'SetCAxis', [ -10 30 ],...
    'SetShowEmg', 'raw',... % choose raw, filt, or smooth
    'MinOrSec', 'sec' ); 

% TEMPORARY: turn this chunk into an option within plotexp
metTab = readtable( fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' ) );
tsTab = table2array( metTab( :, { 'dex_ts_offline', 'dex_ts_online',...
    'ati_ts_offline', 'ati_ts_online', 'dex_ts_inj', 'ati_ts_inj' } ) );
% xline( hAx( 1 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
% xline( hAx( 1 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )
% xline( hAx( 3 ), tsTab( expId, 1 : 4 ), 'm', 'LineWidth', 2 )
% xline( hAx( 3 ), tsTab( expId, 5 : 6 ), 'g', 'LineWidth', 2 )
for i = 1 : 6
    xline( hAx( i ), tsTab( expId, 5 ), 'g', 'LineWidth', 2 )
%     % xline( hAx( i ), [ 4739 6599 10619 ], 'g', 'LineWidth', 1 ) % exp94
%     xline( hAx( i ), [ 7129 9229 12889 ], 'g', 'LineWidth', 1 ) % exp96
    % xline( hAx( i ), [ 5454 7254 10854 ], 'g', 'LineWidth', 1 ) % exp98
    xline( hAx( i ), [ 4679 6479 10079 ], 'g', 'LineWidth', 1 ) % exp99

end


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
addpath( ".\DoseEffect\" )

% mList = { "M102", "M103", "M105", "M106", "M107", "M108", "M111", "M112", "M113" };
mList = { "M112", "M113" };
csvFile = "abc_experiment_list.xlsm";
tLims = [ 600 3600 ];
saveFlag = true;
warning off
batchtidydata( mList, csvFile, tLims, saveFlag )
warning on

%% Get spectral features over time
ccc
addpath( ".\Figures" )
addpath( ".\DoseEffect\" )

doses = [ 0 10 30 50 100 150 ];
% doses = [ 0 30 ];
% tLims = [ -5 5 5 ];
tLims = [ -5 5 55 ];
drug = "dex";
tic
timeFeats = savetimefeats( doses, tLims, drug );
humantime( toc )

root = getrootdir( );
save( fullfile( root, "Results\Dose_Effect", "Time_Ave_Feats.mat" ),...
    "timeFeats" )

%% Fit linear mixed-effects model to time features
ccc
addpath( ".\Figures" )
addpath( ".\DoseEffect\" )
root = getrootdir( );
load( fullfile( root, "Results\Dose_Effect", "Time_Ave_Feats.mat" ),...
    "timeFeats" )
% tic
mdls = fitfeats( timeFeats, [ 4 : 9 ] );
% fprintf( "%s\n", humantime( toc ) )

save( fullfile( root, "Results\Dose_Effect", "Feature_fits.mat" ),...
    "mdls" )
