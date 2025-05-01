ccc
load( ...
    'E:\Dropbox (Personal)\Projects\034_DARPA_ABC\Results\Dose_Effect\Feature_Table_Long.mat')

feats2plot = {
    "rmsEmg", "mf_L", "dBdelta_L", "mf_R", "dBdelta_R", "mf_C", "Cdelta" };

doses = unique( allFeats.dose );
nDoses = length( doses );
for featIdx = 1 : length( feats2plot )
    figure

    for doseIdx = 1 : nDoses
        thisDose = doses( doseIdx );
        thisFeatIdx = allFeats.dose == thisDose;
        thisFeat = allFeats.( feats2plot{ featIdx } )( thisFeatIdx );
        thisEpochs = allFeats.epochOrd( thisFeatIdx );
        plot( thisEpochs, thisFeat )
        hold on

    end

end