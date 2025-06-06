function plotmousetemp( mice )
% PLOTMOUSETEMP makes plot comparing mouse surface temps for different drug
% combos.

% Load table with info.
fwTab = readtable(...
    fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );
fwTab = sortrows( fwTab, 'dex_dose_inj1' );
fwTab = sortrows( fwTab, 'ket_dose_inj1' );
fwTab = sortrows( fwTab, 'ket_dose_inj2', 'descend' );
fwTab = sortrows( fwTab, 'pd_dose_inj1' );


% Get mouse list.
mice = string( mice );
if strcmp( mice, "all" )
    mice = string( unique( fwTab.mouse_id ) );
end

% Make figure.
figure
hold on
lgndCnt = 1;
for mIdx = 1 : length( mice )
    thisM = mice( mIdx );
    mTab = fwTab( strcmp( fwTab.mouse_id, thisM ), : );
    expList = mTab.exp_id;

    for expIdx = 1 : length( expList )
        expID = expList( expIdx );
        expMsg = plotexptemp( expID );

        if ~isempty( expMsg )
            expLabs{ lgndCnt } = expMsg;
            lgndCnt = lgndCnt + 1;
        end

    end

end

% Set figure settings and add labels.
title( sprintf( 'Mouse Temperature - %s', thisM ) )
xlabel( 'Time since injection (min)')
xlim( [ 0 140 ] )
ylim( [ 21 32 ] )
ylabel( sprintf( 'Temperature (%cC)', 176 ) )
legend( expLabs )


end

