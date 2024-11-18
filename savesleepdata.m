function savesleepdata( mouseId, saveFlag )
% ACCUSLEEP create the AccuSleepX files

% Set defaults
if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

root = getrootdir( );
resDir = fullfile( root, "Results" );
csvFile = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( resDir, csvFile ) );

% get experiments to load
% doseSortTab = sortrows( masterTab, "drug_dose" );
exps2procIdx = ...
    masterTab.analyze == 1 & ...
    masterTab.mouse_id == mouseId & ...
    masterTab.drug == "dex";
exps2proc = masterTab.exp_id( exps2procIdx );

% load dex experiment
t1 = tic;
nExps = length( exps2proc );
for expIdx = 1 : nExps
    thisExp = exps2proc( expIdx );
    thisExpIdx = masterTab.exp_id == thisExp;
    fprintf( 'Loading %s exp %u...', mouseId, thisExp )
    [ eegRaw, emgRaw ] = loadprocdata( thisExp, { "eegClean", "emgRaw" } );
    fprintf( 'done.\n' )

    % make AccuSleep directory
    if expIdx == 1
        accDir = fullfile( resDir, mouseId, "AccuSleep" );
        mkdir( accDir )

    end

    EEG = eegRaw.data;
    EMG = emgRaw.data;
    sessDir = fullfile( accDir, masterTab.exp_name );

    try
        save( fullfile( sessDir, "EEG.mat" ), "EEG" )
        save( fullfile( sessDir, "EMG.mat" ), "EMG" )

    catch
        mkdir( sessDir )
        save( fullfile( sessDir, "EEG.mat" ), "EEG" )
        save( fullfile( sessDir, "EMG.mat" ), "EMG" )

    end


end