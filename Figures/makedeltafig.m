function makedeltafig( mouseId )

% for i = 1 : length( mList )

f2load = "TidyData.mat";
thisData = load( fullfile( getrootdir, "Results", mouseId, f2load ),...
    "spec", "notes" );

band = [ 0.5 4 ];
dur = 2;
base = false;
art = true;
nExp = length( thisData.spec );
for expIdx = 1 : nExp
    % Set vars
    S = thisData.spec( expIdx ).SL;
    t = thisData.spec( expIdx ).t - thisData.notes( expIdx ).injDex;
    f = thisData.spec( expIdx ).f;
    
    % % remove artifact
    % tOff = info( expIdx ).injOff;
    % tOn = info( expIdx ).injOn;
    % S = replacedatachunk( Stemp, t, [ tOff tOn ], 'min' );

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

