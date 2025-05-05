%% Plot series of spectrograms
% close all
clc

addpath( ".\Dose_effect\" )
% miceList = { "M114", "M115", "M116", "M117", "M118", "M119",...
%     "M121", "M122", "M123" };
miceList = "M120";
epochLims = [ 600 4200 ];
fLims = [ 0 80 ];

for mouseIdx = 1 : length( miceList )
    thisMouse = miceList{ mouseIdx };
    figure( 'Name', sprintf( '%s', thisMouse ) )
    makespecfig( thisMouse, "ket", epochLims, fLims )

end


%% Plot series of traces
% close all
clc

addpath( ".\Dose_effect\" )
eventTab = fullfile( getrootdir,...
    "\Pres\2025-01-30 DARPA PI Meeting\Assets\Spec_wTraces_example.csv" );
maketracefig( eventTab )

%% Plot delta power across mice
clear all
clc
addpath( ".\Dose_effect\" )
modo = 'median';
mice = { "M102", "M103", "M105" };
for featIdx = 1 : length( mice )
    figure
    makedeltafig( mice{ featIdx } );

end

%% Plot spectrograms for the same dose across mice

% clear all
% close all
clc

addpath( ".\Dose_effect\" )

% doses = [ 0 10 30 50 100 150 ];
doses = [ 50 ];
fLims = [ 0 80 ];
for doseIdx = 1 : length( doses )
    thisDose = doses( doseIdx );
    makespecdosefig( "ket", thisDose, fLims )

end

%% Plot delta power time course after dex
clear all
clc
addpath( ".\Dose_effect\" )

doses = [ 0 10 30 50 100 150 ];
% doses = 30;
aucFlag = true;
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
close all
clc

addpath( ".\Dose_effect\" )

dbFromP = false; % Choose to convert power to db.

% root = getrootdir( );
% load( fullfile( root, "Results\Dose_Effect", "Long_Feat_Table.mat" ),...
%     "allFeats" )
% load( fullfile( root, "Results\Dose_Effect", "Feature_fits.mat" ),...
%     "mdls" )

if dbFromP
    PCols = [ 11 12 ];

else
    PCols = [ 9 10 ];

end
featCols = [ 5 : 8 PCols ];
feats2plot = allFeats.Properties.VariableNames( featCols );

figure
for i = 1 : length( feats2plot )
    hAx( i ) = subplot( 2, 3, i );
    plotlmefits( mdls, feats2plot{ i }, 'plotCI', false, 'Color', 'k' )

end
% set( hAx, "XScale", "log" )


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
addpath( ".\Dose_effect\" )

doses = [ 0 10 30 50 100 150 ];
plotavedosespec( doses )

