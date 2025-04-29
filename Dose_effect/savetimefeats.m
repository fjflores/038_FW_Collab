function allFeats = savetimefeats( doses, tLims, drug, saveFlag )
% SAVETIMEFEATS saves an epochs x features table.
% 
% Usage:
% savetimefeats( doses, tLims, drug, saveFlag )
% 
% Inputs:
% doses: doses to extract.
% tLims: time limits for epochs. 3-element vector with start time,
%   interval, and end time, in mins.
% drug: which drug to process.
% saveFlag: logical. Whether to save the results or not.
% 
% Outputs:
% none


epochs = [...
    tLims( 1 ) : tLims( 2 ) : tLims( 3 ) - tLims( 2 );...
    tLims( 1 ) + tLims( 2 ) : tLims( 2 ) : tLims( 3 ) ];
timeFeats = struct( 'featTab', [], 'epoch', [] );  
nEpochs = size( epochs, 2 );
tic;

for epochIdx = 1 : nEpochs
    thisEpoch = epochs( :, epochIdx );
    epochString = sprintf( "%g -- %g", thisEpoch( 1 ), thisEpoch( 2 ) );
    fprintf( "Processing %s mins segment...\n",...
        epochString );
    featTab = getavefeats( doses, thisEpoch, drug );
    epochCol = repmat( epochString, height( featTab ), 1 );
    epochIdx = repmat( epochIdx - 1, height( featTab ), 1 );
    featTab = addvars( featTab, epochCol, epochIdx,...
        'NewVariableNames', { 'epoch', 'epochIdx' } );
    % timeFeats ( epochIdx ).featTab = getavefeats( doses, thisEpoch, drug );
    % timeFeats ( epochIdx ).epoch = thisEpoch;
    fprintf( ' done...\n\n' )

    if epochIdx == 1
        numRows = height( featTab );
        varTypes = varfun( @class, featTab, 'OutputFormat', 'cell' );
        allFeats = table(...
            'Size', [ 0, width( featTab ) ],...
            'VariableTypes', varTypes,...
            'VariableNames', featTab.Properties.VariableNames );

    end

    allFeats = vertcat( allFeats, featTab );

end

if saveFlag
    fprintf( "Saving..." )
    root = getrootdir( );
    save(...
        fullfile( root, "Results\Dose_Effect", "Feature_Table_Long.mat" ),...
        "allFeats" )
    fprintf( "Done!" )

end

% allFeats.epochOrdinal = ordinal( allFeats.epochOrdinal );
fprintf( "All done in %s\n", humantime( toc ) )
