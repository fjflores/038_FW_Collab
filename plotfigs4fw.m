%% Set dirs.

root = getrootdir;
resDir = fullfile( root, 'Results' );

%% Full exp figs.
expList = [ 148 ];
doseMsg = { "combo_w_ket" };

specYLims = [ 0.5 15; 0.5 150 ];
specCLims = [ 0 35; -10 40 ];

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
metDat = getmetadata( expID );

fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );


fwTab.tail_pinch_30_ts = string( fwTab.tail_pinch_30_ts );

for i = 1 : 6
    xline( hAx( i ), tsTab( expID, 5 ), 'g', 'LineWidth', 2 )
    xline( hAx( i ), tsTab( expID, 6 ), 'g', 'LineWidth', 2 )

    if metDat.FWCollab == 1
        xline( hAx( i ),...
            str2double( fwTab{ ( fwTab.exp_id == expID ), 16 : 21 } ),...
            'g', 'LineWidth', 1 ) % FW exps only
    end

end

% TODO REMOVE EMG IF DEAD
% Option to do more than just 15 and 150

fName15 = sprintf( 'exp%i_%s_to%iHz.png', expID, doseMsg{ expIdx }, specYLims( 1, 2 ) );
saveas( gcf, fullfile( resDir, mouse, fName15 ) )

ylim( hAx( [ 2 4 5 ] ), specYLims( 2, : ) )
clim( hAx( [ 2 4 ] ), specCLims( 2, : ) )
fName150 = sprintf( 'exp%i_%s_to%iHz.png', expID, doseMsg{ expIdx }, specYLims( 2, 2 ) );
saveas( gcf, fullfile( resDir, mouse, fName150 ) )

close all

end

%% Mouse temp fig.

% clear all

mouse = 'FW18';
plotmousetemp( mouse );

saveas( gcf, fullfile( resDir, mouse, 'temperature_comparison.png' ) )

