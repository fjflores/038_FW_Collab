%% Batch-process the ephys data.
ccc

% Define experiment of interest.
expList = 16;

% Set parameters.
win = [ 2 0.1 ];
params = struct(...
    'tapers', [ 3 5 ],...
    'pad', 0,...
    'err', [ 2 0.05 ],...
    'fpass', [ 1 / win( 1 ) 250 ],...
    'filtEeg', [ 1 40 ],...
    'filtEmg', [ 200 700 ] );
smoothEmg = false;
overwrite = true;

% Read and save processed data.
% exps2proc = getexp2proc( expList ); % only includes to-analyze experiments
% batchprocephys( exps2proc, win, params, smoothEmg, overwrite )
batchprocephys( expList, win, params, smoothEmg, overwrite )


%% Plot entire experiment.
% clear all
close all
% clc

% Define experiment of interest.
expID = 9;

expData = loadmixdata( expID );

figure( 'Name', sprintf( 'Exp. %i', expID ), 'WindowState', 'maximized' )
[ hAx, hLink ] = plotexp( expData,...
    'SetShowEeg', 'raw',...
    'SetAmpEeg', [ -400 400 ],...
    'SetFreqSpec', [ 0.5 80 ],...
    'SetCAxis', [ 0 30 ],...
    'SetShowEmg', 'raw',... % choose raw, filt, or smooth
    'MinOrSec', 'sec' ); 


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
