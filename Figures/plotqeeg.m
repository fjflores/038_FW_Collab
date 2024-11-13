function qeeg = plotqeeg( doses, kind, tLims )
% PLOTQEEG plot a qeeg feature across all mice for the given doses.
% 
% Usage:
% qeeg = plotqeeg( doses, kind )
% 
% Input:
% doses: vector with dose or doses to be plotted and extracted.
% kind: string whith qeeg feature to plot/extract. "mf" for median freq, 
% "sef" for spectral edge, and "df" for dominant frequency.
% tLims: time limits to take qeeg median.
% 
% Output:
% qeeg: requested spectral feature

if nargin < 3
    tLims = [ 30 40 ];

end

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
masterTab = readtable( fullfile( root, "Results", csvFileMaster ) );

gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
yLims = [ 0 50 ];

colormap magma

tits = dictionary(...
    "mf", "Median Fequency", ...
    "sef", "Spectral Edge", ...
    "df", "Dominant Frequency" );

nDoses = length( doses );
for doseIdx = 1 : nDoses
    thisDose = doses( doseIdx );
    fprintf( "Processing dose %u %cg\\kg...\n", thisDose, 965 )
    expListIdx = masterTab.analyze == 1 & ...
        masterTab.dex_dose_ugperkg == thisDose;
    expList = masterTab.exp_id( expListIdx );
    nExps = length( expList );

    hAx( doseIdx ) = subtightplot( nDoses, 1, doseIdx, opts{ : } );
    for expIdx = 1 : nExps
        thisExp = expList( expIdx );
        metDat = getmetadata( thisExp );
        resDir = fullfile( root, "Results", metDat.subject );
        f2load = "ExampleFigData.mat";
        load( fullfile( resDir, f2load ), "spec", "info" );
        tabExpIdx = find( [ info.expId ] == thisExp );
        S = spec( tabExpIdx ).L;
        t = ( spec( tabExpIdx ).t2plot - ...
            ( spec( tabExpIdx ).t2plot( 1 ) + 600 ) ) / 60;
        f = spec( tabExpIdx ).f2plot;

        % Get spectra after injection
        dexIdxS = t > 0;
        Sdex = S( dexIdxS, : );
        t2plot = t( dexIdxS );

        [ mf, sef, df ] = qeegspecgram( Sdex, f, [ 0.5 30 ] );

        switch kind
            case "mf"
                var2plot = mf;

            case "sef"
                var2plot = sef;

            case "df"
                var2plot = df;

        end
        qeeg( expIdx, doseIdx ) = median( var2plot(...
            t2plot > tLims( 1 ) & t2plot < tLims( 2 ) ) );
        plot( t2plot, var2plot, Color=[ 0.5 0.5 0.5 ] )
        box off
        hold on

        disprog( expIdx, nExps, 20 )

    end

    ylabel( 'Freq. (Hz)' )
    xLims = get( gca, 'xlim' );
    yLims = get( gca, 'ylim' );
    posX = xLims( 1 ) + 1;
    posY = yLims( 1 ) + 4;

    if thisDose == 0
        leg = "Saline";
        title( tits( kind ) )

    else
        leg = sprintf( "%u %cg/kg", thisDose, 956 );

    end
    text( posX, posY, leg,...
        'Color', 'k',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( 'Freq. (Hz)' )

end

% Remove zeros from qEEG.
qeeg( qeeg == 0 ) = NaN;


set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : 40  )

set( hAx( end ),...
    "XTick", [ -10 : 10 : 60 ],...
    "XTickLabel", [ -10 : 10 : 60 ] )
xlabel( hAx( 1 ), "time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
