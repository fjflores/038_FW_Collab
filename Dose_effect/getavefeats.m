function featTab = getavefeats( doses, tLims, drug )
% GETAVEFEATS gets average features from spectrograms and EMG.
%
% Usage:
% featTab = getavefeats( doses, tLims )
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
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

% Allocate empty tables
featTab = table(...
    'Size', [ 5, 10 ], ...
    'VariableTypes', { 'single', 'string', 'categorical', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double' },...
    'VariableNames', { 'expId', 'mouseId', 'sex', 'dose', 'rmsEmg', 'sef', ...
    'mf', 'df', 'Pdelta', 'Pspindle' } );

nDoses = length( doses );
cnt = 1;
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    fprintf( "Processing dose %u %cg/kg...\n", thisDose, 956 )
    expListIdx = masterTab.analyze == 1 & ...
        masterTab.drug == drug & ...
        masterTab.drug_dose == thisDose;

    expList = masterTab.exp_id( expListIdx );
    eegLFlag = logical( masterTab{ expListIdx, "analyze_EEG_L" } );
    emgFlag = logical( masterTab{ expListIdx, "analyze_EMG" } );
    nExps = length( expList );

    % hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        thisData = load( fullfile( resDir, f2load ), "emg", "spec", "notes" );
        tabExpIdx = find( [ thisData.notes.expId ] == thisExp );
        tInj = thisData.notes( tabExpIdx ).tInj;

        % Get emg features
        if emgFlag( expIdx )
            t = thisData.emg( tabExpIdx ).t - tInj;
            dexIdxEmg = t > tLims( 1 ) & t < tLims( 2 );
            emgDex = thisData.emg( tabExpIdx ).data( dexIdxEmg );
            win = [ 15 1.5 ];
            emgChunks = makesegments(...
                emgDex, thisData.emg( tabExpIdx ).Fs, win );
            rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
            clear t

        else
            rmsEmg = NaN;

        end

        % Get spectral features
        if eegLFlag( expIdx )
            t = thisData.spec( tabExpIdx ).t - tInj;
            dexIdxS = t > tLims( 1 ) & t < tLims( 2 );
            Sdex = thisData.spec( tabExpIdx ).SL( dexIdxS, : );
            f = thisData.spec( tabExpIdx ).f;
            [ mf, sef, df ] = qeegspecgram( Sdex, f, [ 0.5 18 ] );
            Pdelta = median( powerperband( Sdex, f, [ 0.5 3 ], 'total' ) );
            Psigma = median( powerperband( Sdex, f, [ 12 18 ], 'total' ) );
            clear t

        else
            mf = NaN;
            sef = NaN;
            df = NaN;
            Pdelta = NaN;
            Psigma = NaN;

        end

        % Fill table
        featTab.expId( cnt ) = thisExp;
        featTab.mouseId( cnt ) = string( metDat.subject );
        featTab.sex( cnt ) = string( metDat.sex );
        featTab.dose( cnt ) = thisDose;
        featTab.rmsEmg( cnt ) = median( rmsEmg );
        featTab.sef( cnt ) = median( sef );
        featTab.mf( cnt ) = median( mf );
        featTab.df( cnt ) = median( df );
        featTab.Pdelta( cnt ) = Pdelta;
        featTab.Pspindle( cnt ) = Psigma;

        cnt = cnt + 1;
        disprog( expIdx, nExps, 10 )

    end


end

