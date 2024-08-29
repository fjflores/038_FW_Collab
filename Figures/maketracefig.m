function maketracefig( presDir )

path2load = fullfile( getrootdir, 'Pres', presDir, 'Assets' );
f2load = "FigData.mat";
data = load( fullfile( path2load, f2load ), 'eeg' );

%% Set up data to plot
dat2plot{ 1, 1 } = data.eeg.base.L;
dat2plot{ 1, 2 } = data.eeg.base.R;
dat2plot{ 2, 1 } = data.eeg.dex.L;
dat2plot{ 2, 2 } = data.eeg.dex.R;
dat2plot{ 3, 1 } = data.eeg.sleep.L;
dat2plot{ 3, 2 } = data.eeg.sleep.R;

t2plot{ 1 } = data.eeg.t2plot.base;
t2plot{ 2 } = data.eeg.t2plot.dex;
t2plot{ 3 } = data.eeg.t2plot.sleep;

%% EEG example figure
figure
cols = brewermap( 6, 'Set1' );
offset = 400;
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ -850 400 ];
tits = { "Baseline", "Dex (10 \mug/kg)", "Non-REM sleep" };

nPlots = length( t2plot );
for plotIdx = 1 : nPlots
    hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );

    plot( t2plot{ plotIdx }, dat2plot{ plotIdx, 1 },...
        'Color', cols( 1, : ) )
    hold on
    plot( t2plot{ plotIdx }, dat2plot{ plotIdx, 2 } - offset,...
        'Color', cols( 2, : ) )
    ylim( yLims )
    box off
    hold off
    ylabel( "Amp. (\muV)" )
    xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 0.1;
    posY = yLims( 2 ) - 100;
    msg = sprintf( '%s', tits{ plotIdx } );
    text( posX, posY, msg,...
        'Color', 'k',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

    if plotIdx == nPlots
        legend( "Left", "Right" )

    end

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick', [ -400 0 400 ] )

set( gcf, "Position", [ 739 551 804 468 ] )
set( findobj( "Type", "legend" ), "Position", [ 0.84 0.35 0.10 0.09 ] )
