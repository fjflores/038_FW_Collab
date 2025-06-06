function plotcombotemp()

% Load table with info.
fwTabPath = fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' );
opts = detectImportOptions( fwTabPath );
doseTmp = regexp( opts.VariableNames, '.*_dose.*', 'match', 'ignorecase' );
doseCols = string( doseTmp( ~cellfun( @isempty, doseTmp ) ) );
tsTmp = regexp( opts.VariableNames, '.*ts.*', 'match', 'ignorecase' );
tsCols = string( tsTmp( ~cellfun( @isempty, tsTmp ) ) );
opts = setvartype( opts, [ doseCols, tsCols ], 'double' );
fwTab = readtable( fwTabPath, opts );
fwTab = fwTab( fwTab.dex_dose_inj1 == 0 ...
    & fwTab.ket_dose_inj1 == 0 ...
    & fwTab.pdv3_dose_inj1 == 0 ...
    & isnan( fwTab.inj2_ts ), : );
% fwTab = sortrows( fwTab, 'chamber_floor_approx_temp' );
% fwTab = sortrows( fwTab, 'pd_dose_inj1' );

% Get experiment types.
expTypeTmp = fwTab( :, { 'pd_dose_inj1', 'chamber_floor_approx_temp' } );
expTypes = unique( expTypeTmp, 'rows' );
nExpTypes = height( expTypes );

% Set colors.
combo05Col = [ 33,102,172 255 * 0.6 ] / 255;
combo1Col = [ 5,48,97 255 * 0.6 ] / 255;
combo05HeatCol = [ 178,24,43 255 * 0.6 ] / 255;
combo1HeatCol = [ 103,0,31 255 * 0.6 ] / 255;

% Make figure.
figure
hold on
for typeIdx = 1 : nExpTypes
    thisPDdose = expTypes{ typeIdx, 'pd_dose_inj1' };
    thisHeat = expTypes{ typeIdx, 'chamber_floor_approx_temp' };
    typeTab = fwTab( fwTab.pd_dose_inj1 == thisPDdose ...
        & fwTab.chamber_floor_approx_temp == thisHeat, : );
    expList = unique( typeTab.exp_id );
    nExps = length( expList );

    if thisPDdose == 0.5 && thisHeat == 20
        thisCol = combo05Col;
    elseif thisPDdose == 0.5 && thisHeat == 32
        thisCol = combo05HeatCol;
    elseif thisPDdose == 1 && thisHeat == 20
        thisCol = combo1Col;
    elseif thisPDdose == 1 && thisHeat == 32
        thisCol = combo1HeatCol;
    end

    for expIdx = 1 : nExps
        expID = expList( expIdx );
        plotexptemp( expID, 'line', thisCol );

    end

end

% Set figure settings and add labels.
title( 'Mouse Temperature' )
xlabel( 'Time since injection (min)' )
xlim( [ 0 130 ] )
ylim( [ 20 32 ] )
ylabel( sprintf( 'Temperature (%cC)', 176 ) )
% legend( ,... 
%     { 'Combo 0.5', 'Combo 0.5 + heat support', 'Combo 1', 'Combo 1 + heat support' },...
%     'EdgeColor', 'none' )
set( gca, 'FontSize', 12, 'TickDir', 'out' )


end

