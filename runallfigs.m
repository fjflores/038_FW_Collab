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
for i = 1 : length( mice )
    figure
    makedeltafig( mice{ i } );

end

%% Plot spectrograms for the same dose across mice

clear all
close all
clc

addpath( ".\Figures" )

% doses = [ 0 10 50 100 150 ];
doses = 30;
for i = 1 : length( doses )
    thisDose = doses( i );
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
for i = 1 : length( doses )
    thisDose = doses( i );
    subplot( length( doses ), 1, i )
    plotdeltatc( thisDose, aucFlag )
    box off
    ylabel( 'Power (db)' )
    title( sprintf( "Dose: %u ug/kg", thisDose ) )
    ylim( [ 0 0.4 ] )

    if i == length( doses )
        xlabel( "time (min)" )

    end

end

%% Plot all fits on average features over time
clear all
clc

addpath( ".\DoseEffect\" )
root = getrootdir( );
load( fullfile( root, "Results\Dose_Effect", "Time_Ave_Feats.mat" ),...
    "timeFeats" )
load( fullfile( root, "Results\Dose_Effect", "Feature_fits.mat" ),...
    "mdls" )
feats2plot = timeFeats( 1 ).featTab.Properties.VariableNames( 4 : end );

for i = 1 : length( feats2plot )
    subplot( 2, 3, i )
    plotlmefits( mdls, feats2plot{ i } )

end

%% Plot dose v. features
close all

norm = false; % Choose to normalize to baseline or not.
saveFigs = false; % Choose to save pngs or not.

if ~exist( "timeFeats", "var" )
    load( fullfile(...
        getrootdir(), 'Results', 'Dose_Effect', 'Time_Ave_Feats.mat' ),...
        'timeFeats')

end

if norm
    % Normalize to [ -5 0 ] baseline.
    timeFeatsNorm = timeFeats;
    col2Norm = [ 4 8 9 ];
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
        "rms (uV)", "sef (Hz)", "mf (Hz)",...
        "df (Hz)", "P \delta (uV^2)", "P \sigma (uV^2)" };

% % Plot all features for each epoch.
% for epochIdx = 1 : length( timeFeats2plot )
%     featTab = timeFeats2plot( epochIdx ).featTab;
%     epoch = timeFeats2plot( epochIdx ).epoch;
%     figure( 'Name', sprintf( '%i to %i mins', epoch( : ) ) )
%     for i = 1 : 6
%         hAx( i ) = subplot( 2, 3, i );
%         % hLines = plot( featTab{ :, 3 }, featTab{ :, i + 3 }, "Color", [ 0.5 0.5 0.5 ] );
%         scatter( featTab.dose, featTab{ :, i + 3 }, 20, 'k', 'filled' )
%         box off
%         xlim( [ -10 160 ] )
%         hold on
% 
%         if norm
%             switch i
%                 case 1
%                     ylim( [ 0 4 ] )
%                     yline( 1, ':' )
%                 case 5
%                     ylim( [ 0 20 ] )
%                     yline( 1, ':' )
%                 case 6
%                     ylim( [ 0 3.1 ] )
%                     yline( 1, ':' )
%                 end
% 
%         else
%             switch i
%                 case 1
%                     ylim( [ 0 220 ] )
%                 case 5
%                     ylim( [ 0 2.5 ] )
%                 case 6
%                     ylim( [ 0 0.11 ] )
%             end
% 
%         end
% 
%         switch i
%             case 2
%                 ylim( [ 0 16 ] )
%             case 3
%                 ylim( [ 0 7 ] )
%             case 4
%                 ylim( [ 0 8 ] )
%         end
% 
%         title( tits{ i } )
% 
%     end
% 
%     xLabString = sprintf( "Dose (%cg/kg)", 956 );
%     hAx( 4 ).XLabel.String = xLabString;
%     hAx( 5 ).XLabel.String = xLabString;
%     hAx( 6 ).XLabel.String = xLabString;
% 
%     if saveFigs
%         saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
%             sprintf( '%s%i_to_%i_mins.png', normMsg, epoch( : ) ) ) )
%     end
% end

% Plot each feature for all epochs.
for featIdx = 1 : 6    
    figure( 'Name', tits{ featIdx } )    
    for epIdx = 1 : length( timeFeats2plot )
        featTab = timeFeats2plot( epIdx ).featTab;
        epoch = timeFeats2plot( epIdx ).epoch;
        hAx( epIdx ) = subplot( 2, length( timeFeats2plot ) / 2, epIdx );
        scatter( featTab.dose, featTab{ :, featIdx + 3 }, 20, 'k', 'filled' )
        box off
        xlim( [ -10 160 ] )
        hold on

        if norm
            switch featIdx
                case 1
                    ylim( [ 0 4 ] )
                    yline( 1, ':' )
                case 5
                    ylim( [ 0 20 ] )
                    yline( 1, ':' )
                case 6
                    ylim( [ 0 3.1 ] )
                    yline( 1, ':' )
            end

        else
            switch featIdx
                case 1
                    ylim( [ 0 220 ] )
                case 5
                    ylim( [ 0 2.5 ] )
                case 6
                    ylim( [ 0 0.11 ] )
            end

        end

        switch featIdx
            case 2
                ylim( [ 0 16 ] )
            case 3
                ylim( [ 0 7 ] )
            case 4
                ylim( [ 0 8 ] )
        end

        title( sprintf( '%i to %i min', epoch( : ) ) )
        xLabString = sprintf( "Dose (%cg/kg)", 956 );
        if epIdx > length( timeFeats2plot ) / 2
            xlabel( xLabString );
        end

    end

    % if saveFigs
    %     saveas( gcf, fullfile( getrootdir(), 'Results', 'Dose_Effect',...
    %         sprintf( '%s%i_to_%i_mins.png', normMsg, epoch( : ) ) ) )
    % end
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