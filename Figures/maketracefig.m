function maketracefig( eventTab )


tab = readtable( eventTab, 'ReadRowNames', 1 );
% mouseId = strcat( "M", string( tab{ "mouseID", : } ) );
expId = tab{ "expID", : };
eventsDex = tab{ 4 : 7, 1 };
% root = getrootdir( );
eegClean = loadprocdata( expId, { "eegClean" } );
% Find required experiment
dataEeg = eegClean.data( :, 1 );
t = eegClean.ts;
Fs = eegClean.Fs( 1 );
dataEeg = eegemgfilt( dataEeg,[ 0.1 80 ], Fs );

% Get data chunks
dexSegs = createdatamatc( dataEeg, eventsDex, Fs, [ 0 10 ], t );

% get sleep
expId = tab{ "sleep_expID", : };
eventsSleep = tab{ "time_NREM", : };
eegClean = loadprocdata( expId, { "eegClean" } );

% resDir = fullfile( root, "Results", mouseId );
% load( fullfile( resDir, "TidyData.mat" ), "eeg", "notes" );
% Find required experiment
dataEeg = eegClean.data( :, 1 );
t = eegClean.ts;
Fs = eegClean.Fs( 1 );
sleepSegs = createdatamatc( dataEeg, eventsSleep, Fs, [ 0 10 ], t );

mat2plot = [ dexSegs sleepSegs ];
%% Set up data to plot
cols = brewermap( 6, 'Set1' );
offset = 400;
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ -900 400 ];
xLims = [ 0 10 ];

figure
nExps = size( mat2plot, 2 );
for i = 1 : nExps
    t2plot = linspace( 0, 10, size( mat2plot, 1 ) );
    disp( [ t2plot( 1 ) t2plot( end ) ] )

    % EEG example figure
    hAx( i ) = subtightplot( nExps, 1, i,...
        opts{ : } );
    plot( t2plot, mat2plot( :, i ), 'Color', cols( 1, : ) )
    ylim( yLims )

    box off
    hold off
    posX = xLims( 1 ) + 0.1;
    posY = yLims( 2 ) - 100;
        xlim( xLims )
    % axis tight
    % tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
    % text( posX, posY, tit,...
    %     'Color', 'k',...
    %     'FontWeight', 'bold',...
    %     'FontSize', 10 )

    % subplot( nExps, 2, plotIdx( i ) + 1 )
    % hAx( plotIdx( i ) + 1 ) = subtightplot( nExps, 2, plotIdx( i ) + 1,...
    %     opts{ : } );
    % plot( tExp, thisExp.L, 'Color', cols( 1, : ) )
    % hold on
    % plot( tExp, thisExp.R - offset, 'Color', cols( 2, : ) )
    % ylim( yLims )
    % box off
    % hold off
    % xLims = get( gca, 'xlim' );
    % posX = xLims( 1 ) + 0.1;
    % posY = yLims( 2 ) - 100;
    % tit = sprintf( '%s %u ug/kg', info( i ).type, info( i ).dose );
    % text( posX, posY, tit,...
    %     'Color', 'k',...
    %     'FontWeight', 'bold',...
    %     'FontSize', 10 )


end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick', [ -400 0 400 ] )
hAx( 1 ).YLabel.String = "Amp. (\muV)";
% hAx( 1 ).Title.String = "Baseline";
% hAx( 2 ).Title.String = "Injection";
% set( hAx( 2 : end ),...
%     "YTickLabel", [] )
set( hAx( end ),...
    "XTick", [ 0, 2, 4, 6, 8, 10 ], "XTickLabel", [ 0, 2, 4, 6, 8, 10 ] )
hAx( end ).XLabel.String = "time (s)";
% legend( "Left", "Right" )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )
set( findobj( "Type", "legend" ), "Position", [ 0.91 0.16 0.07 0.05 ] )

%%
% nPlots = length( t2plot );
% for plotIdx = 1 : nPlots
%     hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
%
%     plot( t2plot{ plotIdx }, dat2plot{ plotIdx, 1 },...
%         'Color', cols( 1, : ) )
%     hold on
%     plot( t2plot{ plotIdx }, dat2plot{ plotIdx, 2 } - offset,...
%         'Color', cols( 2, : ) )
%     ylim( yLims )
%     box off
%     hold off
%     ylabel( "Amp. (\muV)" )
%     xLims = get( gca, 'xlim' );
%     posX = xLims( 1 ) + 0.1;
%     posY = yLims( 2 ) - 100;
%     msg = sprintf( '%s', tits{ plotIdx } );
%     text( posX, posY, msg,...
%         'Color', 'k',...
%         'FontWeight', 'bold',...
%         'FontSize', 10 )
%
%     if plotIdx == nPlots
%         legend( "Left", "Right" )
%
%     end
%
% end
%

