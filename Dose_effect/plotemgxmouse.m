function plotemgxmouse( mouseId, drug, emgKind )
% PLOTSPECXMOUSE plots spectrograms for doses of a drug in a mouse.
%
% Usage:
% plotemgxmouse( mouseId, drug, emgKind )
%
% Input:
% mouseId: mouse ID.
% drug: drug to plot. Either "dex", "ket", or "pro".


drug = lower( drug );

root = getrootdir( );
resDir = fullfile( root, "Results" );
db2load = "abc_experiment_list.xlsm";

masterTab = readtable( fullfile( resDir, db2load ) );
expListIdx = masterTab.analyze == 1 ...
    & strcmp( masterTab.drug_inj1, drug ) ...
    & strcmp( masterTab.mouse_id, mouseId );

gap = [ 0.005 0.01 ];
margH = [ 0.07 0.08 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
nExps = sum( expListIdx );
colors = brewermap( 2, 'Set1' );

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

    otherwise
        units = 32;  % blank space?

end

% define y-limits
switch emgKind
    case "emg"
        yLimits = [ -1000 1000 ]; 
        yTick = [ -500 500 ];

    case "emgRms"
        yLimits = [ 0 15 ];  % milli
        yTick = [ 0 10 ];

end

f2load = strcat( "TidyData_", drug, ".mat" );
thisData = load( fullfile( resDir, mouseId, f2load ), "notes", "emg" );
for expIdx = 1 : nExps
    tInj1 = thisData.notes( expIdx ).tInj1;
    t = ( thisData.emg( expIdx ).t - tInj1 ) / 60;
    thisDose = thisData.notes( expIdx ).doseInj1;

    if expIdx == 1
        tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];

    end
  
    data = thisData.emg( expIdx ).data;
    hAx( expIdx ) = subtightplot( nExps, 1, expIdx, opts{ : } );
    plot( t, data, "Color", colors( 2, : ) );
    xLims = get( hAx( expIdx ), 'xlim' );
    ylim( yLimits )
    posX = xLims( 1 ) + 2;
    posY = yLimits( 2 ) - 500;
    if thisDose == 0
        tit = "saline";

    else
        tit = sprintf( '%s %u %cg/kg', drug, thisDose, units );

    end

    text( posX, posY, tit,...
        'Color', 'k',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Amp. (uV)" )

end

set( hAx,...
    'FontSize', 10,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  yTick  )

sgtitle( sprintf(...
    "EMG from %s at each dose", mouseId ), ...
    "FontSize", 12 );

set( hAx( end - 1 : end ),...
    "XTick", 0 : 20 : tLims( 2 ),...
    "XTickLabel", 0 : 20 : tLims( 2 ) )
xlabel( hAx( end - 1 : end ), "Time (min)" );
set( hAx, 'FontSize', 10, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )


