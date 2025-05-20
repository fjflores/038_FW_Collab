function plotspecxdose( drug, dose, fLims )
% Plot all specs for a given dose acros mice

drug = lower( drug );
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & ...
    fTab.drug_dose_inj1 == dose & ...
    strcmp( drug, fTab.drug_inj1 );
expList = fTab.exp_id( expListIdx );

gap = [ 0.005 0.01 ];
margH = [ 0.07 0.08 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
colorLims = [ -35 -5 ];

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

end

% figure( 'WindowState', 'maximized' )
figure
colormap magma
nExps = length( expList );

for expIdx = 1 : nExps
    thisExp = expList( expIdx );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = strcat( "TidyData_", drug, ".mat" );
    load( fullfile( resDir, f2load ), "spec", "notes" );
    tabExpIdx = find( [ notes.expId ] == thisExp );

    if spec( tabExpIdx ).valid( 1 ) == true % Check if channel is invalid.
        SL = spec( tabExpIdx ).SL;
        
    else    
        sz = size( spec( tabExpIdx ).SL );
        SL = repmat( eps, sz );

    end

    t = ( spec( tabExpIdx ).t - notes( tabExpIdx ).tInj1 ) ./ 60;
    tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];
    f = spec( tabExpIdx ).f;
    
    thisPlotIdx = ( 2 * expIdx ) - 1;
    hAx( thisPlotIdx ) = subtightplot( nExps, 2, thisPlotIdx, opts{ : } );
    plotspecgram( SL, t, f, 'log' )
    clim( colorLims )
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

    if spec( tabExpIdx ).valid( 2 ) == true % Check if channel is invalid.
        SR = spec( tabExpIdx ).SR;
        
    else    
        sz = size( spec( tabExpIdx ).SR );
        SR = repmat( eps, sz );

    end

    thisPlotIdx = 2 * expIdx;
    hAx( thisPlotIdx ) = subtightplot( nExps, 2, thisPlotIdx, opts{ : } );
    plotspecgram( SR, t, f, 'log' )
    clim( colorLims )
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
    set( hAx( 2 * expIdx ), "YTickLabel", [] )
    % ylabel( 'Freq. (Hz)' )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : fLims( 2 ) - 10  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
sgtitle( sprintf(...
    "Spectrograms at %u %cg/kg in each mouse", dose, units ) );
% hAx( 1 ).Title.String = sprintf(...
%     "Spectrograms at %u %cg/kg in each mouse", dose, units );

xTicksVec = tLims( 1 ) : 10 : tLims( 2 );
set( hAx( end - 1 : end ),...
    "XTick", xTicksVec, ...
    "XTickLabel", xTicksVec )
xlabel( hAx( end - 1 : end ), "Time (min)" );

