%% Batchprocess example data
ccc
addpath(".\DoseEffect")

mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108", "M109", "M111", "M112", "M113" };
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
mouseID = "M109";
tLims = [ 600 3600 ];

figure( 'Name', sprintf( '%s', mouseID ) )
makespecfig( mouseID, "dex", tLims )


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

%% Plot dose v. features
figure
tits = { "rms (uV)", "sef (Hz)", "mf (Hz)", "df (Hz)", "P_{delta} (uV^2)", "P_{spindle} (uV^2)" };
for i = 1 : 6
    hAx( i ) = subplot( 2, 3, i );
    scatter( featTab.dose, featTab{ :, i + 3 }, 20, 'k', 'filled' )
    box off
    xlim( [ -10 160 ] )

    if i == 1
        ylim( [ 0 300 ] )

    elseif i == 5
        ylim( [ 0 2.5 ] )

    end
    title( tits{ i } )

end

hAx( 4 ).XLabel.String = "dose (ug/kg)";
hAx( 5 ).XLabel.String = "dose (ug/kg)";
hAx( 6 ).XLabel.String = "dose (ug/kg)";
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