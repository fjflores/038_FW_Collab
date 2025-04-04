%% Frags durations
frags = finddeltafrags( "dex", "delta", "total" );

for i = 1 : length( frags );
    thisFrag = frags( i );
    allDurs = [];
    for j = 1 : length( thisFrag.lowDurs )
        allDurs = vertcat( allDurs, thisFrag.lowDurs{ j } );

    end
    subplot( 6, 1, i )
    allDurs = allDurs * thisFrag.dt; % to secs
    allDurs( allDurs > 250 ) = 250;
    histogram( allDurs , 50 )
    xlim( [ -10 251 ] )
    ylim( [ 0 20 ] )
    title( thisFrag.dose )
    box off

end