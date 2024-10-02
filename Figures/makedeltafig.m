function P = makedeltafig( mouseId )

% for i = 1 : length( mList )

f2load = "ExampleFigData.mat";
load( fullfile( getrootdir, "Results", mouseId, f2load ), "spec", "info" );

band = [ 0.5 4 ];
dur = 2;
base = false;
art = true;
nExp = length( spec );
for expIdx = 1 : nExp
    % Set vars
    Stemp = spec( expIdx ).L;
    t = spec( expIdx ).t2plot;
    f = spec( expIdx ).f2plot;
    
    % remove artifact
    tOff = info( expIdx ).injOff;
    tOn = info( expIdx ).injOn;
    S = replacechunkspec( Stemp, t, [ tOff tOn ] );

    % get power
    bandtc = getbandtimecourse( S, t, f, band, dur, base, art );

    % Remove offline period
    % tOff = info( expIdx ).injOff;
    % tOn = info( expIdx ).injOn;
    % t2plotOrig = spec( expIdx ).t2plot;
    % idxBase = find( t2plotOrig < tOff );
    % idxExp = find( t2plotOrig > tOn );
    % P{ expIdx } = [ Porig( idxBase ); nan( 50, 1 ); Porig( idxExp ) ];
    % t2plot = [ t2plotOrig( idxBase ) nan( 1, 50 ) t2plotOrig( idxExp ) ];
    % t2plot = t2plot - t2plot( 1 );
    subplot( nExp, 1, expIdx )
    plotbandtimecourse( bandtc, S, t, f, [ 0.5 30 ] )
    
end


% end

