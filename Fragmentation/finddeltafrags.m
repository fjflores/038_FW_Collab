function frags = finddeltafrags( drug, bandName, modo )
% Plot delta power AUC across all mice for a single dose


root = getrootdir( );
f2load = strcat( bandName, "_Power_", drug );
bandFile = load( fullfile( root, "Results", "Dose-Effect", f2load ) );
PL = bandFile.PL;
% gap = [ 0.005 0.01 ];
% margH = [ 0.1 0.05 ];
% margV = [0.1 0.1];
% opts = { gap, margH, margV };
% yLims = [ 0 50 ];

% colormap magma

nDoses = length( PL );
for doseIdx = 1 : nDoses
    % figure
    thisP = PL( doseIdx );
    
    expList = thisP.expList;
    nExps = length( expList );

    for expIdx = 1 : nExps
        switch modo
            case "total"
                P2analyze = thisP.total;

            case "median"
                P2analyze = thisP.median;

            case "mean"
                P2analyze = thisP.mean;

        end
        
        tP = thisP.ts;
        Psmooth = medfilt1( P2analyze( :, expIdx ), 30 );
        newSignal = stretchsignal( Psmooth );
        dt = mean( diff( tP ) );
        lowIdx = newSignal <= 0.2;
        [ lowDurs{ expIdx }, highDurs{ expIdx } ] = countzerosandones( lowIdx );
        lowTotalDur( expIdx ) = sum( lowIdx ) * dt;
        highTotalDur( expIdx ) = sum( ~lowIdx ) * dt;
        % [ pks{ expIdx }, locs{ expIdx }, w{ expIdx } ] = findpeaks(...
        %     newSignal, tP,...
        %     "MinPeakHeight", 0.2,...
        %     "MinPeakDistance", 0.1 );


        % subplot( nExps, 1, expIdx )
        
        % plot( tP, newSignal )
        % hold on
        % plot( locs{ expIdx }, pks{ expIdx }, 'vr' )
        % box off

        % disprog( expIdx, nExps, 10 )

    end
    
    frags( doseIdx ).lowDurs = lowDurs;
    frags( doseIdx ).highDurs = highDurs; 
    frags( doseIdx ).lowTotalDur = lowTotalDur;
    frags( doseIdx ).highTotalDur = highTotalDur;
    frags( doseIdx ).dose = thisP.dose;
    frags( doseIdx ).dt = dt;

end

end

function newSignal = stretchsignal( signal )
% Stretch the input signal to the range [0, 1]
vals = prctile( signal, [ 1 99 ] );
% minVal = min(signal);
% maxVal = max(signal);

% Normalize the signal
newSignal = (signal - vals( 1 ) ) / ( vals( 2 ) - vals( 1 ) );

end
