function featTab = getavefeats( doses, tLims, drug )
% GETAVEFEATS gets average features from spectrograms and EMG.
% 
% Usage:
% featTab = getavefeats( doses, tLims )
% 
% Input:
% doses: vector with dose or doses to be plotted and extracted.
% tLims: time limits to take qeeg median in minutes.
% 
% Output:
% featTab: requested spectral feature.

% Defensive programming
% epochLims = [ -5 : 5 : 55; 0 : 5 : 60 ];

tLims = tLims * 60;
drug = string( drug );

% Get info
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

% Allocate empty tables
featTab = table(...
    'Size', [ 5, 9 ], ...
    'VariableTypes', { 'single', 'string', 'double', 'double', 'double',...
    'double', 'double', 'double', 'double' },...
    'VariableNames', { 'expId', 'mouseId', 'dose', 'rmsEmg', 'sef', 'mf',...
    'df', 'Pdelta', 'Pspindle' } );

nDoses = length( doses );
cnt = 1;
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    fprintf( "Processing dose %u %cg\\kg...\n", thisDose, 965 )
    expListIdx = masterTab.analyze == 1 & ...
        masterTab.drug == drug & ...
        masterTab.drug_dose == thisDose;
    expList = masterTab.exp_id( expListIdx );
    nExps = length( expList );

    % hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        thisData = load( fullfile( resDir, f2load ), "emg", "spec", "notes" );
        tabExpIdx = find( [ thisData.notes.expId ] == thisExp );
        
        % Get emg features
        tInj = thisData.notes( tabExpIdx ).injDex;
        t = thisData.emg( tabExpIdx ).t - tInj;
        dexIdxEmg = t > tLims( 1 ) & t < tLims( 2 );
        emgDex = thisData.emg( tabExpIdx ).data( dexIdxEmg );
        win = [ 1 1 ];
        emgChunks = makesegments(...
            emgDex, thisData.emg( tabExpIdx ).Fs, win );
        rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
        clear t

        % Get spectral features
        t = thisData.spec( tabExpIdx ).t - tInj;
        dexIdxS = t > tLims( 1 ) & t < tLims( 2 );
        Sdex = thisData.spec( tabExpIdx ).SL( dexIdxS, : );        
        f = thisData.spec( tabExpIdx ).f;
        [ mf, sef, df ] = qeegspecgram( Sdex, f, [ 0.5 15 ] );
        Pdelta = powerperband( Sdex, f, [ 0.5 3 ], 'total' );
        Pspindle = powerperband( Sdex, f, [ 12 18 ], 'total' );
        clear t
        
        % Fill table
        featTab.expId( cnt ) = thisExp;
        featTab.mouseId( cnt ) = string( metDat.subject );
        featTab.dose( cnt ) = thisDose;
        featTab.rmsEmg( cnt ) = median( rmsEmg );
        featTab.sef( cnt ) = median( sef );
        featTab.mf( cnt ) = median( mf );
        featTab.df( cnt ) = median( df );
        featTab.Pdelta( cnt ) = median( Pdelta );
        featTab.Pspindle( cnt ) = median( Pspindle );
        
        % box off
        % hold on
        cnt = cnt + 1;
        disprog( expIdx, nExps, 10 )

    end

    % ylabel( 'Freq. (Hz)' )
    % xLims = get( gca, 'xlim' );
    % yLims = get( gca, 'ylim' );
    % posX = xLims( 1 ) + 1;
    % posY = yLims( 1 ) + 4;
    % 
    % if thisDose == 0
    %     leg = "Saline";
    %     title( tits( kind ) )
    % 
    % else
    %     leg = sprintf( "%u %cg/kg", thisDose, 956 );
    % 
    % end
    % text( posX, posY, leg,...
    %     'Color', 'k',...
    %     'FontWeight', 'bold',...
    %     'FontSize', 10 )
    % ylabel( 'Freq. (Hz)' )

end

% Remove zeros from qEEG.
% qeeg( qeeg == 0 ) = NaN;
% 
% 
% set( hAx,...
%     'FontSize', 12,...
%     'TickDir', 'out',...
%     'XTickLabel', [],...
%     'YTick',  0 : 10 : 40  )
% 
% set( hAx( end ),...
%     "XTick", [ -10 : 10 : 60 ],...
%     "XTickLabel", [ -10 : 10 : 60 ] )
% xlabel( hAx( 1 ), "time (min)" );
% set( hAx, 'FontSize', 12, 'TickDir', 'out' )
