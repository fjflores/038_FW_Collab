%% Save data for examples
ccc
addpath(".\Figures")

root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
maxFreq = 50;
csvFile = "example_traces_IDB.csv";
getexampledata( resDir, maxFreq, csvFile, true )

%% Plot series of spectrograms
close all
clc

addpath(".\Figures")
root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
makespecfig( resDir )

%%
close all

addpath(".\Figures")
root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
maketracefig( resDir )