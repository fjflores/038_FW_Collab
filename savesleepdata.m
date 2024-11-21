function savesleepdata( mouseId )
% ACCUSLEEP create the AccuSleepX files
% 
% Usage:
% savesleepdata( mouseId, saveFlag )
% 
% Input:
% mouseId: single string or cell list with mouse names.

% Set defaults
if ~exist( "saveFlag", "var" )
    saveFlag = true;

end

root = getrootdir( );
resDir = fullfile( root, "Results" );
csvFile = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( resDir, csvFile ) );

nMice = length( mouseId );
if isstring( mouseId )
    tmp{ 1 } = mouseId;
    mouseId = tmp;

elseif ischar( mouseId ) && nMice > 1
    tmp{ 1 } = mouseId;
    mouseId = tmp;
    nMice = length( mouseId );

end

% get experiments to load
for miceIdx = 1 : nMice
    thisMouse = mouseId{ miceIdx };
    exps2procIdx = ...
        masterTab.analyze == 1 & ...
        masterTab.mouse_id == thisMouse ;
    exps2proc = masterTab.exp_id( exps2procIdx );

    % load dex experiment
    t1 = tic;
    nExps = length( exps2proc );
    fprintf( "Saving %s data for sleep scoring...\n", thisMouse )
    for expIdx = 1 : nExps
        thisExp = exps2proc( expIdx );
        thisExpIdx = masterTab.exp_id == thisExp;
        [ eegRaw, emgRaw ] = loadprocdata( thisExp, { "eegClean", "emgRaw" } );

        % make AccuSleep directory
        if expIdx == 1
            accDir = fullfile( resDir, thisMouse, "AccuSleep" );
            mkdir( accDir )

        end
    
        EEG = eegemgfilt( eegRaw.data( :, 1 ), [ 0.5 300 ], eegRaw.Fs );
        EMG = eegemgfilt( emgRaw.data, [ 10 1000 ], eegRaw.Fs ); 
        sessDir = fullfile( accDir, masterTab.exp_name( thisExpIdx ) );

        try
            save( fullfile( sessDir, "EEG.mat" ), "EEG" )
            save( fullfile( sessDir, "EMG.mat" ), "EMG" )

        catch
            mkdir( sessDir )
            save( fullfile( sessDir, "EEG.mat" ), "EEG" )
            save( fullfile( sessDir, "EMG.mat" ), "EMG" )

        end
    
        disprog( expIdx, nExps, 10 )

    end
    
end
fprintf( "All done in %s.\n\n", humantime( toc( t1 ) ) )