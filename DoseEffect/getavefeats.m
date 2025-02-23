function featTab = getavefeats( doses, tLims )
% GETAVEFEATS gets average features from spectrograms and EMG.
% 
% Usage:
% featTab = getavefeats( doses, tLims )
% 
% Input:
% doses: vector with dose or doses to be plotted and extracted.
% tLims: time limits to take qeeg median.
% 
% Output:
% featTab: requested spectral feature.

if nargin < 3
    tLims = [ 30 40 ];

end

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

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
        masterTab.drug == "dex" & ...
        masterTab.drug_dose == thisDose;
    expList = masterTab.exp_id( expListIdx );
    nExps = length( expList );

    % hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "TidyData.mat";
        load( fullfile( resDir, f2load ), "emg", "spec", "notes" );
        tabExpIdx = find( [ notes.expId ] == thisExp );
        
        % Get emg features
        t = emg( tabExpIdx ).t;
        dexIdxEmg = t > tLims( 1 ) & t < tLims( 2 );
        emgDex = emg( tabExpIdx ).data( dexIdxEmg );
        win = [ 1 1 ];
        emgChunks = makesegments( emgDex, emg( tabExpIdx ).Fs, win );
        rmsEmg = sqrt( mean( emgChunks .^ 2 ) );
        clear t

        % Get spectral features
        t = spec( tabExpIdx ).t;
        dexIdxS = t > tLims( 1 ) & t < tLims( 2 );
        Sdex = spec( tabExpIdx ).SL( dexIdxS, : );        
        f = spec( tabExpIdx ).f;
        [ mf, sef, df ] = qeegspecgram( Sdex, f, [ 0.5 10 ] );
        Pdelta = powerperband( Sdex, f, [ 0.5 3 ], 'total' );
        Pspindle = powerperband( Sdex, f, [ 12 18 ], 'total' );
        
        % Fill table
        featTab.expId( cnt ) = thisExp;
        featTab.mouseId( cnt ) = string( metDat.subject );
        featTab.dose( cnt ) = thisDose;
        featTab.rmsEmg( cnt ) = median( rmsEmg );
        featTab.sef( cnt ) = median( sef );
        featTab.mf( cnt ) = median( mf );
        featTab.df( cnt ) = median( df );
        featTab.Pdelta( cnt ) = sum( Pdelta );
        featTab.Pspindle( cnt ) = sum( Pspindle );
        
        % box off
        % hold on
        cnt = cnt + 1;
        disprog( expIdx, nExps, 20 )

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
