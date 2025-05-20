%% cage floor temps
temps = readtable( fullfile( getrootdir, 'Data', 'chamber_floor_temp.xlsx' ) );
figure
scatterjit( temps{ :, 1 }, temps{ :, 2 }, 'Jit', 0.4 )
ylim( [ 19 35 ] )


%% Proto plot temp curves with and without heat pad.

clear temps

exp185Temps = readtable(...
    fullfile( getrootdir, 'Data', 'FW18', 'exp185_temps.xlsx' ) );
exp142Temps = readtable(...
    fullfile( getrootdir, 'Data', 'FW18', 'exp142_temps.xlsx' ) );
% exp94Temps = readtable(...
% fullfile( getrootdir, 'Data', 'FW14', 'exp94_temps.xlsx' ) );
% Add estimated cage temps to exp 100 (all 20 degrees C)
exp142Temps.cageTemp = 20 * ones( height( exp142Temps ), 1 );
% exp94Temps.cageTemp = 20 * ones( height( exp94Temps ), 1 );
injTimes = [ 16 19; 11 52 ];
expTabs = { exp185Temps; exp142Temps };
% injTimes = [ 13 19; 12 38; 11 35 ];
% expTabs = { exp180Temps; exp99Temps; exp94Temps };

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
hAx( 1 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.temp, 'b' );
hAx( 2 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.cageTemp, 'b:' );
hAx( 3 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.temp, 'r' );
hAx( 4 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.cageTemp, 'r:' );
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
legend( hAx( [ 1 3 7 5 6 ] ),...
    { 'No heat support', 'Heat support',...
    '', 'Mouse fur', 'Chamber floor' },...
    'Location', 'southeast' )
title( sprintf( 'Combo (10 %cg/mg vaso + 0.5 mg/kg PD)', 956 ) )

set( gca, 'FontSize', 12, 'TickDir', 'out' )


clear temps

exp184Temps = readtable(...
    fullfile( getrootdir, 'Data', 'FW17', 'exp184_temps.xlsx' ) );
exp125Temps = readtable(...
    fullfile( getrootdir, 'Data', 'FW17', 'exp125_temps.xlsx' ) );
% exp94Temps = readtable(...
% fullfile( getrootdir, 'Data', 'FW14', 'exp94_temps.xlsx' ) );
% Add estimated cage temps to exp 100 (all 20 degrees C)
exp125Temps.cageTemp = 20 * ones( height( exp125Temps ), 1 );
% exp94Temps.cageTemp = 20 * ones( height( exp94Temps ), 1 );
injTimes = [ 13 01; 11 24 ];
expTabs = { exp184Temps; exp125Temps };
% injTimes = [ 13 19; 12 38; 11 35 ];
% expTabs = { exp180Temps; exp99Temps; exp94Temps };

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
hAx( 1 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.temp, 'b' );
hAx( 2 ) = plot( expTabs{ 2 }.tsSec / 60, expTabs{ 2 }.cageTemp, 'b:' );
hAx( 3 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.temp, 'r' );
hAx( 4 ) = plot( expTabs{ 1 }.tsSec / 60, expTabs{ 1 }.cageTemp, 'r:' );
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
legend( hAx( [ 1 3 7 5 6 ] ),...
    { 'No heat support', 'Heat support',...
    '', 'Mouse fur', 'Chamber floor' },...
    'Location', 'southeast' )
title( sprintf( 'Combo (10 %cg/mg vaso + 0.5 mg/kg PD)', 956 ) )

set( gca, 'FontSize', 12, 'TickDir', 'out' )
