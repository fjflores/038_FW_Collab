%% Set dirs.

root = getrootdir;
resDir = fullfile( root, 'Results' );

%% Full exp figs.
expList = [ 185 ]; % 100 172 142 148 154 169 143 170 ];

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
                str2double( fwTab{ ( fwTab.exp_id == expID ), 17 : 22 } ),... % MAKE THIS ACTUALLY WORK
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

mouse = 'FW17';
plotmousetemp( mouse );

saveas( gcf, fullfile( resDir, mouse, 'temperature_comparison.png' ) )

