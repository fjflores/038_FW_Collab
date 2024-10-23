%% Save data for examples
ccc
addpath(".\Figures")

mouseId = "M106";
maxFreq = 50;
csvFile = "example_traces.csv";
tLims = [ ];
getexampledata( mouseId, maxFreq, csvFile, tLims, true )

%% batchprocess example data
ccc
addpath(".\Figures")

mList = { "M101", "M102", "M103", "M105", "M106", "M107", "M108" };
maxFreq = 50;
csvFile = "example_traces.csv";
tLims = [ ];
batchexampledata( mList, maxFreq, csvFile, tLims, true )

%% Plot series of spectrograms
% close all
clc

addpath(".\Figures")
mouseId = "M103";
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

%% Plot spectrograms across mice for the same dose
clear all
clc
addpath( ".\Figures" )

doses = [ 0 10 50 100 150 ];
for i = 1 : length( doses )
thisDose = doses( i ); 
makespecdosefig( thisDose )

end