function P = makedeltafig( mList, modo, logFlag )

% for i = 1 : length( mList )

f2load = "ExampleFigData.mat";
load( fullfile( getrootdir, "Results", mList, f2load ), "spec", "info" );

% win = [ 20 1 ];
% params = 

for expIdx = 1 : length( spec ) - 1
    % get mtm spectra

    % get power
    Porig = powerperband(...
        spec( expIdx ).L, spec( expIdx ).f2plot, [ 0.5 4 ], modo );

    % Remove offline period
    tOff = info( expIdx ).injOff;
    tOn = info( expIdx ).injOn;
    t2plotOrig = spec( expIdx ).t2plot;
    idxBase = find( t2plotOrig < tOff );
    idxExp = find( t2plotOrig > tOn );
    P{ expIdx } = [ Porig( idxBase ); nan( 50, 1 ); Porig( idxExp ) ];
    t2plot = [ t2plotOrig( idxBase ) nan( 1, 50 ) t2plotOrig( idxExp ) ];
    t2plot = t2plot - t2plot( 1 );

    if logFlag
        plot( t2plot, pow2db( P{ expIdx } ) )
        hold on

    else
        plot( t2plot, P{ expIdx } )
        hold on

    end
end


% end

