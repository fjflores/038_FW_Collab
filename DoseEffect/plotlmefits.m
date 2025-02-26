function plotlmefits( mdls, feat2plot )

% map = sky;
% colors = map( 20 : 20 : end, : );

% Get fitted values and residuals
for mdlIdx = 1 : length( mdls )
    fittedValues = fitted( mdls( mdlIdx ).( feat2plot ),...
        "Conditional", false );
    flipFlag = fittedValues( 1 ) > fittedValues( end );
    resi = residuals( mdls( mdlIdx ).rmsEmg );

    % Get predicitons for a mock table
    % firstColumn = repmat("M000", 16, 1); % 16 rows of "M000"
    % secondColumn = ( 0: 10: 150 )'; % Column vector
    % mockTab = table(firstColumn, secondColumn, 'VariableNames', { 'mouseId', 'dose' } );
    % predVals = predict( mdls( 1 ).rmsEmg, mockTab )


    % Calculate standard errors of the fitted values
    standardErrors = std( resi ) * sqrt( 1 + ( 1 / length( resi ) ) ); % Adjust as needed

    % Calculate studentized confidence intervals
    tValue = tinv( 0.975, mdls( 1 ).rmsEmg.DFE ); % 95% confidence interval
    lowerCI = unique( fittedValues - tValue * standardErrors );
    upperCI = unique( fittedValues + tValue * standardErrors );

    % Plot the original data and fitted values with confidence intervals
    % figure;
    hold on;
    % colororder( sky )
    % nanIdx = isnan( timeFeats( 1 ).featTab.rmsEmg );
    dMat = mdls( mdlIdx ).( feat2plot ).designMatrix;
    pred = unique( dMat( :, 2 ) );
    resp = unique( fittedValues );
    if flipFlag
        resp = flipud( resp );

    end
    % scatter( pred, resp, 'filled', 'MarkerFaceColor', [ 0.8, 0.8, 0.8 ] );
    % scatter( timeFeats( 1 ).featTab.dose, timeFeats( 1 ).featTab.rmsEmg,...
    %     'filled', 'MarkerFaceColor', [ 0.8, 0.8, 0.8 ] )
    % plot( pred, resp, 'LineWidth', 2, "Color", colors( mdlIdx, : ) );
    plot( pred, resp, 'LineWidth', 2, "Color", 'k' );
    % fill( [pred; flipud( pred )], [ lowerCI; flipud( upperCI ) ],...
    %     colors( mdlIdx, : ), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    % hold off;
    % xlim( [ -10 160 ] )

    % Add labels and title
    % xlabel('Dose (ug/kg)');
    % ylabel( feat2plot );
    % title('Model Fit');
    % legend('Original Data', 'Fitted Values', 'Confidence Intervals');
    % grid on;

end
