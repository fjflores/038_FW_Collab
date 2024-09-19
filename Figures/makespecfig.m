function makespecfig( resDir )

f2load = "ExampleFigData.mat";
load( fullfile( resDir, f2load ), 'spec', 'info' );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ 0 50 ];

figure
colormap magma
nExps = length( spec );
plotIdx = 1 : 2 : 2 * nExps;
for i = 1 : nExps
    thisSpecL = spec( i ).L;
    thisSpecR = spec( i ).R;
    tSpec = spec( i ).t2plot - ( spec( i ).t2plot( 1 ) + 5 );
    fSpec = spec( i ).f2plot;

    % EEG example figure
    hAx( plotIdx( i ) ) = subtightplot( nExps, 2, plotIdx( i ),...
        opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecL' ) )
    axis xy
    box off
    clim( [ 0 35 ] )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 2 ) - 5;
    tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

    hAx( plotIdx( i ) + 1 ) = subtightplot( nExps, 2, plotIdx( i ) + 1,...
        opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecR' ) )
    axis xy
    box off
    clim( [ 0 35 ] )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 2 ) - 5;
    tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick', [ 0 : 10 : 50 ] )

hAx( 1 ).Title.String = "Left hemisphere";
hAx( 2 ).Title.String = "Right hemisphere";

hAx( 1 ).YLabel.String = "Freq. (Hz)";
set( hAx( 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", [ -5 0 5 10 15 ],...
    "XTickLabel", [ -5 0 5 10 15 ] )
xlabel( hAx( end - 1 : end ), "time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% set( gcf, 'Position', [ 0.3664    0.3208    0.3292    0.4338 ] )


