function plotrmsvals( rms, nSubPlots )

nSigs = length( rms );
nFigs = ceil( nSigs ./ nSubPlots );

cnt = 1;
for i = 1 : nFigs
    figure

    for j = 1 : nSubPlots
        subplot( nSubPlots, 1, j )
        plot( rms{ cnt } )
        cnt = cnt + 1;

        if cnt > nSigs
            break

        end

    end

end