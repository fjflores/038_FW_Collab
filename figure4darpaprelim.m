%% Plot tail pinch scores for combo only (no heat pad), including Priya's 
% og cohort.
% 
% Bar chart for DARPA preliminary grant proposal Jun-2025

% ccc
clear all
clc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

tpTabPathEEGCoh = fullfile( resDir, 'FW_tail_pinch_table.csv');
tpTabPathOGCoh = fullfile(...
    resDir, 'FW_collab' ,'FW_tail_pinch_table_ogmice.csv' );

opts = detectImportOptions( tpTabPathEEGCoh );
doseTmp = regexp( opts.VariableNames, '.*Dose.*', 'match' );
doseCols = string( doseTmp( ~cellfun( @isempty, doseTmp ) ) );
tsTmp = regexp( opts.VariableNames, '.*ts.*', 'match', 'ignorecase' );
tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
opts = setvartype( opts, [ doseCols, tsCols ], 'double' );
tpTabEEG = readtable( tpTabPathEEGCoh, opts );
tpTabOG = readtable( tpTabPathOGCoh, opts );
tpTab = vertcat( tpTabEEG, tpTabOG );
tpTab.approxMinCode = zeros( height( tpTab ), 1 ); 
tpTab.approxMinCode( tpTab.approxMin == 30 ) = 1;
tpTab.approxMinCode( tpTab.approxMin == 60 ) = 2;
tpTab.approxMinCode( tpTab.approxMin == 120 ) = 3;

ctrlCol = [ 0.4 0.4 0.4 ];
combo025Col = [ 107 174 214 ] / 255;
combo05Col = [ 49 130 189 ] / 255;
combo1Col = [ 8 81 156 ] / 255;

cols = [ combo025Col; combo05Col; combo1Col ];

% Get exps of interest.
% So far, all vaso doses = 10 ug/kg.
pdDoses = [ 0.25 0.5 1 ];
dexDoses = 0;
ketDoses = 0;
floorTemps = [ 20 ];
tpMins2exclude = [ 0 5 35 120 ]; % only include 30- and 60-min tail pinches
exp2exclude = [ 129 138 143 154 ]; % manually exclude delayed ket bc ketIdcs not working properly 

pdIdcs = ismember( tpTab.pdDose1, pdDoses ) | ismember( tpTab.pdDose2, pdDoses );
dexIdcs = ismember( tpTab.dexDose1, dexDoses ) | ismember( tpTab.dexDose2, dexDoses );
ketIdcs = ismember( tpTab.ketDose1, ketDoses ) | ismember( tpTab.ketDose2, ketDoses ); % MAKES THIS ACTUALLY WORK
tempIdcs = ismember( tpTab.floorTemp, floorTemps );
minIdcs = ~ismember( tpTab.approxMin, tpMins2exclude );
expIdcs = ~ismember( tpTab.expID, exp2exclude );
expOIIdcs = all( [ pdIdcs dexIdcs ketIdcs tempIdcs minIdcs expIdcs ], 2 );

subTpTab = tpTab( expOIIdcs, : );
expList = unique( subTpTab.expID );
condTab = subTpTab( :, [ doseCols "floorTemp" ] ); % unique exp conditions
condTabTmp = table2array( condTab );
for rowIdx = 1 : height( condTab )
    condTabTmp( rowIdx, isnan( condTabTmp( rowIdx, : ) ) ) = -99;
end
expTypes = unique( condTabTmp, 'rows' );
nExpTypes = height( expTypes );
offsets = linspace( -0.25, 0.25, nExpTypes );

% combine saline + baseline conditions
salIdcs = tpTab.vasoDose1 == 0;
blIdcs = tpTab.approxMin == 0;
ctrlIdcs = any( [ salIdcs blIdcs ], 2 );
subTpBLTab = tpTab( ctrlIdcs, : );

mins = unique( subTpTab.approxMin );
cnt = 1;

figure
hold on
for pdIdx = 1 : length( pdDoses )
    thisDose = pdDoses( pdIdx );
    theseExps = subTpTab( subTpTab.pdDose1 == thisDose, : );
    offset = offsets( pdIdx );
    thisCol = cols( pdIdx, : );    

    for minIdx = 1 : length( mins )
        thisMin = mins( minIdx );
        theseTPs = theseExps( theseExps.approxMin == thisMin, : );
        thisMean = mean( theseTPs.scoreAvg );
        thisStdErr = std( theseTPs.scoreAvg ) / sqrt( length( theseTPs.scoreAvg ) );

        bAx( pdIdx ) = bar( minIdx + offset, thisMean, 0.2,...
            'EdgeColor', 'none', 'FaceColor', thisCol, 'FaceAlpha', 0.6 );
        hAx( pdIdx ) = scatterjit( theseTPs.approxMinCode + offset,...
        theseTPs.scoreAvg,...
        40, 'filled', 'MarkerFaceColor', thisCol,...
        'MarkerFaceAlpha', 0.8, 'Jit', [ 0.08 ], 'Axis', 'x' );
        errorbar( minIdx + offset, thisMean, thisStdErr, 'Color', 'k' );

    end   

end

blMean = mean( subTpBLTab.scoreAvg );
blStdErr = std( subTpBLTab.scoreAvg ) / sqrt( length( subTpBLTab.scoreAvg ) );
bAx( pdIdx + 1 ) = bar( 0, blMean, 0.2,...
    'EdgeColor', 'none', 'FaceColor', ctrlCol, 'FaceAlpha', 0.6 );
hAx( pdIdx + 1 ) = scatterjit( zeros( height( subTpBLTab ), 1 ),...
    subTpBLTab.scoreAvg,...
    40, 'filled', 'MarkerFaceColor', ctrlCol,...
    'MarkerFaceAlpha', 0.8, 'Jit', [ 0.08 ], 'Axis', 'x' );
errorbar( 0, blMean, blStdErr, 'Color', 'k' );

% xlim( [ -5 130 ] )
xlim( [ -0.6 2.8 ] )
ylim( [ 0 4.5 ] )
% xticks( [ 0 5 30 35 60 120 ] )
xticks( [ 0 : 1 : 3 ] )
xticklabels( { 'baseline', '30', '60', '120' } )
yticks( [ 1 : 1 : 4 ] )
xlabel( 'Time after injection (min)' )
ylabel( 'Tail pinch score' )
legend ( hAx( [ 1 2 3 ] ),... 
    { 'Combo 0.25', 'Combo 0.5', 'Combo 1' }, 'EdgeColor', 'none' )
legend ( bAx( [ 1 2 3 ] ),... 
    { 'Combo 0.25', 'Combo 0.5', 'Combo 1' }, 'EdgeColor', 'none' )
set( gca, 'FontSize', 12, 'TickDir', 'out' )


%% Same as above but include all combo tail pinches (no heat pad, heat pad,
% + Priya's og cohort).

% ccc
clear all
clc

% Get dirs.
root = getrootdir;
datDir = fullfile( root, 'Data' );
resDir = fullfile( root, 'Results' );

tpTabPathEEGCoh = fullfile( resDir, 'FW_tail_pinch_table.csv');
tpTabPathOGCoh = fullfile(...
    resDir, 'FW_collab' ,'FW_tail_pinch_table_ogmice.csv' );

opts = detectImportOptions( tpTabPathEEGCoh );
doseTmp = regexp( opts.VariableNames, '.*Dose.*', 'match' );
doseCols = string( doseTmp( ~cellfun( @isempty, doseTmp ) ) );
tsTmp = regexp( opts.VariableNames, '.*ts.*', 'match', 'ignorecase' );
tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
opts = setvartype( opts, [ doseCols, tsCols ], 'double' );
tpTabEEG = readtable( tpTabPathEEGCoh, opts );
tpTabOG = readtable( tpTabPathOGCoh, opts );
% tpTab = vertcat( tpTabEEG, tpTabOG );
tpTab = tpTabEEG;
tpTab.approxMinCode = zeros( height( tpTab ), 1 ); 
tpTab.approxMinCode( tpTab.approxMin == 5 ) = 1;
tpTab.approxMinCode( tpTab.approxMin == 30 ) = 2;
tpTab.approxMinCode( tpTab.approxMin == 60 ) = 3;
tpTab.approxMinCode( tpTab.approxMin == 120 ) = 4;

ctrlCol = [ 0.4 0.4 0.4 ];
% combo025Col = [ 67,147,195 ] / 255;
combo05Col = [ 33,102,172 ] / 255;
combo1Col = [ 5,48,97 ] / 255;
% combo025HeatCol = [ nan nan nan ];
combo05HeatCol = [ 178,24,43 ] / 255;
combo1HeatCol = [ 103,0,31 ] / 255;

cols = [ combo05Col; combo05HeatCol; combo1Col; combo1HeatCol ];

% Get exps of interest.
% So far, all vaso doses = 10 ug/kg.
pdDoses = [ 0.5 1 ];
dexDoses = 0;
ketDoses = 0;
floorTemps = [ 20 32 ];
tpMins2exclude = [ 0 35 ]; % exclude baseline pinches
exp2exclude = [ 129 138 143 154 ]; % manually exclude delayed ket bc ketIdcs not working properly 

pdIdcs = ismember( tpTab.pdDose1, pdDoses ) | ismember( tpTab.pdDose2, pdDoses );
dexIdcs = ismember( tpTab.dexDose1, dexDoses ) | ismember( tpTab.dexDose2, dexDoses );
ketIdcs = ismember( tpTab.ketDose1, ketDoses ) | ismember( tpTab.ketDose2, ketDoses ); % MAKES THIS ACTUALLY WORK
tempIdcs = ismember( tpTab.floorTemp, floorTemps );
minIdcs = ~ismember( tpTab.approxMin, tpMins2exclude );
expIdcs = ~ismember( tpTab.expID, exp2exclude );
expOIIdcs = all( [ pdIdcs dexIdcs ketIdcs tempIdcs minIdcs expIdcs ], 2 );

subTpTab = tpTab( expOIIdcs, : );
expList = unique( subTpTab.expID );
condTab = subTpTab( :, [ doseCols "floorTemp" ] ); % unique exp conditions
condTabTmp = table2array( condTab );
for rowIdx = 1 : height( condTab )
    condTabTmp( rowIdx, isnan( condTabTmp( rowIdx, : ) ) ) = -99;
end
expTypes = unique( condTabTmp, 'rows' );
nExpTypes = height( expTypes );
% offsets = linspace( -0.45, 0.45, nExpTypes );
offsets = linspace( -0.3, 0.3, 4 );
offsets = [ -0.3 -0.12 0.12 0.3 ];

% combine saline + baseline conditions
salIdcs = tpTab.vasoDose1 == 0;
blIdcs = tpTab.approxMin == 0;
ctrlIdcs = any( [ salIdcs blIdcs ], 2 );
subTpBLTab = tpTab( ctrlIdcs, : );

mins = unique( subTpTab.approxMin );
cnt = 1;

figure
hold on
for pdIdx = 1 : length( pdDoses )
    thisDose = pdDoses( pdIdx );
    theseExps = subTpTab( subTpTab.pdDose1 == thisDose, : );

    for heatIdx = 1 : length( floorTemps )
        thisHeat = floorTemps( heatIdx );
        theseExpsHeat = theseExps( theseExps.floorTemp == thisHeat, : );
        thisCol = cols( cnt, : );
        offset = offsets( cnt );

        for minIdx = 1 : length( mins )
            thisMin = mins( minIdx );
            theseTPs = theseExpsHeat( theseExpsHeat.approxMin == thisMin, : );
            thisMean = mean( theseTPs.scoreAvg );
            thisStdErr = std( theseTPs.scoreAvg ) / sqrt( length( theseTPs.scoreAvg ) );

            bAx( cnt ) = bar( minIdx + offset, thisMean, 0.18,...
                'EdgeColor', 'none', 'FaceColor', thisCol, 'FaceAlpha', 0.6 );
            hAx( cnt ) = scatterjit( theseTPs.approxMinCode + offset,...
                theseTPs.scoreAvg,...
                40, 'filled', 'MarkerFaceColor', thisCol,...
                'MarkerFaceAlpha', 0.8, 'Jit', [ 0.05 ], 'Axis', 'x' );
            errorbar( minIdx + offset, thisMean, thisStdErr, 'Color', 'k' );

        end

        cnt = cnt + 1;

    end

end

blMean = mean( subTpBLTab.scoreAvg );
blStdErr = std( subTpBLTab.scoreAvg ) / sqrt( length( subTpBLTab.scoreAvg ) );
bAx( cnt + 1 ) = bar( 0.3, blMean, 0.18,...
    'EdgeColor', 'none', 'FaceColor', ctrlCol, 'FaceAlpha', 0.6 );
hAx( cnt + 1 ) = scatterjit( zeros( height( subTpBLTab ), 1 ) + 0.3,...
    subTpBLTab.scoreAvg,...
    40, 'filled', 'MarkerFaceColor', ctrlCol,...
    'MarkerFaceAlpha', 0.8, 'Jit', [ 0.05 ], 'Axis', 'x' );
errorbar( 0.3, blMean, blStdErr, 'Color', 'k' );

% xlim( [ -5 130 ] )
xlim( [ 0 4.8 ] )
ylim( [ 0 4.5 ] )
% xticks( [ 0 5 30 35 60 120 ] )
xticks( [ 0.3 1 : 5 ] )
xticklabels( { 'baseline', '5', '30', '60', '120' } )
yticks( [ 1 : 1 : 4 ] )
xlabel( 'Time after injection (min)' )
ylabel( 'Tail pinch score' )
% legend ( hAx( [ 1 2 3 4 ] ),... 
%     { 'Combo 0.5', 'Combo 0.5 + heat support', 'Combo 1', 'Combo 1 + heat support' }, 'EdgeColor', 'none' )
legend ( bAx( [ 1 2 3 4 ] ),... 
    { 'Combo 0.5', 'Combo 0.5 + heat support', 'Combo 1', 'Combo 1 + heat support' }, 'EdgeColor', 'none' )
set( gca, 'FontSize', 12, 'TickDir', 'out' )