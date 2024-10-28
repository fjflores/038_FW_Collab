%% Batchprocess example data
ccc
addpath(".\Figures")

% mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108" };
mList = { "M102" };
csvFile = "example_traces.csv";
tLims = [ 600 3600 + 600 ];
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
mice = { "M102", "M103" };
for i = 1 : length( mice )
    figure
    makedeltafig( mice{ i } );

end

%% Plot spectrograms for the same dose across mice 
clear all
clc
close all
addpath( ".\Figures" )

doses = [ 0 10 50 100 150 ];
% doses = 50;
nomalizeFlag = false;
for i = 1 : length( doses )
    thisDose = doses( i ); 
    makespecdosefig( thisDose, nomalizeFlag )

end