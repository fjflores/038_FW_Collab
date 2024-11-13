function makespecfig( mouseId, drug, tLims, db2load )
% MAKESPECFIG plots spectrograms for all doses of a drug in a signle mouse.
% 
% Usage:
% makespecfig( mouseId, tLims )
% 
% Input:
% mouseId: mous ID.
% tLims: 2-element vector with time limits before and after the event.

root = getrootdir( );
resDir = fullfile( root, "Results" );

if ~exist( "db2load", "var" )
    db2load = "abc_experiment_list.xlsm";

end

masterTab = readtable( fullfile( resDir, db2load ) );
expListIdx = masterTab.analyze == 1 ...
    & strcmp( masterTab.drug, drug ) ...
    & strcmp( masterTab.mouse_id, mouseId );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ 0 50 ];

figure
colormap magma
expList = masterTab.exp_id( expListIdx )
nExps = sum( expListIdx );
plotIdx = 1 : 2 : 2 * nExps;
colorLims = [ -35 -5 ];
for expIdx = 1 : nExps
    [ spec, info ] = loadprocdata( expList( expIdx ), { "spec", "info" } );
    thisSpecL = spec.L;
    thisSpecR = spec.R;
    tSpec = ( spec.t2plot - ( spec.t2plot( 1 )...
        + tLims( 1 ) ) ) / 60;
    fSpec = spec.f2plot;

    % Spectrogram figure
    hAx( plotIdx( i ) ) = subtightplot( nExps, 2, plotIdx( i ),...
        opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecL' ) )
    axis xy
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 0.5;
    posY = yLims( 2 ) - 5;
    if info( i ).dose == 0
        tit = "saline";

    else
        tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Freq. (Hz)" )
    set( gca, 'YTick',  0 : 10 : 50  )
    
    % Plot EMG activation on top
    % pos = get( hAx( plotIdx( i ) ), "Position" );
    % hEmg = axes(...
    %     "Position", pos, ...
    %     "Ylim", [ 0 1 ], ...
    %     "YAxisLocation", "right",...
    %     "Color", "none" )
    % plot( hEmg, emg( i ).t2plot, emg( i ).smooth, 'w' )

    hAx( plotIdx( i ) + 1 ) = subtightplot( nExps, 2, plotIdx( i ) + 1,...
        opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecR' ) )
    axis xy
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 2 ) - 5;
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : 50  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
hAx( 1 ).Title.String = "Left hemisphere";
hAx( 2 ).Title.String = "Right hemisphere";

set( hAx( 2 : 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", -tLims( 1 ) / 60 : 10 : tLims( 2 ) / 60,...
    "XTickLabel", -tLims( 1 ) / 60 : 10 : tLims( 2 ) / 60 )
xlabel( hAx( end - 1 : end ), "time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )


