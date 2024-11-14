function expMetaData = getmetadata( expID, tabPath )
% GETMETADATA gets the experiment metadata based on the exp ID.
% 
% Usage:
% expMetaData = getmetadata( expID, tabPath )
% expMetaData = getmetadata( expID )
% 
% Input:
% expID: experiment correlative number.
% tabPath: path to table with experiments metadata. Default: project
% "Results" folder.
% 
% Output:
% expMetaData: structure with main meta data from experiments table.

if nargin < 2
    tabPath = fullfile( getrootdir, "Results" );
    
end

expTab = readtable( fullfile( tabPath,...
    "abc_experiment_list.xlsm" )  );
expIdx = expTab.exp_id == expID;
analyzeMask = expTab.analyze( expIdx );
subject = expTab.mouse_id( expIdx );
dexDose = expTab.drug_dose( expIdx );
expDate = expTab.date( expIdx );
expNumber = expTab.exp_number( expIdx );
expType = expTab.exp_type( expIdx );
expName = expTab.exp_name( expIdx );
nlynxDir = expTab.nlyx_folder( expIdx );
bonsaiSuff = expTab.bonsai_suffix( expIdx );
vidFileList = expTab{ expIdx, [ "topview_vid_file",...
    "sideview_vid_file",...
    "topview_led_file",...
    "sideview_led_file",...
    "vid_rec_ts_file" ] };
ephysFileList = expTab{ expIdx, [ "EEG_L", "EEG_R", "EMG" ] };
chValid = expTab{ expIdx,...
    [ "analyze_EEG_L", "analyze_EEG_R", "analyze_EMG" ] };


expMetaData.analyzeMask = analyzeMask;
expMetaData.subject = subject{ 1 };
expMetaData.dexDose = dexDose;
expMetaData.date = expDate{ 1 };
expMetaData.expNumber = expNumber{ 1 };
expMetaData.expType = expType{ 1 };
expMetaData.expName = expName{ 1 };
expMetaData.nlynxDir = nlynxDir{ 1 };
expMetaData.bonsaiSuff = bonsaiSuff{ 1 };
expMetaData.vidFileList = vidFileList;
expMetaData.ephysFileList = ephysFileList;
expMetaData.chValid = chValid;


end

