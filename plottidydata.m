function plottidydata( mouseOrDose, drug, vars2plot )
% PLOTTIDYDATA plots a set of variables by mouse.

% Check first argument
doseFlag = false;
mouseFlag = false;
if ischar( mouseOrDose ) || isstring( mouseOrDose )
    mouseFlag = true;
    mouseOrDose = string( mouseOrDose );
    mouseId = mouseOrDose;

elseif isnumeric( mouseOrDose )
    doseFlag = true;
    dose = mouseOrDose;

else
    error( "Wrong data type in mouseOrDose" )

end

nVars = length( vars2plot );
% Plot
for varIdx = 1 : nVars
    figure
    colormap magma
    thisVar = vars2plot{ varIdx };

    if mouseFlag
        plotxmouse( mouseId, drug, thisVar )

    elseif doseFlag
        plotxdose( drug, dose, thisVar )

    else
        error( "Something weird in plot flags." )

    end

end
set( gcf, "Units", "normalized", "Position", [ 0.10 0.18 0.60 0.70 ] )


%--------------------------------------------------------------------------
% Helper fx to plot by mouse
function plotxmouse( mouseId, drug, thisVar )

% Define freq lims
if strcmp( drug, "dex" )
    fLims = [ 0.5 30 ];

elseif strcmp( drug, "ket" )
    fLims = [ 0.5 80 ];

else
    fLims = [ 0.5 50 ];

end

switch thisVar
    case { "eeg", "eegZ" }
        ploteegxmouse( mouseId, drug, thisVar )

    case { "emg", "emgRms" }
        plotemgxmouse( mouseId, drug, thisVar )

    case { "spec", "coher" }
        if strcmp( thisVar, "spec" )
            plotspecxmouse( mouseId, drug, fLims )

        else
            plotcoherxmouse( mouseId, drug, fLims )

        end

    otherwise
        error( "Wrong variable name" )

end


%--------------------------------------------------------------------------
% Helper fx to plot by dose
function plotxdose( drug, dose, thisVar )

% Define freq lims
switch drug
    case "dex"
    fLims = [ 0.5 30 ];
    
    case "ket"
    fLims = [ 0.5 80 ];

    otherwise
        fLims = [ 0.5 50 ];

end

% for plotIdx = 1 : nExps
    switch thisVar
        case { "eeg", "eegZ" }
            ploteegxdose( drug, dose, thisVar )

        case { "emg", "emgRms" }
            plotemgxdose( drug, dose, thisVar )

        case { "spec", "coher" }
            if strcmp( thisVar, "spec" )
                plotspecxdose( drug, dose, fLims )

            else
                plotcoherxdose( drug, dose, fLims )

            end

        otherwise
            error( "Wrong variable name" )

    end

% end