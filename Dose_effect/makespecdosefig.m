function makespecdosefig( drug, dose, fLims )
% Plot all specs for a given dose acros mice

drug = lower( drug );
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & ...
    fTab.drug_dose_inj1 == dose & ...
    fTab.drug_inj1 == drug;
expList = fTab.exp_id( expListIdx );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

end

figure( 'WindowState', 'maximized' )
colormap magma
nExps = length( expList );

for idxExp = 1 : nExps
    thisExp = expList( idxExp );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = strcat( "TidyData_", drug, ".mat" );
    load( fullfile( resDir, f2load ), "spec", "notes" );
    % tsTab = readtable( fullfile( resDir, csvFileSpec ) );
    tabExpIdx = find( [ notes.expId ] == thisExp );

    if spec( tabExpIdx ).valid( 1 ) == 0 % Check if channel is invalid.
        sz = size( spec( tabExpIdx ).SL );
        S = zeros( sz );
        
    else    
        S = spec( tabExpIdx ).SL;

    end

    t = ( spec( tabExpIdx ).t - notes( tabExpIdx ).tInj1 ) ./ 60;
    tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];
    f = spec( tabExpIdx ).f;
    
    hAx( idxExp ) = subtightplot( nExps, 1, idxExp, opts{ : } );
    imagesc( t, f, pow2db( S' ) )
    axis xy
    clim( [ -35 -5 ])
    box off
    xLims = get( gca, 'xlim' );
    ylim( fLims )
    posX = xLims( 1 ) + 1;
    posY = fLims( 2 ) - 5;
    tit = sprintf( '%s', metDat.subject );
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( 'Freq. (Hz)' )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : fLims( 2 ) - 10  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
hAx( 1 ).Title.String = sprintf(...
    "Spectrograms at %u %cg/kg in each mouse", dose, units );

xTicksVec = tLims( 1 ) : 10 : tLims( 2 );
set( hAx( end ),...
    "XTick", xTicksVec, ...
    "XTickLabel", xTicksVec )
xlabel( hAx( end ), "Time (min)" );

