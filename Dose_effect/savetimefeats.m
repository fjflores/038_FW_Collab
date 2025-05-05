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
% allFeats: long table with features per epoch.


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
    dbLCol = pow2db( featTab.Pdelta_L );
    dbRCol = pow2db( featTab.Pdelta_R );
    tanCdelta = atanh( featTab.Cdelta );
    epochCol = repmat( epochString, height( featTab ), 1 );
    epochOrd = repmat( epochIdx - 1, height( featTab ), 1 );
    featTab = addvars( featTab, ...
        dbLCol, dbRCol, tanCdelta, epochCol, epochOrd,...
        'NewVariableNames', ...
        { 'dBdelta_L', 'dBdelta_R', 'tanCdelta', 'epoch', 'epochOrd' } );
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
    f2save =  strcat( ...
        "Feature_Table_Long_", drug, num2str( tLims( 2 ) ), ".mat" )
    save(...
        fullfile( root, "Results\Dose_Effect", f2save ),...
        "allFeats" )
    fprintf( "Done!" )

end

% allFeats.epochOrdinal = ordinal( allFeats.epochOrdinal );
fprintf( "All done in %s\n", humantime( toc ) )




