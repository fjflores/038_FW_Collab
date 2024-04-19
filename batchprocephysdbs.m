function batchprocephysdbs( expList, win, params, smoothEmg, overwrite )
% BATCHPROCDBS batch-processess the given list of DBS experiments.
%
% Usage:
% batchprocdbs( expList, win, params, overwrite )
%
% Input:
% expList: list of experiments to process.
% win: window for spectrogram processing.
% params: parameters for spectrogram processing.
% smoothEmg: true if should smooth EMG. False if should skip this step (and
% only save raw and filtered EMG).
% overwrite: True if should overwrite already processed data. False
% otherwise.
%
% Output:
% Saves the ephysData structure to its respective folder.

global waitPos
if isempty( waitPos )
    waitPos = [ 435 476 270 56.2500 ];
    
end

t1 = tic;
dateProc = datestr( now, 'yyyy-mm-dd HH:MM' );
nExps = length( expList );
msg = sprintf( 'Processing exp %u (%u/%u)',...
    expList( 1 ), 1, nExps );
hWait = waitbar( 0, msg,...
    'Name', 'Batch processing data...',...
    'Position', waitPos );
for expIdx = 1 : nExps    
    expId = expList( expIdx );
    msg = sprintf(...
        'Processing exp %u (%u/%u)',...
        expId, expIdx, nExps );
    waitbar(...
        ( expIdx - 1 ) / nExps,...
        hWait,...
        msg )
    exStat = saveephysdbs(...
        expId, win, params, smoothEmg, dateProc, overwrite );
    allSkipped( expIdx,1 ) = exStat;    
    disp( ' ' )
        
end
waitbar(...
    1,...
    hWait,...
    msg )

t2 = round( toc( t1 ) );
msg = humantime( t2 );
fprintf( 'Done processing %u experiments in %s.\n',...
    nExps, msg )

pause( 4 )
delete( hWait )




