%% Plot traces per dose per mouse
ccc
addpath(".\Figures")

root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
getexampledata( resDir, true )

%%
maketracefig( resDir )