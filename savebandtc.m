function [ PL, PR, emg ] = savebandtc( drug, doses, band, bandName, saveFlag )
% Save power timecourse across all experiments for a given dose and drug.

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );

start = tic;
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
    cnt1 = 1;
    cnt2 = 2;
    cnt3 = 3;
    tot = [];
    med = [];
    mu = [];
    finalExpList = [];

    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        thisData = load( fullfile( resDir, f2load ),...
            "eeg", "emg", "spec", "notes" );
        structIdx = [ thisData.notes.expId ] == thisExp;
        tInj = thisData.notes( structIdx ).tInj;

        SL = thisData.spec( structIdx ).SL;
        locL = thisData.eeg( structIdx ).eegLocs{ 1 };

        SR = thisData.spec( structIdx ).SR;
        locR = thisData.eeg( structIdx ).eegLocs{ 2 };

        emg = thisData.emg( structIdx ).data;
        tEmg = thisData.emg( structIdx ).data;

        t = thisData.spec( structIdx ).t - tInj;
        f = thisData.spec( structIdx ).f;

        % Get spectra after injection
        drugIdxS = t > 31 & t <= 3590;
        SL = SL( drugIdxS, : );
        tP = t( drugIdxS );
        valid = [...
            thisData.spec( structIdx ).valid ...
            thisData.emg( structIdx ).valid ];

        % tmp = [];
        if valid( 1 )
            tmp = powerperband( SL, f, band, 'total' );
            tot( :, cnt1 ) = tmp ./ sum( tmp );
            med( :, cnt1 ) = powerperband( SL, f, band, 'median' );
            mu( :, cnt1 ) = powerperband( SL, f, band, 'mean' );
            finalExpList( cnt1 ) = thisExp;
            cnt1 = cnt1 + 1;

            PL( doseIdx ).total = tot;
            PL( doseIdx ).median = med;
            PL( doseIdx ).mean = mu;


        elseif valid( 2 )
            tmp = powerperband( SR, f, band, 'total' );
            tot( :, cnt2 ) = tmp ./ sum( tmp );
            med( :, cnt2 ) = powerperband( SR, f, band, 'median' );
            mu( :, cnt2 ) = powerperband( SR, f, band, 'mean' );
            finalExpList( cnt2 ) = thisExp;
            cnt2 = cnt2 + 1;

            PR( doseIdx ).total = tot;
            PR( doseIdx ).median = med;
            PR( doseIdx ).mean = mu;

        elseif valid( 3 )
            win = [ 15 1.5 ];
            emgChunks = makesegments(...
                emgDex, thisData.emg( tabExpIdx ).Fs, win );
            rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
            rmsVal( :, cnt3 ) = rmsEmg;
            emg( doseIdx ).rms = rmsVals;
            cnt3 = cnt3 + 1;

        else
            warning(...
                sprintf( "Spectra in exp %u wasn't valid", thisExp ) )

        end
        PL( doseIdx ).ts = tP;
        PL( doseIdx ).expId = thisExp;
        PL( doseIdx ).loc = locL;
        PL( doseIdx ).dose = thisDose;
        PL( doseIdx ).expList = finalExpList;

        PR( doseIdx ).ts = tP;
        PR( doseIdx ).expId = thisExp;
        PR( doseIdx ).loc = locL;
        PR( doseIdx ).dose = thisDose;
        PR( doseIdx ).expList = finalExpList;

        

        disprog( expIdx, nExps, 10 )

    end
    % clear tot med mu locL finalExpList
    disp( ' ' )

end

if saveFlag
    resDir = fullfile( getrootdir, "Results\Dose-Effect\" );
    drug = char( drug );
    drug = strcat( upper( drug( 1 ) ), drug( 2 : end ) );
    fName = sprintf( "%s_Power_%s", bandName, drug );
    save( fullfile( resDir, fName ), 'PL', 'PR', 'band' )

end

fprintf( "Done in %s %c\n", humantime( toc( start ) ), 9786 )
