% %% cage floor temps
% temps = readtable( fullfile( getrootdir, 'Data', 'chamber_floor_temp.xlsx' ) );
% figure
% scatterjit( temps{ :, 1 }, temps{ :, 2 }, 'Jit', 0.4 )
% ylim( [ 19 35 ] )


%% Proto plot temp curves w/ and w/o heat pad for same dose.

mID = 'FW14';
expNoHeat = 94;
expHeat = 197;
mID = 'FW16';
expNoHeat = 101;
expHeat = 200;
mID = 'FW17';
expNoHeat = 170;
expHeat = 201;


fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx') );

clear temps

noHeatTemps = readtable(...
    fullfile( getrootdir, 'Data', mID,...
    sprintf( 'exp%i_temps.xlsx', expNoHeat ) ) );
heatTemps = readtable(...
    fullfile( getrootdir, 'Data', mID,...
    sprintf( 'exp%i_temps.xlsx', expHeat ) ) );
% Add estimated cage temps to no heat exp (all 20 degrees C)
noHeatTemps.cageTemp = 20 * ones( height( noHeatTemps ), 1 );

injTimes = [ fwTab{ fwTab.exp_id == expNoHeat, 'inj1_hr' }...
    fwTab{ fwTab.exp_id == expNoHeat, 'inj1_min' };...
    fwTab{ fwTab.exp_id == expHeat, 'inj1_hr' }...
    fwTab{ fwTab.exp_id == expHeat, 'inj1_min' } ];
expTabs = { noHeatTemps; heatTemps };

for i = 1 : 2 %3
% Calculate timepoint for each temp measurement.
expTemps = expTabs{ i };
inj = datetime( 1, 1, 1, injTimes( i, 1 ), injTimes( i, 2 ), 0 );
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
blTemps = expTemps.tsSec < 0;
        
expTemps.tsSec( blTemps ) = 0;
% Plot all temps for this exp.
expTemps = sortrows( expTemps, 'tsSec' );
expTabs{ i } = expTemps;
clear a b c expTemps
end
figure
hold on
hAx( 1 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.temp, 'b' );
hAx( 2 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.cageTemp, 'b:' );
hAx( 3 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.temp, 'r' );
hAx( 4 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.cageTemp, 'r:' );
hAx( 5 ) = plot( nan, nan, 'k' );
hAx( 6 ) = plot( nan, nan, 'k:' );
hAx( 7 ) = plot( nan, nan, 'w' );
% hAx( 8 ) = plot( expTabs{ 3 }.tsSec / 60, expTabs{ 3 }.temp,...
% 'b', 'LineWidth', 1 );


xlim( [ 0 190 ] )
ylim( [ 19 33 ] )
xticks( [ 0 : 60 : 360 ] )
xlabel( 'Time since injection (min)' )
ylabel( sprintf( 'Temperature (%cC)', 176 ) )
% legend( hAx( [ 1 3 7 5 6 ] ),...
%     { 'No heat support', 'Heat support',...
%     '', 'Mouse fur', 'Chamber floor' },...
%     'Location', 'southeast' )
title( sprintf( 'Combo (10 %cg/mg vaso + %.1f mg/kg PD)',...
    956, fwTab{ fwTab.exp_id == expHeat, 'pd_dose_inj1' } ) )

set( gca, 'FontSize', 12, 'TickDir', 'out' )


