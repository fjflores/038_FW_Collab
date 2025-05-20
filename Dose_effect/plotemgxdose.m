function plotemgxdose( drug, dose, emgKind )
% Plot all specs for a given dose acros mice

drug = lower( drug );
root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & ...
    fTab.drug_dose_inj1 == dose & ...
    strcmp( drug, fTab.drug_inj1 );
expList = fTab.exp_id( expListIdx );

gap = [ 0.005 0.01 ];
margH = [ 0.07 0.08 ];
margV = [0.1 0.1];
opts = { gap, margH, margV };
colors = brewermap( 2, 'Set1' );

% define units
switch lower( drug )
    case "dex"
        units = 956; % micro

    case { "ket", "pro" }
        units = 109; % milli

end

% define y-limits
switch emgKind
    case "emg"
        yLimits = [ -1500 1500 ]; 
        yTick = [ -1000 10000 ];

    case "emgRms"
        yLimits = [ 0 250 ]; 
        yTick = [ 50 150 ];

end

nExps = length( expList );
for expIdx = 1 : nExps
    thisExp = expList( expIdx );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = strcat( "TidyData_", drug, ".mat" );
    thisData = load( fullfile( resDir, f2load ), emgKind, "notes" );
    tabExpIdx = find( [ thisData.notes.expId ] == thisExp );

    tInj1 = thisData.notes( tabExpIdx ).tInj1;
    t = ( thisData.( emgKind )( tabExpIdx ).t - tInj1 ) / 60;
    if expIdx == 1
        tLims = [ floor( t( 1 ) ) ceil( t( end ) ) ];

    end
    data = thisData.( emgKind )( tabExpIdx ).data;

    hAx( expIdx ) = subtightplot( nExps, 1, expIdx, opts{ : } );
    plot( t, data, "Color", colors( 2, : ) );
    xLims = get( hAx( expIdx ), 'xlim' );
    ylim( yLimits )
    posX = xLims( 1 ) + 2;
    posY = yLimits( 2 ) - 5;
    tit = sprintf( '%s', metDat.subject );
    text( posX, posY, tit,...
        'Color', 'k',...
        'FontWeight', 'bold',...
        'FontSize', 10 )
    ylabel( "Amp. (uV)" )

end

set( hAx,...
    'FontSize', 12,...
    'TickDir', 'out',...
    'XTickLabel', [],...
    'YTick',  yTick,...
    'Box', 'off' )

sgtitle( sprintf(...
    "EMG from each mouse at %u %sg/kg", dose, units ), ...
    "FontSize", 12 );

set( hAx( 2 : 2 : end ),...
    "YTickLabel", [] )
set( hAx( end - 1 : end ),...
    "XTick", 0 : 20 : tLims( 2 ),...
    "XTickLabel", 0 : 20 : tLims( 2 ) )
xlabel( hAx( end - 1 : end ), "Time (min)" );

