%% Batchprocess mice to get tidy data
ccc
addpath( ".\Dose_effect\" )

allFWMice = { "FW14", "FW16", "FW17", "FW18" };
drugs = { "combo", "combo_dex", "combo_ket" }; 
%csvFile = "abc_experiment_list.xlsm";
% tLims = [ 600 4200 ]; % for dex experiments
tLims = [ 600 5400 ]; % for ket experiments
saveFlag = true;  
warning off
for drugIdx = 1 : numel( drugs )
    batchtidydata( allFWMice, drugs{ drugIdx }, tLims, saveFlag )

end
warning on