function warnprocfail( failList )
% WARNPROCFAIL takes a list of experiments that failed to process (list of
% integer exp IDs) and prints a warning to user listing failed experiments.

nFails = length( failList );
msg = '';

if nFails == 1
    msg = sprintf( 'Failed to process exp %i.', failList );
    
elseif nFails == 2
    msg = sprintf( 'Failed to process exps %i and %i.', failList );
    
elseif nFails > 2
    msg = sprintf( [ 'Failed to process exps ',...
        repmat( '%i, ', 1, length( failList ) - 1 ),...
        'and %i.' ], failList );
    
end

if ~isempty( msg )
    warning( msg );
    
end


end

