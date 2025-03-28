function savebandtc( drug, doses, band, bandName )
% Save power timecourse across all experiments for a given dose and drug.

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );

nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    fprintf( "Processing dose %u %cg\\kg...\n", thisDose, 956 )
    expListIdx = ...
        fTab.analyze == 1 & ...
        fTab.drug_dose == thisDose & ...
        fTab.drug == string( drug );
    expList = fTab.exp_id( expListIdx );
    nExps = length( expList );
    % csvFileSpec = "example_traces.csv";

    for idxExp = 1 : nExps
        thisExp = expList( idxExp );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        thisData = load( fullfile( resDir, f2load ),...
            "eeg", "spec", "notes" );
        structIdx = [ thisData.notes.expId ] == thisExp;
        tInj = thisData.notes( structIdx ).tInj;
        SL = thisData.spec( structIdx ).SL;
        locL = thisData.eeg( structIdx ).eegLocs{ 1 };
        SR = thisData.spec( structIdx ).SR;
        locR = thisData.eeg( structIdx ).eegLocs{ 2 };
        t = thisData.spec( structIdx ).t - tInj;
        f = thisData.spec( structIdx ).f;

        % Get spectra after injection
        % dexIdxS = t > 0.5;
        % Sdex = S( dexIdxS, : );
        % tP = t( dexIdxS );
        valid = thisData.spec( structIdx ).valid;
        if valid( 1 )
            PL( nExps ).tot = powerperband( SL, f, band, 'total' );
            PL( nExps ).med = powerperband( SL, f, band, 'median' );
            PL( nExps ).mu = powerperband( SL, f, band, 'mean' );

        elseif valid( 2 )
            PR( nExps ).tot = powerperband( SR, f, band, 'total' );
            PR( nExps ).med = powerperband( SR, f, band, 'median' );
            PR( nExps ).mu = powerperband( SR, f, band, 'mean' );

        else
            warning(...
                fprintf( "None of the spectra were valid %u", thisExp ) )

        end
        PL( nExps ).expId = thisExp;
        PL( nExps ).loc = locL;

        PR( nExps ).expId = thisExp;
        PR( nExps ).loc = locR;
        
        disprog( idxExp, nExps, 10 )

    end

end
fprintf( "Done!%s\n", char([55357, 56842]) )
