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
% 'Results' folder.
% 
% Output:
% expMetaData: structure with main meta data from experiments table.

if nargin < 2
    tabPath = fullfile( getrootdir, 'Results' );
    
end

expTab = readtable( fullfile( tabPath,...
    'abc_experiment_list.xlsm' )  );
expIdx = expTab.exp_id == expID;
subject = expTab.mouse_id( expIdx );
nlynxDir = expTab.nlyx_folder( expIdx );
expNumber = expTab.exp_number( expIdx );
expDate = expTab.date( expIdx );
fileList = expTab{ expIdx, [ "EEG_F", "EEG_P", "EMG" ] };
analyzeMask = expTab.analyze( expIdx );
expName = expTab.exp_name( expIdx );
vidName = expTab.video_file( expIdx );
chValid = expTab{ expIdx,...
    [ "analyze_EEG_F", "analyze_EEG_P", "analyze_EMG" ] };
consc = expTab.consciousness( expIdx );

expMetaData.subject = subject{ 1 };
expMetaData.nlynxDir = nlynxDir{ 1 };
expMetaData.expNumber = expNumber{ 1 };
expMetaData.date = expDate{ 1 };
expMetaData.fileList = fileList;
expMetaData.analyzeMask = analyzeMask;
expMetaData.expName = expName{ 1 };
expMetaData.vidName = vidName{ 1 };
expMetaData.chValid = chValid;
expMetaData.consciousness = consc{ 1 };

