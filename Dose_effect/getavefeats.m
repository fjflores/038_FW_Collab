function featTab = getavefeats( doses, tLims, drug )
% GETAVEFEATS gets average features from spectrograms and EMG.
%
% Usage:
% featTab = getavefeats( doses, tLims, drug )
%
% Input:
% doses: vector with dose or doses to be plotted and extracted.
% tLims: two-element vector with time limits to take qeeg median in minutes.
% drug: string drug name to use. "dex" or "ket".
%
% Output:
% featTab: requested spectral feature.

tLims = tLims * 60;
drug = string( drug );

% Get info
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
tab2read = fullfile( root, "Results", csvFileMaster );
masterTab = safereadtable( tab2read );
% opts = detectImportOptions( tab2read );
% opts = setvartype( opts, length( opts.VariableNames ) - 1, 'double' ); % Set data types for specific columns
% masterTab = readtable( tab2read, opts );

% Allocate empty tables
featTab = table(...
    'Size', [ 1, 11 ], ...
    'VariableTypes', ...
    { 'single', 'string', 'string', 'double', 'double', 'double', 'double', ...
     'double', 'double', 'double', 'double'},...
    'VariableNames', ...
    { 'expId', 'mouseId', 'sex', 'dose', 'rmsEmg',...
     'mf_L', 'Pdelta_L', 'mf_R', 'Pdelta_R', 'mf_C', 'Cdelta' } );

nDoses = length( doses );
fBand = [ 0.5 3.5 ];
cnt = 1;
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    fprintf( "Processing dose %u %cg/kg...\n", thisDose, 956 )
    expListIdx = masterTab.analyze == 1 & ...
        masterTab.drug_inj1 == drug & ...
        masterTab.drug_dose_inj1 == thisDose & ...
        masterTab.approx_inj1_inj2_dif_min < 70;

    expList = masterTab.exp_id( expListIdx );
    subjectList = masterTab.mouse_id( expListIdx );
    sexList = masterTab.sex( expListIdx );
    % eegLFlag = logical( masterTab{ expListIdx, "analyze_EEG_L" } );
    % emgFlag = logical( masterTab{ expListIdx, "analyze_EMG" } );
    nExps = length( expList );

    % hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        % metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", subjectList{ expIdx  } );
        f2load = "TidyData.mat";
        thisData = load( fullfile( resDir, f2load ),...
            "emg", "spec", "coher", "notes" );
        tidyExpIdx = find( [ thisData.notes.expId ] == thisExp );
        tInj1 = thisData.notes( tidyExpIdx ).tInj1;
        win = thisData.notes( tidyExpIdx ).params.win;

        % Get emg features
        if thisData.emg( tidyExpIdx ).valid
            t = thisData.emg( tidyExpIdx ).t - tInj1;
            drugIdxEmg = t > tLims( 1 ) & t < tLims( 2 );
            emgDrug = thisData.emg( tidyExpIdx ).data( drugIdxEmg );
            emgChunks = makesegments(...
                emgDrug, thisData.emg( tidyExpIdx ).Fs, win );
            rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
            clear t

        else
            rmsEmg = NaN;

        end

        % Get left spectral features
        if thisData.spec( tidyExpIdx ).valid( 1 )
            t = thisData.spec( tidyExpIdx ).t - tInj1;
            drugIdxS = t > tLims( 1 ) & t < tLims( 2 );
            SLdrug = thisData.spec( tidyExpIdx ).SL( drugIdxS, : );
            f = thisData.spec( tidyExpIdx ).f;
            mf_L = qeegspecgram( SLdrug, f, [ 0.5 18 ] );
            Pdelta_L = median( powerperband( SLdrug, f, fBand, 'total' ) );
            clear t

        else
            mf_L = NaN;
            Pdelta_L = NaN;

        end

        % Get right spectral features
        if thisData.spec( tidyExpIdx ).valid( 2 )
            t = thisData.spec( tidyExpIdx ).t - tInj1;
            drugIdxR = t > tLims( 1 ) & t < tLims( 2 );
            SRdrug = thisData.spec( tidyExpIdx ).SR( drugIdxR, : );
            f = thisData.spec( tidyExpIdx ).f;
            mf_R = qeegspecgram( SRdrug, f, [ 0.5 18 ] );
            Pdelta_R = median( powerperband( SLdrug, f, fBand, 'total' ) );
            clear t

        else
            mf_R = NaN;
            Pdelta_R = NaN;

        end

        % Get Coherence features
        if thisData.coher( tidyExpIdx ).valid
            t = thisData.coher( tidyExpIdx ).t - tInj1;
            drugIdxS = t > tLims( 1 ) & t < tLims( 2 );
            Cdrug = thisData.coher( tidyExpIdx ).C( drugIdxS, : );
            f = thisData.spec( tidyExpIdx ).f;
            mf_C = qeegspecgram( Cdrug, f, [ 0.5 18 ] );
            Cdelta = median( powerperband( Cdrug, f, fBand, 'total' ) );
            clear t

        else
            mf_C = NaN;
            Cdelta = NaN;

        end

        % Fill table
        featTab.expId( cnt ) = thisExp;
        featTab.mouseId( cnt ) = string( subjectList{ expIdx  } );
        featTab.sex( cnt ) = string( sexList{ expIdx } );
        featTab.dose( cnt ) = thisDose;
        featTab.rmsEmg( cnt ) = median( rmsEmg );
        featTab.mf_L( cnt ) = median( mf_L );
        featTab.Pdelta_L( cnt ) = pow2db( Pdelta_L );
        featTab.mf_R( cnt ) = median( mf_R );
        featTab.Pdelta_R( cnt ) = pow2db( Pdelta_R );
        featTab.mf_C( cnt ) = median( mf_C );
        featTab.Cdelta( cnt ) = atanh( Cdelta );

        cnt = cnt + 1;
        disprog( expIdx, nExps, 10 )

    end


end

