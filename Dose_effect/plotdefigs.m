%% Load data and set options for dose v. feature figures.
% Run this section before running either of the two following feature
% plotting sections.

ccc
% close all

addpath( ".\Dose_effect\" )

norm = false; % Choose to normalize to baseline or not.
dbFromP = true; % Choose to convert power to db.
saveFigs = true; % Choose to save pngs or not.

if ~exist( "allFeats", "var" )
    load( fullfile(...
        getrootdir(), 'Results', 'Dose_Effect', 'Long_Feat_Table.mat' ),...
        'allFeats')

end

load( fullfile(...
    getrootdir(), 'Results', 'Dose_Effect', 'Feature_fits.mat' ),...
    'mdls' )
featList = allFeats.Properties.VariableNames( 5 : 12 );

yLims = [ 0 240; 7 16; 0.5 7.5; 0 8; 0 2.5; 0 0.11; -19 4; -22 -9 ];

if dbFromP
    PUnits = 'db';
    PCols = [ 11 12 ];

else
    PUnits = sprintf( '%cV^2', 956 );
    PCols = [ 9 10 ];
end

featCols = [ 5 : 8 PCols ];
feats2plot = featList( featCols - 4 );
epochList = unique( allFeats.epochOrdinal );
    
if norm
    % Normalize to [ -5 0 ] baseline.
    warning( [ 'Plotting linear model fits on top of scatters does ',...
        'not currently work with normalized data.' ] );
    allFeatsNorm = allFeats;
    col2Norm = [ 5 9 : 12 ];

    expList = unique( allFeats.expId );
    for expIdx = 1 : length( expList )
        thisExp = expList( expIdx );
        allFeatsNorm( allFeatsNorm.expId == thisExp, col2Norm ) =...
        allFeats( allFeats.expId == thisExp, col2Norm )...
            ./ allFeats( allFeats.expId == thisExp &...
            allFeats.epochOrdinal == 0, col2Norm );

    end

    yLims( col2Norm - 4, : ) = [ 0 4.5; 0 20; 0 3.1; -1 2.5; 0.5 1.5 ];
    allFeats2plot = allFeatsNorm;
    normMsg = 'norm_';

else 
    allFeats2plot = allFeats;
    normMsg = '';

end

plotLMEOpts = { 'PlotCI', true, 'Color', [ 0.1 0.6 0.7 ] };
tits = {...
        sprintf( "rms (%cV)", 956 ), "sef (Hz)", "mf (Hz)",...
        "df (Hz)",...
        sprintf( "P %c (%s)", 948, PUnits ),...
        sprintf( "P %c (%s)", 963, PUnits ) };


%% Plot all features for each epoch.

% 1) Run 'Load data and set options for dose v. feature figures.' section.

% 2) Plot.
for epIdx = 1 : length( epochList )
    thisEpOrd = epochList( epIdx );
    featTab = allFeats2plot( allFeats2plot.epochOrdinal == thisEpOrd, : );
    tmp1 = allFeats2plot{ allFeats2plot.epochOrdinal == thisEpOrd, 'epoch' };
    tmp2 = tmp1{ 1 };
    tmp3 = regexp( tmp2, '(\S*\d+) -- (\d+)', 'tokens' );
    epoch = str2double( tmp3{ 1 } );
    figure( 'Name', sprintf( '%i to %i mins', epoch( : ) ),...
        'Units', 'normalize', 'Position', [ 0.3536 0.1639 0.4609 0.6481 ] )
    for featIdx = 1 : 6
        thisFeat = featCols( featIdx );
        hAx( featIdx ) = subplot( 2, 3, featIdx );
        hold on
        scatter( featTab.dose, featTab{ :, thisFeat },...
            20, [ 0.5 0.5 0.5 ], 'filled' )
        plotlmefits( mdls( epIdx ), feats2plot{ featIdx },...
            plotLMEOpts{ : } )
        ylabel( '' )
        box off
        xlim( [ -10 160 ] )
        xticks( [ 0 : 50 : 150 ] )
        hold on

        if norm & ismember( featIdx, [ 1 5 6 ] )
            yline( 1, ':' );
        end

        ylim( yLims( thisFeat - 4, : ) )
        title( tits{ featIdx } )
        xLabString = sprintf( "Dose (%cg/kg)", 956 );
        if epIdx > 3
            xlabel( xLabString );
        else
            xlabel( '' );
        end

    end

    set( hAx, 'FontSize', 12 )

    if saveFigs
        saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
            sprintf( '%s%i_to_%i_mins.png', normMsg, epoch( : ) ) ) )
    end

end


%% Plot each feature across all epochs.

% 1) Run 'Load data and set options for dose v. feature figures.' section.

% 2) Plot.

% epochList = [ 0 2 7 12 ];
for featIdx = 1 : 6
    thisFeat = featCols( featIdx );
    figure( 'Name', tits{ featIdx },...
        'Units', 'normalize', 'Position', [ 0.2151 0.2074 0.6531 0.6185 ] )
    for epIdx = 1 : length( epochList )
        thisEpOrd = epochList( epIdx );
        featTab = allFeats2plot( allFeats2plot.epochOrdinal == thisEpOrd, : );
        tmp1 = allFeats2plot{ allFeats2plot.epochOrdinal == thisEpOrd, 'epoch' };
        tmp2 = tmp1{ 1 };
        tmp3 = regexp( tmp2, '(\S*\d+) -- (\d+)', 'tokens' );
        epoch = str2double( tmp3{ 1 } );
        hAx( epIdx ) = subplot( 2, length( epochList ) / 2, epIdx );
        % hAx( epIdx ) = subplot( 1, length( epochList ), epIdx );
        hold on
        scatter( featTab.dose, featTab{ :, thisFeat },...
            20, [ 0.5 0.5 0.5 ], 'filled' )
        plotlmefits( mdls( epIdx ), feats2plot{ featIdx },...
            plotLMEOpts{ : } )
        % plotlmefits( mdls( thisEpOrd + 1 ), feats2plot{ featIdx },...
        %     plotLMEOpts{ : } )
        ylabel( '' )
        box off
        xlim( [ -10 160 ] )
        xticks( [ 0 : 50 : 150 ] )
        hold on

        if norm & ismember( featIdx, [ 1 5 6 ] )
            yline( 1, ':' );
        end
            
        ylim( yLims( thisFeat - 4, : ) )
        title( sprintf( '%i to %i mins', epoch( : ) ) )
        xLabString = sprintf( "Dose (%cg/kg)", 956 );
        if epIdx > length( epochList ) / 2
            xlabel( xLabString );
        else
            xlabel( '' );
        end

        if epIdx == 1 || epIdx == ( length( epochList ) / 2 ) + 1
            ylabel( tits{ featIdx } );
        end

    end

    set( hAx, 'FontSize', 12 )
    linkaxes( hAx( : ), 'xy' )

    if saveFigs
        saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
            sprintf( '%s.png',...
            allFeats2plot.Properties.VariableNames{ thisFeat } ) ) )
    end

end
