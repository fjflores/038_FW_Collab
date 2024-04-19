%% Batch-process the ephys data.
ccc

% Define experiment of interest.
expList = 1 : 2;

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
% batchprocephysdbs( exps2proc, win, params, smoothEmg, overwrite )
batchprocephysdbs( expList, win, params, smoothEmg, overwrite )


%% Plot entire experiment.
% clear all
% close all
% clc

% Define experiment of interest.
expID = 1;

expData = loadmixdata( expID );

figure( 'Name', sprintf( 'Exp. %i', expID ), 'WindowState', 'maximized' )
[ hAx, hLink ] = plotexpdbs( expData,...
    'SetShowEeg', 'raw',...
    'SetAmpEeg', [ -500 500 ],...
    'SetFreqSpec', [ 0.5 80 ],...
    'SetCAxis', [ 0 30 ],...
    'SetShowEmg', 'raw',... % choose raw, filt, or smooth
    'PlotAllEvents', 'yes',...
    'MinOrSec', 'sec' ); 

