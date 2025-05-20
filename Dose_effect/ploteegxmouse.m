function ploteegxmouse( mouseId, drug, eegKind )
% PLOTSPECXMOUSE plots spectrograms for doses of a drug in a mouse.
%
% Usage:
% plotspecxmouse( mouseId, drug, fLims, db2load )
%
% Input:
% mouseId: mouse ID.
% drug: drug to plot. Either "dex", "ket", or "pro".
% fLims: 2-element vector with frequency limits.
% db2load: Optional. experiment database file.

drug = lower( drug );

root = getrootdir( );
resDir = fullfile( root, "Results" );

if ~exist( "db2load", "var" )
    db2load = "abc_experiment_list.xlsm";

end

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

end

% define y-limits
switch eegKind
    case "eeg"
        yLimits = [ -1500 1500 ]; 
        yTick = [ -1000 10000 ];

    case "eegZ"
        yLimits = [ -15 15 ];  % milli
        yTick = [ -10 10 ];

end


f2load = strcat( "TidyData_", drug, ".mat" );
thisData = load( fullfile( resDir, mouseId, f2load ), "notes", eegKind );
for expIdx = 1 : nExps
    tInj1 = thisData.notes( expIdx ).tInj1;
    thisDose = thisData.notes( expIdx ).doseInj1;

    t = ( thisData.( eegKind )( expIdx ).t - tInj1 ) / 60;
    if expIdx == 1
        tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];

    end
    
  
    datL = thisData.( eegKind )( expIdx ).dataL;
    datR = thisData.( eegKind )( expIdx ).dataR;

    subIdx = ( 2 * expIdx )  - 1;
    hAx( subIdx ) = subtightplot( nExps, 2, subIdx, opts{ : } );
    plot( t, datL, "Color", colors( 1, : ) );
    xLims = get( hAx( subIdx ), 'xlim' );
    ylim( yLimits )
    posX = xLims( 1 ) + 2;
    posY = yLimits( 2 ) - 5;
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

    subIdx = 2 * expIdx;
    hAx( subIdx ) = subtightplot( nExps, 2, subIdx, opts{ : } );
    plot( t, datR, "Color", colors( 2, : ) );
    xLims = get( gca, 'xlim' );
    ylim( yLimits )
    posX = xLims( 1 ) + 2;
    posY = yLimits( 2 ) - 5;
    text( posX, posY, tit,...
        'Color', 'k',...
        'FontWeight', 'bold',...
        'FontSize', 10 )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  yTick,...
    'Box', 'off' )
hAx( 1 ).Title.String = "Left hemisphere";
hAx( 2 ).Title.String = "Right hemisphere";

sgtitle( sprintf(...
    "EEG from %s at each dose", mouseId ), ...
    "FontSize", 12 );

set( hAx( 2 : 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", 0 : 20 : tLims( 2 ),...
    "XTickLabel", 0 : 20 : tLims( 2 ) )
xlabel( hAx( end - 1 : end ), "Time (min)" );
% set( hAx, 'FontSize', 12, 'TickDir', 'out' )
% set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )


