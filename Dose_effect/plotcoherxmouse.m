function plotcoherxmouse( mouseId, drug, fLims, db2load )
% MAKESPECFIG plots spectrograms for all doses of a drug in a signle mouse.
% 
% Usage:
% plotcoherxmouse( mouseId, tLims )
% 
% Input:
% mouseId: mouse ID.
% tLims: 2-element vector with time limits before and after the event.

root = getrootdir( );
resDir = fullfile( root, "Results" );

if ~exist( "db2load", "var" )
    db2load = "abc_experiment_list.xlsm";

end

masterTab = readtable( fullfile( resDir, db2load ) );
drug = lower( drug );
expListIdx = masterTab.analyze == 1 ...
    & strcmp( masterTab.drug_inj1, drug ) ...
    & strcmp( masterTab.mouse_id, mouseId );

gap = [ 0.005 0.01 ];
margH = [ 0.07 0.08 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };

colormap magma
% expList = masterTab.exp_id( expListIdx );
% doseList = masterTab.drug_dose_inj1( expListIdx );
nExps = sum( expListIdx );
% plotIdx = 1 : 2 : 2 * nExps;
colorLims = [ 0 3 ];

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

end

f2load = strcat( "TidyData_", drug, ".mat" );
load( fullfile( resDir, mouseId, f2load ), "notes", "coher" );
for expIdx = 1 : nExps
    tInj1 = notes( expIdx ).tInj1;
    t = ( coher( expIdx ).t - tInj1 ) / 60;
    f = coher( expIdx ).f;
    thisDose = notes( expIdx ).doseInj1;

    if expIdx == 1
        tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];

    end
    
    % Left Spectrogram
    if coher( expIdx ).valid( 1 ) == true % Check if channel is invalid.
        C = coher( expIdx ).C;
        idx1 = C > 1 - 1e-6;
        C( idx1 ) = 0;
        
    else    
        sz = size( coher( expIdx ).C );
        C = zeros( sz );

    end
    
    hAx( expIdx ) = subtightplot( nExps, 1, expIdx, opts{ : } );
    plotcohergram( C, t, f, "tan" )
    box off
    clim( colorLims )
    xLims = get( gca, 'xlim' );
    ylim( fLims )
    posX = xLims( 1 ) + 2;
    posY = fLims( 2 ) - 5;
    if thisDose == 0
        tit = "saline";

    else
        tit = sprintf( '%s %u %cg/kg', drug, thisDose, units );

    end
    text( posX, posY, tit,...
        'Color', 'w',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Freq. (Hz)" )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  0 : 10 : fLims( end ) - 10  )
ffcbar( gcf, hAx( end ), "Power (dB)" );
% hAx( 1 ).Title.String = "Left hemisphere";
% hAx( 2 ).Title.String = "Right hemisphere";

sgtitle( sprintf(...
    "Coherence from mouse %s at each dose", mouseId ) );

set( hAx( 2 : 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", 0 : 20 : tLims( 2 ),...
    "XTickLabel", 0 : 20 : tLims( 2 ) )
xlabel( hAx( end - 1 : end ), "Time (min)" );
set( hAx, 'FontSize', 12, 'TickDir', 'out' )
set( gcf, "Units", "normalized", "Position", [ 0.30 0.31 0.37 0.47 ] )


