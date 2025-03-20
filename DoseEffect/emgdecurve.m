function [ percQuietTab, rmsVals ] = emgdecurve( drug )
% Plot average spectra for each dose across all mice
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

doses = sort( unique( masterTab.drug_dose(...
    masterTab.drug == drug & ...
    masterTab.analyze == 1 ) ) );

% Create the table
% expId = [ ];          % Example experiment IDs
% mouseId = { };  % Example mouse IDs
% drug = { };
% dose = [ ];   % Example doses
% percMov = [ ]; % Example percentage movement
percQuietTab = table(...
    'Size', [ 5, 5 ], ...
    'VariableTypes', {'double', 'string', 'string', 'double', 'double'}, ...
    'VariableNames', { 'expId', 'mouseId', 'drug', 'dose', 'percQuiet' } );

nDoses = length( doses );
cnt = 1;
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    expListIdx = masterTab.analyze == 1 & ...
        masterTab.drug_dose == thisDose & ...
        masterTab.analyze_EMG == 1;
    expList = masterTab.exp_id( expListIdx );
    fprintf( "Processing dose %u %cg/kg...\n", thisDose, 956 )
    
    nExps = length( expList );
    for idxExp = 1 : nExps
        thisExp = expList( idxExp );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        load( fullfile( resDir, f2load ), "emg", "info" );
        tabExpIdx = find( [ info.expId ] == thisExp );
        data = emg( tabExpIdx ).data;
        ts = emg( tabExpIdx ).t;
        emgFs = emg( tabExpIdx ).Fs;
        tOn = info( tabExpIdx ).tOn;
        [ percQuiet, rmsTmp ] = getperctquiet( data, ts, tOn, emgFs );
        rmsVals{ cnt } = rmsTmp';
        % figure
        % histogram( rmsVals, 100 )
        % title( sprintf( "RMS values %s %u ug/kg", metDat.subject, thisDose ) )
        % Fill table
        percQuietTab.expId( cnt ) = thisExp;
        percQuietTab.mouseId( cnt ) = metDat.subject;
        percQuietTab.drug( cnt ) = drug;
        percQuietTab.dose( cnt ) = thisDose;
        percQuietTab.percQuiet( cnt ) = percQuiet;
        cnt = cnt + 1;

    end

    disp( ' ' )

end