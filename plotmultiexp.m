%% Make plot of multiple experiments with parietal spec and EMG.
% TO DO: turn into fx.

%% Gather data.

clear all

metTab = readtable(...
    fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' ) );
FW14 = metTab( strcmp( metTab.mouse_id, 'FW14' ), : );
FW14 = sortrows( FW14, 'drug_dose' );
clear metTab

exps = [ 87 FW14.exp_id( ~isnan( FW14.drug_dose ) )' ];
doses = FW14.drug_dose( ~isnan( FW14.drug_dose ) )';
nDoses = length( doses ) + 1;
doseMsg{ 1 } = 'Baseline';
for i = 2 : nDoses
    doseMsg{ i } = sprintf( 'Dex: %.1f %cg/kg i.v.', doses( i - 1 ), 956 );
end
injTime = [ 30*60 FW14.drug_ts_inj( ~isnan( FW14.drug_dose ) )' ];

for expIdx = 1 : length( exps )
    expID = exps( expIdx );
    [ spec, emg ] = loadprocdata( expID, { 'spec', 'emgRaw' } );    
    specDat{ expIdx } = spec.S( :, :, 1 );
    specT{ expIdx } = ( spec.t - injTime( expIdx ) ) / 60; 
    f = spec.f;
    emgDat{ expIdx } = emg.data;
    emgT{ expIdx } = ( emg.ts - injTime( expIdx ) ) / 60;
    
end


%% Make plot(s).

xLims = [ -30 130 ]; % Set time window.

% Set subtightplot options.
gap = [ 0.005 0.01 ];
margH = [ 0.1 0.05 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

nSubplots = 4; % Set max # subplots per fig.

doseIdx = 1;
for figIdx = 1 : ceil( nDoses / nSubplots )
    figure
    for subpIdx = 1 : nSubplots
        thisAxes = [ ( subpIdx * 3 - 2 ) : ( subpIdx * 3 ) ];
        hAx( thisAxes( 1 : 2 ) ) = subtightplot( nSubplots * 3, 1,...
            thisAxes( 1 : 2 ), opts{ : } );
        imagesc( specT{ doseIdx }, f, pow2db( specDat{ doseIdx }' ) )
        % plotspecgram( specDat{ doseIdx }, specT{ doseIdx }, f, 'loglog' );
        axis xy
        ylabel( 'Freq. (Hz)' )
        hold on
        ffcbar( gcf, hAx( thisAxes( 1 ) ), 'Power (db)' );
        clim( [ 0 35 ] )
        ylim( [ 0.5 60 ] )
        if doseIdx > 1
            xline( 0, 'k', 'LineWidth', 2 )
        end
        text( xLims( 1 ) + 1, 55, doseMsg{ doseIdx },...
            'Color', 'g', 'FontWeight', 'bold' )
        xlim( xLims )

        hAx( thisAxes( 3 ) ) = subtightplot( nSubplots * 3, 1,...
            thisAxes( 3 ), opts{ : } );
        plot( emgT{ doseIdx }, emgDat{ doseIdx },...
            'Color', [ 0.2 0.2 0.2 ] )
        ylim( [ - 1800 1800 ] )
        xlim( xLims )
        ylabel( 'Amp. (\muV)' )

        doseIdx = doseIdx + 1;

    end

    % Set figure options.
    set( hAx( 1 : nSubplots * 3 - 1 ), 'xTick', [] )
    set( hAx, 'FontSize', 11 )
    set( hAx, 'box', 'off' )
    linkaxes( hAx, 'x' )
    linkaxes( hAx( [ 1 2 4 5 7 8 ] ), 'y' )
    hLink = linkprop( hAx( [ 1 2 4 5 7 8 ] ), 'CLim' );
    linkaxes( hAx( [ 3 6 9 ] ), 'y' )
    xlabel( 'Time (min)' )
    colormap magma

end


