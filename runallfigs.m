%% Plot traces per dose per mouse
ccc
addpath("D:\Code\Projects\034_ABC\Figures")

root = getrootdir( );
mouseId = "M102";
resDir = fullfile( root, "Results", mouseId );
getexampledata( resDir, false )

%%
maketracefig( resDir )