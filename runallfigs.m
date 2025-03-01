%% Batchprocess example data
ccc
addpath(".\DoseEffect")

% mList = {...
%     "M101", "M102", "M103",...
%     "M105", "M106", "M107", "M108",...
%     "M109", "M111", "M112", "M113" };
mList = { "M112" };
csvFile = "abc_experiment_list.xlsm";
epochLims = [ 600 3600 ];
warning off
batchtidydata( mList, csvFile, epochLims, true )
warning on

%% Plot series of spectrograms
% close all
clc

addpath(".\Figures")
mouseID = "M108";
epochLims = [ 600 3600 ];

figure( 'Name', sprintf( '%s', mouseID ) )
makespecfig( mouseID, "dex", epochLims )


%% Plot series of traces
% close all
clc

addpath(".\Figures")
eventTab = fullfile( getrootdir,...
    "\Pres\2025-01-30 DARPA PI Meeting\Assets\Spec_wTraces_example.csv" );
maketracefig( eventTab )

%% Plot delta power across mice
clear all
clc
addpath(".\Figures")
modo = 'median';
mice = { "M102", "M103", "M105" };
for featIdx = 1 : length( mice )
    figure
    makedeltafig( mice{ featIdx } );

end

%% Plot spectrograms for the same dose across mice

clear all
close all
clc

addpath( ".\Figures" )

% doses = [ 0 10 50 100 150 ];
doses = 30;
for featIdx = 1 : length( doses )
    thisDose = doses( featIdx );
    makespecdosefig( thisDose )

end

%% Plot delta power time course after dex
clear all
clc
addpath( ".\Figures" )

% doses = [ 0 10 50 100 150 ];
doses = 30;
aucFlag = false;
figure
for featIdx = 1 : length( doses )
    thisDose = doses( featIdx );
    subplot( length( doses ), 1, featIdx )
    plotdeltatc( thisDose, aucFlag )
    box off
    ylabel( 'Power (db)' )
    title( sprintf( "Dose: %u ug/kg", thisDose ) )
    ylim( [ 0 0.4 ] )

    if featIdx == length( doses )
        xlabel( "time (min)" )

    end

end

%% Plot all fits on average features over time
% clear all
clc

addpath( ".\DoseEffect\" )

dbFromP = true; % Choose to convert power to db.

root = getrootdir( );
load( fullfile( root, "Results\Dose_Effect", "Time_Ave_Feats.mat" ),...
    "timeFeats" )
load( fullfile( root, "Results\Dose_Effect", "Feature_fits.mat" ),...
    "mdls" )

if dbFromP
    PCols = [ 10 11 ];

else
    PCols = [ 8 9 ];

end
featCols = [ 4 : 7 PCols ];
feats2plot = timeFeats( 1 ).featTab.Properties.VariableNames( featCols );

figure
for i = 1 : length( feats2plot )
    hAx( i ) = subplot( 2, 3, i );
    plotlmefits( mdls, feats2plot{ i }, true )

end
% set( hAx, "XScale", "log" )

%% Load data and set options for dose v. feature figures.

ccc
% close all

addpath( './DoseEffect/' )

norm = false; % Choose to normalize to baseline or not.
dbFromP = true; % Choose to convert power to db.
saveFigs = false; % Choose to save pngs or not.

if ~exist( "timeFeats", "var" )
    load( fullfile(...
        getrootdir(), 'Results', 'Dose_Effect', 'Time_Ave_Feats.mat' ),...
        'timeFeats')

end

load( fullfile(...
    getrootdir(), 'Results', 'Dose_Effect', 'Feature_fits.mat' ),...
    'mdls' )
featList = timeFeats( 1 ).featTab.Properties.VariableNames( 4 : end );

if dbFromP
    PUnits = 'db';
    PCols = [ 10 11 ];

else
    PUnits = sprintf( '%cV^2', 956 );
    PCols = [ 8 9 ];

end

featCols = [ 4 : 7 PCols ];
feats2plot = featList( featCols - 3 );
    
if norm
    % Normalize to [ -5 0 ] baseline.
    warning( [ 'Plotting linear model fits on top of scatters does ',...
        'not currently work with normalized data.' ] );
    timeFeatsNorm = timeFeats;
    col2Norm = [ 4 PCols ];
    for epIdx = 1 : length( timeFeats )
        timeFeatsNorm( epIdx ).featTab( :, col2Norm ) = ...
            timeFeats( epIdx ).featTab( :, col2Norm )...
            ./ timeFeats( 1 ).featTab( :, col2Norm );

    end
    timeFeats2plot = timeFeatsNorm;
    normMsg = 'norm_';

else 
    timeFeats2plot = timeFeats;
    normMsg = '';

end

tits = {...
        sprintf( "rms (%cV)", 956 ), "sef (Hz)", "mf (Hz)",...
        "df (Hz)",...
        sprintf( "P %c (%s)", 948, PUnits ),...
        sprintf( "P %c (%s)", 963, PUnits ) };


%% Plot all features for each epoch.

% 1) Run 'Load data and set options for dose v. feature figures.' section.

% 2) Plot.
for epochIdx = 1 : length( timeFeats2plot )
    featTab = timeFeats2plot( epochIdx ).featTab;
    epoch = timeFeats2plot( epochIdx ).epoch;
    figure( 'Name', sprintf( '%i to %i mins', epoch( : ) ) )
    for featIdx = 1 : 6
        thisFeat = featCols( featIdx );
        hAx( featIdx ) = subplot( 2, 3, featIdx );
        hold on
        scatter( featTab.dose, featTab{ :, thisFeat }, 20, 'k', 'filled' )
        plotlmefits( mdls( epochIdx ), feats2plot{ featIdx } )
        ylabel( '' )
        box off
        xlim( [ -10 160 ] )
        xticks( [ 0 : 50 : 150 ] )
        hold on

        if norm
            switch featIdx
                case 1
                    ylim( [ 0 4 ] )
                    yline( 1, ':' )
                case 5
                    if dbFromP
                        ylim( [ -5 2 ] )
                    else
                        ylim( [ 0 20 ] )
                    end
                    yline( 1, ':' )

                case 6
                    if dbFromP
                        ylim( [ 0.6 1.4 ] )
                    else
                        ylim( [ 0 3.1 ] )
                    end
                    yline( 1, ':' )

            end

        else
            switch featIdx
                case 1
                    ylim( [ 0 220 ] )
                case 5
                    if dbFromP                    
                        ylim( [ -15 5 ] )
                    else
                        ylim( [ 0 2.5 ] )
                    end

                case 6
                    if dbFromP
                        ylim( [ -22 -8 ] )
                    else
                        ylim( [ 0 0.11 ] )
                    end

            end

        end

        switch featIdx
            case 2
                ylim( [ 7 16 ] )
            case 3
                ylim( [ 1 7 ] )
            case 4
                ylim( [ 0 8 ] )
        end

        title( tits{ featIdx } )
        xLabString = sprintf( "Dose (%cg/kg)", 956 );
        if epochIdx > 3
            xlabel( xLabString );
        else
            xlabel( '' );
        end

    end

    if saveFigs
        saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
            sprintf( '%s%i_to_%i_mins.png', normMsg, epoch( : ) ) ) )
    end

end


%% Plot each feature for all epochs.

% 1) Run 'Load data and set options for dose v. feature figures.' section.

% 2) Plot.
for featIdx = 1 : 6
    thisFeat = featCols( featIdx );
    figure( 'Name', tits{ featIdx } )
    for epIdx = 1 : length( timeFeats2plot )
        featTab = timeFeats2plot( epIdx ).featTab;
        epoch = timeFeats2plot( epIdx ).epoch;
        hAx( epIdx ) = subplot( 2, length( timeFeats2plot ) / 2, epIdx );
        hold on
        scatter( featTab.dose, featTab{ :, thisFeat },...
            20, [ 0.5 0.5 0.5 ], 'filled' )
        plotlmefits( mdls( epIdx ), feats2plot{ featIdx }, true )
        ylabel( '' )
        box off
        xlim( [ -10 160 ] )
        xticks( [ 0 : 50 : 150 ] )
        hold on

        if norm
            switch featIdx
                case 1
                    ylim( [ 0 4 ] )
                    yline( 1, ':' )
                case 5
                    if dbFromP
                        ylim( [ -5 2 ] )
                    else
                        ylim( [ 0 20 ] )
                    end
                    yline( 1, ':' )
                case 6
                    if dbFromP
                        ylim( [ 0.6 1.4 ] )
                    else
                        ylim( [ 0 3.1 ] )
                    end
                    yline( 1, ':' )
            end

        else
            switch featIdx
                case 1
                    ylim( [ 0 220 ] )
                case 5
                    if dbFromP
                        ylim( [ -15 5 ] )
                    else
                        ylim( [ 0 2.5 ] )
                    end
                case 6
                    if dbFromP
                        ylim( [ -22 -8 ] )
                    else
                        ylim( [ 0 0.11 ] )
                    end
            end

        end

        switch featIdx
            case 2
                ylim( [ 7 16 ] )
            case 3
                ylim( [ 1 7 ] )
            case 4
                ylim( [ 0 8 ] )
        end

        title( sprintf( '%i to %i min', epoch( : ) ) )
        xLabString = sprintf( "Dose (%cg/kg)", 956 );
        if epIdx > length( timeFeats2plot ) / 2
            xlabel( xLabString );
        else
            xlabel( '' );
        end

        if epIdx == 1 || epIdx == 7
            ylabel( tits{ featIdx } );
        end

    end

    % if saveFigs
    %     saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
    %         sprintf( '%s%i_to_%i_mins.png', normMsg, epoch( : ) ) ) )
    % end

    set( hAx, 'FontSize', 12 )

end


%% Fit an exponential decay model to the data
x = repmat( doses, size( qeeg, 1 ), 1 );
x = x( : );
y = qeeg( : );
idxNan = isnan( y );
x( idxNan ) = [ ];
y( idxNan ) = [ ];
fitType = fittype(...
    'a*exp(b*x) + c*exp(d*x)',...
    'independent', 'x',...
    'dependent', 'y' );
fitOptions = fitoptions(...
    'Method', 'NonlinearLeastSquares',...
    'StartPoint', [ 1, -0.1, 1, -0.01 ] );
[fitResult, gof] = fit( x, y, fitType, fitOptions );

% Display the fit results
disp( fitResult );
plot( fitResult, x, y );
xlabel( 'X Data' );
ylabel( 'Y Data' );
title( 'Exponential Decay Fit' );
legend( 'Data', 'Fitted Curve' );
xlim([ -5 155 ] )
ylim( [ 5 25 ] )


%% Plot average spectrogram for each dose
clear all
clc
addpath( ".\Figures" )

doses = [ 0 10 30 50 100 150 ];
plotavedosespec( doses )


%% Plot example exp at each dose

% CONVERT TO FX
doses = [ 0 10 30 50 100 150 ];

exampleTab = table( doses',...
    [ 35; 63; 73; 36; 14; 37 ],...
    VariableNames = { 'dose', 'expID' } );


% Plot example spec for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [ 0.1 0.1 ];
opts = { gap, margH, margV };

yLims = [ 0 40 ];

figure
colormap magma
nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    thisExp = exampleTab.expID( exampleTab.dose == thisDose );

    metDat = getmetadata( thisExp );

    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    load( fullfile( resDir, f2load ), "spec", "notes" );
    tabExpIdx = find( [ notes.expId ] == thisExp );
    Sdose( :, : ) = spec( tabExpIdx ).SL;

    t = spec( tabExpIdx ).t / 60;
    f = spec( tabExpIdx ).f;

    hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    imagesc( t, f, pow2db( Sdose' ) )
    axis xy
    box off
    clim( [ -35 -5 ] )
    ylim( yLims )
    ylabel( 'Freq. (Hz)' )
    xLims = get( gca, 'xlim' );
    posX = xLims( 1 ) + 2;
    posY = yLims( 2 ) - 5;

    if thisDose == 0
        tit = "Saline";
        title( "Example spectrogram per dose")

    else
        tit = sprintf( "Dose: %u %cg/kg", thisDose, 956 );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( 'Freq. (Hz)' )

    clear S Sdose spec info

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : 30  )
ffcbar( gcf, hAx( end ), "Power (dB)" );

set( hAx( end ),...
    "XTick", -10 : 10 : 60,...
    "XTickLabel", -10 : 10 : 60 )
xlabel( hAx( end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )