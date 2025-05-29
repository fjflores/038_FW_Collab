ccc
root = getrootdir( );
tab2read = 'Feature_table_long_dex5.mat';
load( fullfile( root, 'Results\Dose_Effect\', tab2read ) )


% % Clean table from anomalous values less than 1e-5
% cutoff = 10e-10;
% rowsToReplace = any( allFeats{ :, 7} < cutoff, 2 );
% 
% % Replace those rows with NaNs
% allFeats( rowsToReplace, 5 : 14 ) = { NaN };

feats2plot = {
    "rmsEmg", "mf_L", "dBdelta_L", "mf_R", "dBdelta_R", "mf_C", "Cdelta" };
featsYlabels = {
    "r.m.s. (uV)", "freq. (Hz)", "power (dB)", "freq. (Hz)", "power (dB)",...
    "freq. (Hz)", "coher. (a.u.)" };

doses = unique( allFeats.dose );
epochTmp = unique( allFeats.epoch );
nEpochs = length( epochTmp );
epochLabels = natsort( cellstr( epochTmp ) );

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
    legend( hLinesThick, num2str( doses ), "Location", "eastoutside" )
    box off
    set( gca, ...
        "XTick", 1 : nEpochs, ...
        "XTickLabel", epochLabels,...
        "XTickLabelRotation", 45,...
        "XLim", [ 0 nEpochs + 1 ] )
    xlabel( "epoch (min)" )
    ylabel( featsYlabels{ featIdx } )


end

function dat2plot = getdat2plot( allFeats, thisFeat, thisDose )

miceList = unique( allFeats.mouseId );
nMice = length( miceList );
nEpochs = length( unique( allFeats.epochOrd ) );
dat2plot = [];
for mouseIdx = 1 : nMice
    thisMouse = miceList( mouseIdx );
    thisIdx = strcmp( thisMouse, allFeats.mouseId ) & ...
        allFeats.dose == thisDose;
    thisEpochFeats = allFeats.( thisFeat )( thisIdx );
    numZeros = sum( thisEpochFeats == 0 );

    if numZeros == 0 && ~isempty( thisEpochFeats )
        dat2plot( :, mouseIdx ) = thisEpochFeats;

    else
        dat2plot( :, mouseIdx ) = nan( nEpochs, 1 );

    end

end
% dat2plot( :, all( dat2plot == 0, 1 ) ) = [];

end