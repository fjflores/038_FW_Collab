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
consc = expTab.consciousness( expIdx );
subject = expTab.mouse_id( expIdx );
expDate = expTab.date( expIdx );
expNumber = expTab.exp_number( expIdx );
expType = expTab.exp_type( expIdx );
expName = expTab.exp_name( expIdx );
nlynxDir = expTab.nlyx_folder( expIdx );
bonsaiSuff = expTab.bonsai_suffix( expIdx );
vidFileList = expTab{ expIdx, [ "flir_video_file",...
    "kinect_rgb_video_file",...
    "kinect_ir_video_file",...
    "kinect_depth_file",...
    "flir_led_file",...
    "kin_rgb_led_file",...
    "kin_ir_led_file" ] };
ephysFileList = expTab{ expIdx, [ "EEG_L", "EEG_R", "EMG" ] };
chValid = expTab{ expIdx,...
    [ "analyze_EEG_L", "analyze_EEG_R", "analyze_EMG" ] };


expMetaData.analyzeMask = analyzeMask;
expMetaData.consciousness = consc{ 1 };
expMetaData.subject = subject{ 1 };
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

