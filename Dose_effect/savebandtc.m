function [ PL, PR, emgRms ] = savebandtc(...
    drug, doses, band, bandName, saveFlag )
% Save power timecourse across all experiments for a given dose and drug.

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
f2load = "TidyData.mat";
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
    
    % Set counters to 1
    cnt1 = 1; % PL
    cnt2 = 1; % PR
    cnt3 = 1; % coher
    cnt4 = 1; % emgRms

    % Allocate empty vars
    tmpL = [];
    totL = [];
    medL = [];
    muL = [];
    finalExpListL = [];
    
    tmpR = [];
    totR = [];
    medR = [];
    muR = [];
    finalExpListR = [];

    finalExpListEmg = [];

    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        
        thisData = load( fullfile( resDir, f2load ),...
            "eeg", "emg", "spec", "notes" );
        structIdx = [ thisData.notes.expId ] == thisExp;
        tInj = thisData.notes( structIdx ).tInj;

        SL = thisData.spec( structIdx ).SL;
        locL = thisData.eeg( structIdx ).eegLocs{ 1 };

        SR = thisData.spec( structIdx ).SR;
        locR = thisData.eeg( structIdx ).eegLocs{ 2 };

        t = thisData.spec( structIdx ).t - tInj;
        f = thisData.spec( structIdx ).f;

        emg = thisData.emg( structIdx ).data;
        tEmg = thisData.emg( structIdx ).data;
        Fs = thisData.emg( structIdx ).Fs;

        % Get spectra after injection
        drugIdxS = t > 31 & t <= 3590;
        SL = SL( drugIdxS, : );
        tP = t( drugIdxS );
        valid = [...
            thisData.spec( structIdx ).valid ...
            thisData.emg( structIdx ).valid ];

        % tmp = [];
        if valid( 1 )
            tmpL = powerperband( SL, f, band, 'total' );
            totL( :, cnt1 ) = tmpL ./ sum( tmpL );
            medL( :, cnt1 ) = powerperband( SL, f, band, 'median' );
            muL( :, cnt1 ) = powerperband( SL, f, band, 'mean' );
            finalExpListL( cnt1 ) = thisExp;
            cnt1 = cnt1 + 1;

            PL( doseIdx ).total = totL;
            PL( doseIdx ).median = medL;
            PL( doseIdx ).mean = muL;

        end


        if valid( 2 )
            tmpR = powerperband( SR, f, band, 'total' );
            totR( :, cnt2 ) = tmpR ./ sum( tmpR );
            medR( :, cnt2 ) = powerperband( SR, f, band, 'median' );
            muR( :, cnt2 ) = powerperband( SR, f, band, 'mean' );
            finalExpListR( cnt2 ) = thisExp;
            cnt2 = cnt2 + 1;

            PR( doseIdx ).total = totR;
            PR( doseIdx ).median = medR;
            PR( doseIdx ).mean = muR;

        end

        if valid( 3 )
            win = [ 15 1.5 ]; % Change this!
            emgChunks = makesegments( emg, Fs, win );
            rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
            rmsVals( :, cnt3 ) = rmsEmg;
            emgRms( doseIdx ).rms = rmsVals;
            finalExpListEmg( cnt3 ) = thisExp;
            cnt3 = cnt3 + 1;

        end

        PL( doseIdx ).ts = tP;
        PL( doseIdx ).loc = locL;
        PL( doseIdx ).dose = thisDose;
        PL( doseIdx ).expList = finalExpListL;

        PR( doseIdx ).ts = tP;
        PR( doseIdx ).loc = locL;
        PR( doseIdx ).dose = thisDose;
        PR( doseIdx ).expList = finalExpListR;

        emgRms( doseIdx ).ts = tP;
        emgRms( doseIdx ).dose = thisDose;
        emgRms( doseIdx ).expList = finalExpListEmg;
        
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
