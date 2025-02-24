function timeFeats = savetimefeats( doses, tLims, drug )


warning off
epochs = [...
    tLims( 1 ) : tLims( 2 ) : tLims( 3 ) - tLims( 2 );...
    tLims( 1 ) + tLims( 2 ) : tLims( 2 ) : tLims( 3 ) ];
timeFeats = struct( 'featTab', [], 'epoch', [] );  
nEpochs = size( epochs, 2 );
% tic;

for epochIdx = 1 : nEpochs
    thisEpoch = epochs( :, epochIdx );
    fprintf( "Processing %g -- %g mins segment...\n",...
        thisEpoch( 1 ), thisEpoch( 2 ) );
    timeFeats ( epochIdx ).featTab = getavefeats( doses, thisEpoch, drug );
    timeFeats ( epochIdx ).epoch = thisEpoch;
    % disprog( epochIdx, nEpochs, 10 )
    fprintf( ' done...\n\n' )

end

% fprintf( "All done in %s\n", humantime( toc ) )
warning on