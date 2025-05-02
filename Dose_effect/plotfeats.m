ccc
root = getrootdir( );
load( fullfile( root, 'Results\Dose_Effect\Feature_Table_Long.mat' ) )

feats2plot = {
    "rmsEmg", "mf_L", "dBdelta_L", "mf_R", "dBdelta_R", "mf_C", "Cdelta" };
featsYlabels = {
    "r.m.s. (uV)", "freq. (Hz)", "power (dB)", "freq. (Hz)", "power (dB)",
    "freq. (Hz)", "coherence (a.u.)" };

doses = unique( allFeats.dose );
epochTmp = unique( allFeats.epoch );
epochLabels = epochTmp( 2 : 2 : end );

nDoses = length( doses );
colorTmp = brewermap( 9, 'YlOrRd' );
colors = colorTmp( [ 3 : 6 8 : 9 ], : );
for featIdx = 1 : length( feats2plot )
    figure
    thisFeat = feats2plot{ featIdx };

    for doseIdx = 1 : nDoses
        thisDose = doses( doseIdx );
        dat2plot = getdat2plot( allFeats, thisFeat, thisDose );
        hLinesThin = plot( dat2plot );
        set( hLinesThin, "Color", [ colors( doseIdx, : ) 0.4 ] );
        hold on
        hLinesThick( doseIdx ) = plot( median( dat2plot, 2, "omitmissing" ), ...
            "Color", colors( doseIdx, : ), ...
            "LineWidth", 2 );
        hold on

    end
    title( thisFeat )
    legend( hLinesThick, num2str( doses ) )
    box off
    set( gca, ...
        "XTick", [ 2 : 2 : 14 ], ...
        "XTickLabel", [ 0 : 10 : 60 ] )


end

function dat2plot = getdat2plot( allFeats, thisFeat, thisDose )

miceList = unique( allFeats.mouseId );
nMice = length( miceList );
dat2plot = [];
for mouseIdx = 1 : nMice
    thisMouse = miceList( mouseIdx );
    thisIdx = strcmp( thisMouse, allFeats.mouseId ) & ...
        allFeats.dose == thisDose;

    if sum( thisIdx ) > 0
        dat2plot( :, mouseIdx ) = allFeats.( thisFeat )( thisIdx );

    else
        dat2plot( :, mouseIdx ) = nan( 14, 1 );

    end

end

end