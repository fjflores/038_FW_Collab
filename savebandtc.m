function PL = savebandtc( drug, doses, band, bandName, saveFlag )
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
    cnt = 1;
    tot = [];
    med = [];
    mu = [];
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
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
        drugIdxS = t > 31 & t <= 3590;
        SL = SL( drugIdxS, : );
        tP = t( drugIdxS );
        valid = thisData.spec( structIdx ).valid;

        if valid( 1 )
            tot( :, cnt ) = powerperband( SL, f, band, 'total' );
            med( :, cnt ) = powerperband( SL, f, band, 'median' );
            mu( :, cnt ) = powerperband( SL, f, band, 'mean' );
            finalExpList( cnt ) = thisExp;
            cnt = cnt + 1;

            % elseif valid( 2 )
            %     PR( nExps ).tot = powerperband( SR, f, band, 'total' );
            %     PR( nExps ).med = powerperband( SR, f, band, 'median' );
            %     PR( nExps ).mu = powerperband( SR, f, band, 'mean' );

        else
            warning(...
                sprintf( "Spectra in exp %u wasn't valid", thisExp ) )

        end
        PL( doseIdx ).total = tot;
        PL( doseIdx ).median = med;
        PL( doseIdx ).mean = mu;
        PL( doseIdx ).ts = tP;
        PL( doseIdx ).expId = thisExp;
        PL( doseIdx ).loc = locL;
        PL( doseIdx ).dose = thisDose;
        PL( doseIdx ).expList = finalExpList;

        

        % PR( nExps ).expId = thisExp;
        % PR( nExps ).loc = locR;

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
    save( fullfile( resDir, fName ), 'PL', 'band' )

end

fprintf( "Done in %s %c\n", humantime( toc( start ) ), 9786 )
