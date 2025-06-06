%% Set dirs.

root = getrootdir;
resDir = fullfile( root, 'Results' );

%% Full exp figs.
expList = [ 207 ];

specYLims = [ 0.5 15; 0.5 150 ];
specCLims = [ 0 35; -10 30 ];

for expIdx = 1 : length( expList )
    expID = expList( expIdx );
    metDat = getmetadata( expID );
    mouse = metDat.subject;

    figure( 'Name', sprintf( 'Exp. %i', expID ), 'WindowState', 'maximized' )
    [ hAx, hLink ] = plotexp( expID,...
        'SetShowEeg', 'raw',...
        'SetAmpEeg', [ -700 700 ],...
        'SetFreqSpec', specYLims( 1, : ),...
        'SetCAxis', specCLims( 1, : ),...
        'SetShowEmg', 'raw',... % choose raw, filt, or smooth
        'MinOrSec', 'sec' );

    % TEMPORARY: turn this chunk into an option within plotexp
    metTabPath = fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' );
    opts = detectImportOptions( metTabPath );
    tsTmp = regexp( opts.VariableNames, 'ts_.*\d', 'match' );
    tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
    opts = setvartype( opts, tsCols, 'double' );
    metTab = readtable( metTabPath, opts );
    tsTab = table2array( metTab( :, { 'ts_offline_inj1', 'ts_online_inj1',...
        'ts_offline_inj2', 'ts_online_inj2', 'ts_inj1', 'ts_inj2' } ) );

    fwTab = readtable(...
        fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );
    fwTab.tail_pinch_30_ts = string( fwTab.tail_pinch_30_ts );
    doseMsg = fwTab.dose_msg{ fwTab.exp_id == expID };

    for i = 1 : 6
        xline( hAx( i ), tsTab( expID, 5 ), 'g', 'LineWidth', 2 )
        xline( hAx( i ), tsTab( expID, 6 ), 'g', 'LineWidth', 2 )

        if metDat.FWCollab == 1
            xline( hAx( i ),...
                str2double( fwTab{ ( fwTab.exp_id == expID ), 19 : 24 } ),... % MAKE THIS ACTUALLY WORK
                'g', 'LineWidth', 1 ) 
            
        end

    end

    % TODO REMOVE EMG IF DEAD --> MAKE THIS AN OPT IN PLOTEXP

    for limIdx = 1 : height( specYLims )
        ylim( hAx( [ 2 4 5 ] ), specYLims( limIdx, : ) )
        clim( hAx( [ 2 4 ] ), specCLims( limIdx, : ) )
        fName = sprintf( 'exp%i_%s_to%iHz.png',...
            expID, doseMsg, specYLims( limIdx, 2 ) );
        saveas( gcf, fullfile( resDir, mouse, fName ) )

    end

    close all

end


%% Mouse temp fig.

% clear all

mouse = 'FW19';
plotmousetemp( mouse );

% saveas( gcf, fullfile( resDir, mouse, 'temperature_comparison.png' ) )


%% Example exp

% use plotexp section of runall first then run this section
% then save as svg for Nitsan

tInj = 3725; % exp 100
% tInj = 3610; % exp 142

for i = 1 : 5
    xline( hAx( i ), tInj, 'g', 'LineWidth', 1 )
end
xLims = [ ( tInj - 10 * 60 ) ( tInj + 120 * 60 ) ];
xlim( xLims )
xlabel( 'Time (min)' )
xticks( [ xLims( 1 ) : 60 * 10 : xLims( 2 ) ] )
xticklabels( [ -10 : 10 : 120 ] )
set( hAx, 'FontSize', 12, 'TickDir', 'out' )

set( hAx( [ 1 3 ] ), 'YLim', [ -500 500 ], 'YTick', [ -400 0 400 ] )
% set( hAx( [ 2 4 ] ), 'cLim', [ -10 35 ], 'YLim', [ 0.5 150 ] )
% set( hAx( [ 2 4 ] ), 'cLim', [ -10 35 ], 'YLim', [ 0.5 100 ] )
% set( hAx( [ 2 4 ] ), 'cLim', [ 0 40 ], 'YLim', [ 0.5 50 ] )



%% Make pretty exp plot.
% 22-May-2025 NOTE: tidy data not yet working for these exps so can't use

% ccc
% 
% expID = 142;
% mID = 'FW18';
% 
% load( fullfile( getrootdir, 'Results', mID, 'TidyData_combo.mat' ) )
% 
% tabExpIdx = find( [ notes.expId ] == expID );
% tInj = notes( tabExpIdx ).tInj1;
% eegClean = [ eeg( tabExpIdx ).dataL eeg( tabExpIdx ).dataR ];
% eegT = eeg( tabExpIdx ).t - tInj;
% emg2plot = emg( tabExpIdx ).data;
% emgT = emg( tabExpIdx ).t - tInj;
% SL = spec( tabExpIdx ).SL;
% SR = spec( tabExpIdx ).SR;
% specT = spec( tabExpIdx ).t - tInj;
% specF = spec( tabExpIdx ).f;
% 
% datPlot{ 1 } = eegClean( :, 1 );
% datPlot{ 3 } = eegClean( :, 2 );
% t2plot{ 1 } = eegT / 60;
% t2plot{ 3 } = t2plot{ 1 };
% datPlot{ 2 } = SL;
% datPlot{ 4 } = SR;
% t2plot{ 2 } = specT / 60;
% t2plot{ 4 } = t2plot{ 2 };
% datPlot{ 5 } = emg2plot;
% t2plot{ 5 } = emgT / 60;
% 
% 
% yLimsEeg = [ -800 800 ];
% % yLimsEmg = 
% 
% 
% nPlots = 5;
% gap = [ 0.005 0.01 ];
% margH = [ 0.1 0.05 ];
% margV = [0.1 0.1];
% opts = { gap, margH, margV };
% 
% figure
% hold on
% for plotIdx = 1 : nPlots
%     switch plotIdx
%         case { 1, 3 }
%             hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
%             thisEEGPlot = plot( t2plot{ plotIdx }, datPlot{ plotIdx } );
%             ylabel( 'Amp. (\muV)' )
%             xticks( [ ] )
%             xticklabels( {} )
%             ylim( yLimsEeg )            
% 
%         case { 2, 4 }
%             hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
%             imagesc( t2plot{ plotIdx }, specF, pow2db( datPlot{ plotIdx }' ) )
%             axis xy
%             ylabel( 'Freq. (Hz)' )
%             xticks( [ ] )
%             xticklabels( {} )
%             hold on
%             ffcbar( gcf, hAx( plotIdx ), 'Power (db)' );
% 
%         case 5
%             hAx( plotIdx ) = subtightplot( nPlots, 1, plotIdx, opts{ : } );
%             hold on
%             plot( t2plot{ plotIdx }, datPlot{ plotIdx }, 'k' )
%             % ylim( yLimEmg )
%             % ylabel( ' )
% 
% 
% 
%     end
% 
%     % Define colormap
%     colormap magma
% 
% end
% 
% xlabel( 'Time (min)' )
% 
% axis tight
% % link axes
% linkaxes( hAx, 'x' )
% linkaxes( hAx( [ 1 3 ] ), 'y' ) % link lfp's
% linkaxes( hAx( [ 2 4 ] ), 'y' ) % link specs and coher
% hLink = linkprop( hAx( [ 2 4 ] ), 'CLim' );
% 
% % Set properties
% set( hAx,...
%     'box', 'off' )
