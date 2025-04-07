function [ percQuiet, rmsVals ] = getperctquiet( emg, ts, tOn, Fs )

% Get emg during "dex" action
% tStart = tOn;
% dur = floor( ts( end ) - tOn );
dexDataIdx = ts > tOn;
dexEmg = emg( dexDataIdx );

% Square emg 
% absEmg = dexEmg .^ 2;

% Break in 1 sec chunks to get rms
win = [ 1 1 ];
emgChunks = makesegments( dexEmg, Fs, win );
rmsVals = sqrt( mean( emgChunks .^ 2 ) );
nChunks = length( rmsVals );
quietChunks = prctile( rmsVals, 25 );
percQuiet = ( quietChunks ./ nChunks) * 100;
