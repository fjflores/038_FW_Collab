function plotdeltatc( dose, aucFlag )
% Plot delta power AUC across all mice for a single dose

if ~exist( "aucFlag", "var" )
    aucFlag = false;

end

root = getrootdir( );
csvFileMaster = "abc_experiment_list.xlsm";
fTab = readtable( fullfile( root, "Results", csvFileMaster ) );
expListIdx = fTab.analyze == 1 & fTab.drug_dose == dose;
expList = fTab.exp_id( expListIdx );
band = [ 0.5 3 ];
% gap = [ 0.005 0.01 ];
% margH = [ 0.1 0.05 ];
% margV = [0.1 0.1];
% opts = { gap, margH, margV };
% yLims = [ 0 50 ];

colormap magma
nExps = length( expList );
% csvFileSpec = "example_traces.csv";
for idxExp = 1 : nExps
    thisExp = expList( idxExp );
    metDat = getmetadata( thisExp );
    resDir = fullfile( root, "Results", metDat.subject );
    f2load = "TidyData.mat";
    thisData = load( fullfile( resDir, f2load ), "spec", "notes" );
    structIdx = [ thisData.notes.expId ] == thisExp;

    valid = thisData.spec( structIdx ).valid( 1 );
    if valid
        tInj = thisData.notes( structIdx ).tInj;
        S = thisData.spec( structIdx ).SL;
        t = thisData.spec( structIdx ).t - tInj;
        f = thisData.spec( structIdx ).f;

        % Get spectra after injection
        dexIdxS = t > 0.5;
        Sdex = S( dexIdxS, : );
        tP = t( dexIdxS );

        if aucFlag
            P = powerperband( Sdex, f, band, 'total' );
            % P = cumsum( tmp );
            % tP = tP( 2 : end );

        else
            P = powerperband( Sdex, f, band, 'median' );

        end
        plot( tP, P, Color=[ 0.5 0.5 0.5 ] )
        hold on

    end
    disprog( idxExp, nExps, 10 )

end