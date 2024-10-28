%% Batchprocess example data
ccc
addpath(".\Figures")

mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108" };
% mList = { "M102" };
csvFile = "example_traces.csv";
tLims = [ 600 3600 ];
batchexampledata( mList, csvFile, tLims, true )

%% Plot series of spectrograms
% close all
clc

addpath(".\Figures")
mouseId = "M105";
makespecfig( mouseId )

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
nomalizeFlag = false;
for i = 1 : length( doses )
    thisDose = doses( i ); 
    makespecdosefig( thisDose, nomalizeFlag )

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

%% Plot dominant freqeuency time course after dex in the delta band
clear all
clc
addpath( ".\Figures" )

doses = [ 0 10 50 100 150 ];
% dose = 100;
figure
for i = 1 : length( doses )
    thisDose = doses( i ); 
    subplot( 5, 1, i )
    plotdeltadf( thisDose )
    title( sprintf( "Dose: %u %cg/kg", thisDose, 956 ) )
    % ylim( [ 0 0.4 ] )

    if i == length( doses )
        xlabel( "time (min)" )

    end

end