function plotdeltadf( dose )
% Plot delta power AUC across all mice for a single dose

if ~exist( "aucFlag", "var" )
    aucFlag = false;

end

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & fTab.dex_dose_ugperkg == dose;
expList = fTab.exp_id( expListIdx );

% gap = [ 0.005 0.01 ];
% margH = [ 0.1 0.05 ];
% margV = [0.1 0.1];
% opts = { gap, margH, margV };
% yLims = [ 0 50 ];

colormap magma
nExps = length( expList );
csvFileSpec = "example_traces.csv";
for idxExp = 1 : nExps
    thisExp = expList( idxExp );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "ExampleFigData.mat";
    load( fullfile( resDir, f2load ), "spec", "info" );
    tsTab = readtable( fullfile( resDir, csvFileSpec ) );
    tabExpIdx = tsTab.dose == dose;
    S = spec( tabExpIdx ).L;
    t = ( spec( tabExpIdx ).t2plot - ...
        ( spec( tabExpIdx ).t2plot( 1 ) + 600 ) ) / 60;
    f = spec( tabExpIdx ).f2plot;

    % Get spectra after injection
    dexIdxS = t > 0.5;
    Sdex = S( dexIdxS, : );
    tP = t( dexIdxS );
    
    [ mf, sef, df ] = qeegspecgram( Sdex, f, [ 0.5 30 ] );

    plot( tP, sef, Color=[ 0.5 0.5 0.5 ] )
    hold on

end
box off
ylabel( 'Freq. (Hz)' )