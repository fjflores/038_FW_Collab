%% Save data for examples
ccc
addpath(".\Figures")

mouseId = "M103";
maxFreq = 50;
csvFile = "example_traces_IDB.csv";
tLims = [ ];
getexampledata( mouseId, maxFreq, csvFile, tLims, true )

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

% end
