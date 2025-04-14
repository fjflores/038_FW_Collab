function printdoneproc( nSuccs, timeSec, nSkip )
% PRINTDONEPROC prints a message telling user that processing given number
% of experiments has been completed in given amount of time.

if nargin < 3
    nSkip = 0;
end

timeMsg = humantime( timeSec );

if nSkip == 0    
    fprintf( 'Done processing %u experiments in %s.\n',...
        nSuccs, timeMsg )
    
elseif nSkip > 0
    fprintf( 'Aborted processing of %u experiments.\n', nSkip )
    nProc = nSuccs - nSkip;
    fprintf( 'Done processing %u out of %u experiments in %s.\n',...
        nProc, nSuccs, timeMsg )

end


end

 