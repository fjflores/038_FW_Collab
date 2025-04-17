%% Makes plot comparing mouse surface temps for different drug combos.

% ccc
clear all

thisM = 'FW17';

fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );
mTab = fwTab( strcmp( fwTab.mouse_id, thisM ), : );

switch thisM
    case 'FW14'
        expList = [ 100 96 98 94 103 126 129 ];

        % fwTab{ ( fwTab.exp_id == expId ),      }
        
        injTime = [ 12 38; 14 54; 12 22; 11 35; 12 59; 14 29; 11 46 ];
        expLabs = { sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD', 956 ),...            
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 1 %cg/kg dex', 956, 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 2 %cg/kg dex', 956, 956 ),...
            sprintf( '10 %cg/kg vaso + 1 mg/kg PD', 956 ),...
            sprintf( '10 %cg/kg vaso + 1 mg/kg PD + 1 %cg/kg dex', 956, 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 3 %cg/kg ket', 956, 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + delayed 3 %cg/kg ket', 956, 956 )};

    case 'FW16'
        expList = [ 99 102 135 101 104 ];
        injTime = [ 12 24; 13 30; 16 51; 15 54; 16 47 ];
        expLabs = { sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD', 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 1 %cg/kg dex', 956, 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 3 mg/kg ket', 956 ),...
            sprintf( '10 %cg/kg vaso + 1 mg/kg PD', 956 ),...
            sprintf( '10 %cg/kg vaso + 1 mg/kg PD + 1 %cg/kg dex', 956, 956 ) };

    case 'FW17'
        expList = [ 125 137 ];
        injTime = [  11	24; 17 05 ];
        expLabs = { sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD', 956 ),...
            sprintf( '10 %cg/kg vaso + 0.5 mg/kg PD + 3 mg/kg ket', 956 ) };
end

figure
hold on
for expIdx = 1 : length( expList )
    thisExp = expList( expIdx );
    fName = sprintf( 'exp%i_temps.xlsx', thisExp );
    inj = datetime( 1, 1, 1, injTime( expIdx, 1 ), injTime( expIdx, 2 ), 0 );
    exp = readtable( fullfile( getrootdir, 'Data', thisM, fName ) );

    ts = regexp( exp.tsClock, "(\d+):(\d{2})", "tokens" );
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

    exp.tsSec = c;

    % For plotting purposes, change baseline temp to all be at inj time.
    if sum( exp.tsSec( exp.tsSec < 0 ) ) > 1
        warning( 'more than one baseline (pre-inj) temp' )
    else
        exp.tsSec( exp.tsSec < 0 ) = 0;
    end

    plot( exp.tsSec / 60, exp.temp )

    clear exp ts a b c 

end

title( 'Mouse Temperature' )
xlabel( 'Time since injection (min)')
xlim( [ 0 140 ] )
ylim( [ 21 32 ] )
ylabel( sprintf( 'Temperature (%cC)', 176 ) )
legend( expLabs )
text( 60, 28.5, sprintf( 'Note: ambient temperature ~21%c', 176 ) )

