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
clear all
clc
addpath(".\Figures")
modos = { 'mean', 'median', 'total' };

figure
for i = 1 : 3
    subplot( 3, 1, i )
    makedeltafig( "M102", modos{ i }, false );

end
