function plotmousetemp( mice )
% PLOTMOUSETEMP makes plot comparing mouse surface temps for different drug
% combos.

% Load table with info.
fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );
fwTab = sortrows( fwTab, 'dex_dose_inj1' );
fwTab = sortrows( fwTab, 'ket_dose_inj1' );
fwTab = sortrows( fwTab, 'ket_dose_inj2' );
fwTab = sortrows( fwTab, 'pd_dose_inj1' );

% Get mouse list.
mice = string( mice );
if strcmp( mice, "all" )
    mice = string( unique( fwTab.mouse_id ) );
end

% Make figure.
figure
hold on
lgndCnt = 1;
for mIdx = 1 : length( mice )
    thisM = mice( mIdx );
    mTab = fwTab( strcmp( fwTab.mouse_id, thisM ), : );
    expList = mTab.exp_id;

    for expIdx = 1 : length( expList )
        expID = expList( expIdx );
        expTab = mTab( mTab.exp_id == expID, : );

        % Load csv with this exp's temps.
        fName = sprintf( 'exp%i_temps.xlsx', expID );
        fPath = fullfile( getrootdir, 'Data', thisM, fName );
        if exist( fPath )
            expTemps = readtable( fPath );
        else
            continue
        end

        % Calculate timepoint for each temp measurement.
        inj = datetime( 1, 1, 1, expTab.inj1_hr, expTab.inj1_min, 0 );

        ts = regexp( expTemps.tsClock, "(\d+):(\d{2})", "tokens" );
        for tsIdx = 1 : length( ts )
            a( tsIdx, : ) = str2double( ts{ tsIdx }{ : } );
            if a( tsIdx, 1 ) < 10
                a( tsIdx, 1 ) = a( tsIdx, 1 ) + 12;

            end

        end

        b = datetime( 1, 1, 1,...
            a( :, 1 ), a( :, 2 ), 0 );

        c = between( inj, b );
        c = time( c );
        c = round( seconds( c ) );

        expTemps.tsSec = c;

        % For plotting purposes, change baseline temp to be at inj time.
        blTemps = expTemps.tsSec < 0;
        if sum( blTemps ) > 1
            expTemps( end + 1, : ) = {...
                '', mean( expTemps.temp( blTemps ) ), 0 };
            expTemps( blTemps, : ) = [];
            fprintf( 'Using average of multiple baseline temps.\n' )
        else
            expTemps.tsSec( blTemps ) = 0;
        end

        % Plot all temps for this exp.
        expTemps = sortrows( expTemps, 'tsSec' );
        plot( expTemps.tsSec / 60, expTemps.temp )

        % Determine proper legend entry for this exp.
        vasoMsg = '';
        pdMsg = '';
        dexMsg = '';
        ketMsg = '';
        if expTab.vaso_dose_inj1 > 0
            vasoMsg = sprintf( '%i %cg/kg vaso',...
                expTab.vaso_dose_inj1, 956 );
        end
        if expTab.pd_dose_inj1 > 0
            pdMsg = sprintf( ' + %.1f mg/kg PD',...
                expTab.pd_dose_inj1 );
        end
        if expTab.dex_dose_inj1 > 0
            dexMsg = sprintf( ' + %i %cg/kg dex',...
                expTab.dex_dose_inj1, 956 );
        end
        if isa(expTab.ket_dose_inj2, 'double' ) & expTab.ket_dose_inj2 > 0 % TODO fix this
            ketMsg = sprintf( ' + delayed %i mg/kg ket',...
                double( expTab.ket_dose_inj2{ 1 } ) );
        elseif expTab.ket_dose_inj1 > 0
            ketMsg = sprintf( ' + %i mg/kg ket',...
                expTab.ket_dose_inj1 );
        end
        expMsg = [ vasoMsg, pdMsg, dexMsg, ketMsg ];
        expLabs{ lgndCnt } = expMsg;
        lgndCnt = lgndCnt + 1;

        clear expTemps ts a b c

    end

end

% Set figure settings and add labels.
title( 'Mouse Temperature' )
xlabel( 'Time since injection (min)')
xlim( [ 0 140 ] )
ylim( [ 21 32 ] )
ylabel( sprintf( 'Temperature (%cC)', 176 ) )
legend( expLabs )
% text( 60, 28.5, sprintf( 'Note: ambient temperature ~21%c', 176 ) )


end

