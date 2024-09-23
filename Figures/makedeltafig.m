function P = makedeltafig( mList )

% for i = 1 : length( mList )

f2load = "ExampleFigData.mat";
load( fullfile( getrootdir, "Results", mList, f2load ), "spec", "info" );

for expIdx = 1 : length( spec )
    P{ expIdx } = powerperband(...
        spec( expIdx ).L, spec( expIdx ).f2plot, [ 0.5 4 ], 'total' );

    plot( spec( expIdx ).t2plot, P{ expIdx } )
    hold on

end


% end

