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
yLims = [ 0 40 ];

colormap magma
expList = masterTab.exp_id( expListIdx );
doseList = masterTab.drug_dose( expListIdx );
nExps = sum( expListIdx );
plotIdx = 1 : 2 : 2 * nExps;
colorLims = [ -35 -5 ];
load( fullfile( resDir, mouseId, "TidyData.mat" ) );
for expIdx = 1 : nExps
    tInj = notes( expIdx ).injDex;
    thisSpecL = spec( expIdx ).SL;
    thisSpecR = spec( expIdx ).SR;
    tSpec = ( spec( expIdx ).t - tInj ) / 60;
    fSpec = spec( expIdx ).f;
    thisDose = notes( expIdx ).dose;

    % Spectrogram figure
    hAx( plotIdx( expIdx ) ) = subtightplot( nExps, 2, plotIdx( expIdx ),...
        opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecL' ) )
    axis xy
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    ylim( yLims )
    posX = xLims( 1 ) + 2;
    posY = yLims( 2 ) - 5;
    if thisDose == 0
        tit = "saline";

    else
        tit = sprintf( '%s %u %cg/kg', drug, thisDose, 956 );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Freq. (Hz)" )

    hAx( plotIdx( expIdx ) + 1 ) = subtightplot(...
        nExps, 2, plotIdx( expIdx ) + 1, opts{ : } );
    imagesc( tSpec, fSpec, pow2db( thisSpecR' ) )
    axis xy
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    ylim( yLims );
    posX = xLims( 1 ) + 2;
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
    'YTick',  0 : 10 : 30  )
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


