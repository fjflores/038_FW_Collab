%% Single-process gettidydata

ccc
mouse = "FW14";
drug = { 'combo' };
tLims = [ 600 7200 ];
saveFlag = true;
warning off
gettidydatafw( mouse, drug, tLims, saveFlag )
warning on

%% Batchprocess mice to get tidy data
ccc
addpath( ".\Dose_effect\" )

allFWMice = { "FW14", "FW16", "FW17", "FW18" };
drugs = { "combo", "combo_heatpad" }; 
%csvFile = "abc_experiment_list.xlsm";
% tLims = [ 600 4200 ]; % for dex experiments
tLims = [ 600 7200 ]; % for ket experiments
saveFlag = true;  
warning off
for drugIdx = 1 : numel( drugs )
    batchtidydatafw( allFWMice, drugs{ drugIdx }, tLims, saveFlag )

end
warning on