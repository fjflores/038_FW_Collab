function plotspecxmouse( mouseId, drug, fLims, db2load )
% MAKESPECFIG plots spectrograms for all doses of a drug in a signle mouse.
% 
% Usage:
% makespecfig( mouseId, tLims )
% 
% Input:
% mouseId: mouse ID.
% tLims: 2-element vector with time limits before and after the event.

drug = lower( drug );

root = getrootdir( );
resDir = fullfile( root, "Results" );

if ~exist( "db2load", "var" )
    db2load = "abc_experiment_list.xlsm";

end

masterTab = readtable( fullfile( resDir, db2load ) );
expListIdx = masterTab.analyze == 1 ...
    & strcmp( masterTab.drug_inj1, drug ) ...
    & strcmp( masterTab.mouse_id, mouseId );

gap = [ 0.005 0.01 ];
margH = [ 0.07 0.08 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

colormap magma
nExps = sum( expListIdx );
colorLims = [ -35 -5 ];

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

end


f2load = strcat( "TidyData_", drug, ".mat" );
load( fullfile( resDir, mouseId, f2load ), "notes", "spec" );
for expIdx = 1 : nExps
    tInj1 = notes( expIdx ).tInj1;
    t = ( spec( expIdx ).t - tInj1 ) / 60;
    f = spec( expIdx ).f;
    thisDose = notes( expIdx ).doseInj1;

    if expIdx == 1
        tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];

    end
    
    % Left Spectrogram
    if spec( expIdx ).valid( 1 ) == true % Check if channel is invalid.
        SL = spec( expIdx ).SL;
        
    else    
        sz = size( spec( tabExpIdx ).SL );
        SL = repmat( eps, sz );

    end
    
    thisPlotIdx = ( 2 * expIdx ) - 1;
    hAx( thisPlotIdx ) = subtightplot( nExps, 2, thisPlotIdx, opts{ : } );
    plotspecgram( SL, t, f, "log" )
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    ylim( fLims )
    posX = xLims( 1 ) + 2;
    posY = fLims( 2 ) - 5;
    if thisDose == 0
        tit = "saline";

    else
        tit = sprintf( '%s %u %cg/kg', drug, thisDose, units );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Freq. (Hz)" )
    
    % Right spectrogram
    if spec( expIdx ).valid( 2 ) == true % Check if channel is invalid.
        SR = spec( expIdx ).SR;
        
    else    
        sz = size( spec( expIdx ).SR );
        SR = repmat( eps, sz );

    end
    
    thisPlotIdx = ( 2 * expIdx );
    hAx( thisPlotIdx ) = subtightplot( nExps, 2, thisPlotIdx, opts{ : } );
    plotspecgram( SR, t, f, "log" )
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    ylim( fLims );
    posX = xLims( 1 ) + 2;
    posY = fLims( 2 ) - 5;
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : fLims( end ) - 10  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
sgtitle( sprintf(...
    "Spectrograms from mouse %s at each dose", mouseId ), ...
    "FontSize", 12 );
set( hAx( 2 : 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", 0 : 20 : tLims( 2 ),...
    "XTickLabel", 0 : 20 : tLims( 2 ) )
xlabel( hAx( end - 1 : end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )


