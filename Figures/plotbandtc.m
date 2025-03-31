function plotbandtc( drug, bandName, modo )
% Plot delta power AUC across all mice for a single dose


root = getrootdir( );
f2load = strcat( bandName, "_Power_", drug );
bandFile = load( fullfile( root, "Results", "Dose-Effect", f2load ) );
PL = bandFile.PL;
% gap = [ 0.005 0.01 ];
% margH = [ 0.1 0.05 ];
% margV = [0.1 0.1];
% opts = { gap, margH, margV };
% yLims = [ 0 50 ];

% colormap magma

nDoses = length( PL );
for doseIdx = 1 : nDoses
    figure
    thisP = PL( doseIdx );
    expList = thisP.expList;
    nExps = length( expList );

    for expIdx = 1 : nExps
        switch modo
            case "total"
                P2plot = thisP.total;

            case "median"
                P2plot = thisP.median;

            case "mean"
                P2plot = thisP.mean;

        end

        subplot( nExps, 1, expIdx )
        tP = thisP.ts;
        plot( tP, P2plot( :, expIdx ) )
        box off
        % ylim( [ 0 1.5 ] )

        % disprog( expIdx, nExps, 10 )

    end

end