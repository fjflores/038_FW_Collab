%% Save data for examples
ccc
addpath(".\Figures")

root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
maxFreq = 50;
csvFile = "example_traces_IDB.csv";
tLims = [ ];
getexampledata( resDir, maxFreq, csvFile, tLims, true )

%% Plot series of spectrograms
close all
clc

addpath(".\Figures")
root = getrootdir( );
mouseId = "M103";
resDir = fullfile( root, "Results", mouseId );
makespecfig( resDir )

%% Plot series of traces
close all

addpath(".\Figures")
root = getrootdir( );
mouseId = "M103";
resDir = fullfile( root, "Results", mouseId );
maketracefig( resDir )

%% Plot delta power across mice
ccc
P = makedeltafig( "M102" );
