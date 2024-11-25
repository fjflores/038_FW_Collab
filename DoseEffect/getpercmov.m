function percMov = getpercmov( emg, ts, tDexOn, Fs )

% Get emg during "dex" action
% tStart = tDexOn;
% dur = tAtiOff - tDexOn;
dexDataIdx = getepochidx( ts, tDexOn, 3600 );
dexEmg = emg( dexDataIdx );

% Square emg 
% absEmg = dexEmg .^ 2;

% Break in 1 sec chunks to get rms
win = [ 1 1 ];
emgChunks = makesegments( absEmg, Fs, win );
rmsVals = sqrt( mean( emgChunks .^ 2 ) );
nChunks = length( rmsVals );
quietChunks = prctile( smRms, 33 );
percMov = ( quietChunks ./ nChunks) * 100;
