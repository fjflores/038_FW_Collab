%% Save data for examples
ccc
addpath(".\Figures")

mouseId = "M103";
maxFreq = 50;
csvFile = "example_traces_IDB.csv";
tLims = [ ];
getexampledata( mouseId, maxFreq, csvFile, tLims, true )

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
modo = 'median';
mice = { "M102", "M103" };
figure
for i = 1 : 2
    subplot( 2, 1, i )
    makedeltafig( mice{ i }, modo, false );
    if i == 2
        legend( 'saline', '10', '50', '100', '150' )

    end
    ylim( [ 0 6000 ] )
    title( mice{ i } )

end

% end
