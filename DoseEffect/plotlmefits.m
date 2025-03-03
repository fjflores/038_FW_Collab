function plotlmefits( mdls, feat2plot, varargin )


% Set options default values
ciFlag = false;
col2plot = 'k';
tmp = magma;
cMap = tmp ( 20 : 15 : end, : );

% Parse  name-value pairs
names = lower( varargin( 1 : 2 : end ) );
values = varargin( 2 : 2 : end );
for k = 1 : numel( names )
    switch lower( names{ k } )
        case "color"
            col2plot = values{ k };

        case "plotci"
            ciFlag = values{ k };

        otherwise
            error( '''%s'' is not a valid Name for Name, Value pairs.',...
                names{ k } )

    end

end

% Generate predictor values for plotting
dose = [ 0 : 10 : 150 ]';
mouseId = repmat( "M000", size( dose, 1 ), 1 );
predTab = table( dose, mouseId );

% Get fitted values and residuals
for mdlIdx = 1 : length( mdls )
    % fittedVals = fitted( mdls( mdlIdx ).( feat2plot ),...
    %     "Conditional", false );
    % Compute predicted response and raw confidence intervals
    fittedVals = predict( ...
        mdls( mdlIdx ).( feat2plot ), ...
        predTab, ...
        'Alpha', 0.05, ...
        'Conditional', false );
    % flipFlag = fittedVals( 1 ) > fittedVals( end );
    resi = residuals( ...
        mdls( mdlIdx ).( feat2plot ), ...
        'Conditional', false );

    % Get predicitons for a mock table
    % firstColumn = repmat("M000", 16, 1); % 16 rows of "M000"
    % secondColumn = ( 0: 10: 150 )'; % Column vector
    % mockTab = table(firstColumn, secondColumn, 'VariableNames', { 'mouseId', 'dose' } );
    % predVals = predict( mdls( 1 ).rmsEmg, mockTab )

    hold on;
    if ciFlag
        % Calculate standard errors of the fitted values
        % standardErrors = std( resi ) * sqrt( 1 + ( 1 / length( resi ) ) ); % Adjust as needed
        %
        % % Calculate studentized confidence intervals
        % tValue = tinv( 0.975, mdls( mdlIdx ).( feat2plot ).DFE ); % 95% confidence interval
        % lowerCI = fittedVals - tValue * standardErrors;
        % upperCI = fittedVals + tValue * standardErrors;
        mse = mean( (...
            mdls( mdlIdx ).( feat2plot ).Variables{ :, feat2plot } - ...
            predict( mdls( mdlIdx ).( feat2plot ), 'Conditional', false ) ) .^ 2 );
        dfe = mdls( mdlIdx ).( feat2plot ).DFE;
        [ upperCI, lowerCI ] = getcis( dose, fittedVals, mse, dfe );

        if length( col2plot ) == 1
            fill( ...
                [ dose; flipud( dose ) ], ...
                [ lowerCI; flipud( upperCI ) ],...
                col2plot, ...
                'FaceAlpha', 0.2, ...
                'EdgeColor', 'none' );

        else
            fill( ...
                [ dose; flipud( dose ) ], ...
                [ lowerCI; flipud( upperCI ) ],...
                cMap( mdlIdx, : ), ...
                'FaceAlpha', 0.2, ...
                'EdgeColor', 'none' );

        end

    end

    % Plot the original data and fitted values with confidence intervals.
    if length( col2plot ) == 1
        plot( dose, fittedVals,...
            'LineWidth', 2, 'Color', col2plot );

    else
        plot( dose, fittedVals,...
            'LineWidth', 2, 'Color', cMap( mdlIdx, : ) );

    end

end


% Helper functions
function [ upper, lower ] = getcis( dose, fitted, mse, dfe )

X = [ ones( size( dose ) ) dose ];
[ ~, R ] = qr( X, 0 );
% E = [ ones( size( x ) ), x ] / R;
E = X / R;
alpha = 0.05;
dy = -tinv( alpha / 2, dfe ) * sqrt( sum( E .^ 2, 2 ) * mse );

% Compute fitted line and bounds on this grid
upper = fitted + dy;
lower = fitted - dy;
