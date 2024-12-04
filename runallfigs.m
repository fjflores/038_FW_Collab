%% Batchprocess example data
ccc
addpath(".\DoseEffect")

mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108", "M109" };
% mList = { "M109" };
csvFile = "abc_experiment_list.xlsm";
tLims = [ 600 3600 ];
warning off
batchtidydata( mList, csvFile, tLims, true )
warning on

%% Plot series of spectrograms
% close all
clc

addpath(".\Figures")
mouseId = "M106";
tLims = [ 600 3600 ];
makespecfig( mouseId, "dex", tLims )

%% Plot series of traces
close all

addpath(".\Figures")
mouseId = "M103";
maketracefig( mouseId )

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
clc
close all
addpath( ".\Figures" )

% doses = [ 0 10 50 100 150 ];
doses = 50;
for i = 1 : length( doses )
    thisDose = doses( i ); 
    makespecdosefig( thisDose )

end

%% Plot delta power time course after dex
clear all
clc
addpath( ".\Figures" )

doses = [ 0 10 50 100 150 ];
% dose = 100;
aucFlag = false;
figure
for i = 1 : length( doses )
    thisDose = doses( i ); 
    subplot( 5, 1, i )
    plotdeltatc( thisDose, aucFlag )
    box off
    ylabel( 'Power (db)' )
    title( sprintf( "Dose: %u ug/kg", thisDose ) )
    ylim( [ 0 0.4 ] )

    if i == length( doses )
        xlabel( "time (min)" )

    end

end

%% Plot spectral edge after dex
ccc
addpath( ".\Figures" )
addpath( ".\DoseEffect\" )

doses = [ 0 10 50 100 150 ];
% dose = 100;
% figure
warning off
featTab = getavefeats( doses, [ 30 40 ] );
warning on

% figure
% plot( doses, qeeg, 'ok' )
% box off
% xlim([ -5 155 ] )
% ylim( [ 5 25 ] )
% xlabel( "dose (ug/kg)" )
% ylabel( "Frequency (Hz)")
% title( { "Median spectral edge", "30-40 min after dex" } )

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

doses = [ 0 10 50 100 150 ];
plotavedosespec( doses )

