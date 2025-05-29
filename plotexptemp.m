function expMsg = plotexptemp( expID, style )
% PLOTEXPTEMP plots mouse surface temps for given experiment.
% Note: currently only works for FW collab experiments.
%
% Usage: expMsg = plotexptemp( expID, style )
%
% Input:
% expID: experiment ID.
% style: 'line' or 'curve' to plot temperature curve (default); 'dot' or
% 'scatter' to plot scatter plot (optional).
%
% Output:
% Plots temperatures as curve or scatter plot.
% expMsg: drug dose in words for use in legend.

if nargin < 2
    style = 'curve';
end

% Get exp metadata.
metDat = getmetadata( expID );
mID = metDat.subject;

% Load appropriate table.
if metDat.FWCollab == 1
    bigTab = readtable(...
        fullfile( getrootdir, 'Results', 'FW_collab_exp_details.xlsx' ) );

elseif metDat.FWCollab == 0
    bigTab = readtable(...
        fullfile( getrootdir, 'Results', 'abc_experiment_list.xlsm' ) );

end

expTab = bigTab( bigTab.exp_id == expID, : );

% Load csv with this exp's temps.
fName = sprintf( 'exp%i_temps.xlsx', expID );
fPath = fullfile( getrootdir, 'Data', mID, fName );
if exist( fPath )
    expTemps = readtable( fPath );

else
    warning( '%s does not exist.', fName )
    expMsg = '';
    return

end

% Calculate timepoint for each temp measurement.
inj = datetime( 1, 1, 1, expTab.inj1_hr, expTab.inj1_min, 0 );

ts = regexp( expTemps.tsClock, "(\d+):(\d{2})", "tokens" );
for tsIdx = 1 : length( ts )
    a( tsIdx, : ) = str2double( ts{ tsIdx }{ : } );
    if a( tsIdx, 1 ) < 9 % convert 12-hr to 24-hr time
        a( tsIdx, 1 ) = a( tsIdx, 1 ) + 12;

    end

end

b = datetime( 1, 1, 1,...
    a( :, 1 ), a( :, 2 ), 0 );

c = between( inj, b );
c = time( c );
c = round( seconds( c ) );

expTemps.tsSec = c;

% For plotting purposes, change baseline temp to be at inj time.
blTemps = expTemps.tsSec < 0;
if sum( blTemps ) > 1
    expTemps( end + 1, : ) = {...
        '', mean( expTemps.temp( blTemps ) ), 0 };
    expTemps( blTemps, : ) = [];
    % fprintf( 'Using average of multiple baseline temps.\n' )

else
    expTemps.tsSec( blTemps ) = 0;

end

% Plot all temps for this exp.
expTemps = sortrows( expTemps, 'tsSec' );

switch style
    case { 'curve', 'line', 'plot' }
        plot( expTemps.tsSec / 60, expTemps.temp )

    case { 'scatter', 'dot', 'dots' }
        scatter( expTemps.tsSec / 60, expTemps.temp,...
            'filled', 'MarkerFaceAlpha', 0.7 )

end

% Determine proper legend entry for this exp.
vasoMsg = '';
pdMsg = '';
dexMsg = '';
ketMsg = '';
if expTab.vaso_dose_inj1 > 0
    vasoMsg = sprintf( '%i %cg/kg vaso',...
        expTab.vaso_dose_inj1, 956 );
end
if expTab.pd_dose_inj1 > 0
    pdMsg = sprintf( ' + %.1f mg/kg PD',...
        expTab.pd_dose_inj1 );
end
if expTab.dex_dose_inj1 > 0
    dexMsg = sprintf( ' + %i %cg/kg dex',...
        expTab.dex_dose_inj1, 956 );
end
if str2double( expTab.ket_dose_inj2{ 1 } ) > 0
    ketMsg = sprintf( ' + delayed %i mg/kg ket',...
        str2double( expTab.ket_dose_inj2{ 1 } ) );
elseif expTab.ket_dose_inj1 > 0
    ketMsg = sprintf( ' + %i mg/kg ket',...
        expTab.ket_dose_inj1 );
end
expMsg = [ vasoMsg, pdMsg, dexMsg, ketMsg ];


end

