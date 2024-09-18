%% Save data for examples
ccc
addpath(".\Figures")

root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
maxFreq = 50;
getexampledata( resDir, maxFreq, [], true )

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