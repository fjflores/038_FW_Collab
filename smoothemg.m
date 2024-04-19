function [ emgAct, tAct, fpassEmg, FsSmooth ] = smoothemg( emg, Fs )
% EMGSMOOTH estimates muscle activation from emg.
% 
% Usage:
% emgAct = smoothemg( emg, highCut, Fs )
% 
% It uses the algorithm described in doi:10.1016/j.neuroimage.2015.06.088. 
% It requires to have Simulink installed. The spectra is hardcoded to be
% computed between 200 - 700 Hz in a window of 10 ms at steps of 1 ms.
% 
% Input:
% emg: single channel emg data.
% Fs: sampling frequency of eeg.
% 
% Output:
% emgAct: estimator of muscle activation.

% Obtain EMG power between 200 and 700 Hz.
fpassEmg = [ 200 700 ];
params = struct(...
    'tapers', [ 3 5 ],...
    'Fs', Fs,...
    'pad', 0,...
    'fpass', fpassEmg );
win = [ 0.01 0.001 ];
[ S, tAct, f ] = mtspecgramc( emg, win, params );
medS = median( S, 2 );

% Pre-proces emg power
sixSigma = 6 * std( medS );
clipEmgPow = medS;
clipEmgPow( medS > sixSigma ) = sixSigma;
medSmax1 = clipEmgPow ./ max( clipEmgPow );
FsSmooth = round( 1 ./ ( mean( diff( tAct ) ) ) );

% Compute acitvation dynamics
% tStart = tic;
emgAct = EMG_to_ACT( medSmax1, FsSmooth, 1, length( medSmax1 ), false );
% tElaps = toc( tStart );
% fprintf( 'EMG smoothed in %s\n', humantime( tElaps ) )
