% Plot examples of delta fragementation
ccc
doseIdx = [ 1 4 6 ];
expList = [ 9 5 3 ];

root = getrootdir( );
f2load = strcat( "Delta", "_Power_", "Dex" );
bandFile = load( fullfile( root, "Results", "Dose-Effect", f2load ) );
PL = bandFile.PL( doseIdx );
tP = PL(1).ts / 60;

nDoses = length( doseIdx );
tits = { "Saline", sprintf( "50 %cg\\kg", 965 ), sprintf( "150 %cg\\kg", 965 )};
figure
for plotIdx = 1 : length( expList )
    P2plot = PL( plotIdx ).total( :, expList( plotIdx ) );

    subplot( nDoses, 1, plotIdx )
    plot( tP, P2plot )
    hold on
    plot( tP, medfilt1( P2plot, 30 ), 'r' )
    box off
    title( tits{ plotIdx } )
    ylabel( "Power (a.u.)" )

    if plotIdx == 3
        xlabel( "Time (min)" )

    end


end

%{
for doseIdx = doses
    thisP = PL( doseIdx );
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
%}