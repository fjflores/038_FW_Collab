% Sample data
x = [0, 1, 2, 3, 4, 5]; % Substrate concentration
y = [0, 0.5, 1.5, 2.5, 3.5, 4.5]; % Reaction rate

% Define the Michaelis-Menten model
mmModel = fittype('Vmax*x/(Km+x)', 'independent', 'x', 'dependent', 'y');

% Fit the model to the data
fitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
                        'StartPoint', [5, 1]); % Initial guess for [Vmax, Km]
[fitResult, gof] = fit(x', y', mmModel, fitOptions);

% Display the fit results
disp(fitResult);

% Plot the data and the fit
plot(fitResult, x, y);
xlabel('Substrate Concentration');
ylabel('Reaction Rate');
title('Michaelis-Menten Fit');

%%

% Sample data for reverse Michaelis-Menten
x = [0, 1, 2, 3, 4, 5]; % Substrate concentration
y = [5, 4.5, 4, 3.5, 3, 2.5]; % Reaction rate (reverse)

% Define the reverse Michaelis-Menten model
reverseMmModel = fittype('Vmax*Km/(Km+x)', 'independent', 'x', 'dependent', 'y');

% Fit the model to the data
fitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
                        'StartPoint', [5, 1]); % Initial guess for [Vmax, Km]
[fitResult, gof] = fit(x', y', reverseMmModel, fitOptions);

% Display the fit results
disp(fitResult);

% Plot the data and the fit
plot(fitResult, x, y);
xlabel('Substrate Concentration');
ylabel('Reaction Rate');
title('Reverse Michaelis-Menten Fit');

%%
 % Sample data
x = [0, 1, 2, 3, 4, 5]; % Substrate concentration
y = [-0, -0.5, -1.5, -2.5, -3.5, -4.5]; % Mirrored reaction rate

% Define the mirrored Michaelis-Menten model
mirroredMmModel = fittype('-Vmax*x/(Km+x)', 'independent', 'x', 'dependent', 'y');

% Fit the model to the data
fitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
                        'StartPoint', [5, 1]); % Initial guess for [Vmax, Km]
[fitResult, gof] = fit(x', y', mirroredMmModel, fitOptions);

% Display the fit results
disp(fitResult);

% Plot the data and the fit
plot(fitResult, x, y);
xlabel('Substrate Concentration');
ylabel('Mirrored Reaction Rate');
title('Mirrored Michaelis-Menten Fit');

%% Sigmoid fit
% Sample data
clear all
clc
frags = finddeltafrags( "dex", "delta", "total" );

% Process frags per dose
figure
loCol = [ 217,95,2 ] / 255;
hiCol = [ 27,158,119 ] / 255;
offset = 0;
x = [];
y = [];
for i = 1 : length( frags )
    rats{ :, i } = frags( i ).lowTotalDur ./ frags( i ).highTotalDur;
    doses( i ) = frags( i ).dose;
    scatter( doses( i ) + offset, rats{ i },...
        50, 'filled', 'MarkerFaceColor', hiCol, 'MarkerFaceAlpha', 0.6 );

        % "MarkerAlpha", 0.6 )
        % scatter( doses( i ), rats{ :, i }, 50, 'filled', 'MarkerFaceColor', [ 27,158,119 ] / 255, ...
        % "MarkerFaceAlpha", 0.6 )
    hold on
    
    lowDurs = frags( i ).lowDurs;
    nDurs = length( lowDurs );
    for j = 1 : nDurs
        yTmp = lowDurs{ j };
        y = vertcat( y, yTmp );

    end
    
    nDurs = length( yTmp );
    x = vertcat( x, frags( i ).dose * ones( nDurs, 1 ) );

end
box off
xlim( [ 8 170 ] )
ylim( [ 0.02 10 ] )
hAx = gca;
set( hAx, "XTick", doses )
set( hAx, "XScale", "log", "YScale", "log" )
xlabel( sprintf( "Dex dose (%cg/kg)", 956 ) )
ylabel( "Ratio (\delta_L/\delta_H )" )

% x = [0, 1, 2, 3, 4, 5]; % Independent variable
% y = [0, 0.1, 0.5, 0.8, 0.9, 1]; % Dependent variable (sigmoid data)

% Define the sigmoid model
sigmoidModel = fittype('L/(1 + exp(-k*(x - x0)))', 'independent', 'x', 'dependent', 'y');

% Fit the model to the data
startPointGPT = [max(y), 1, mean(x)];
fitOptions = fitoptions('Method', 'NonlinearLeastSquares', ...
                        'StartPoint', [1, 1, 2]); % Initial guess for [L, k, x0]
[fitResult, gof] = fit(x', y', sigmoidModel, fitOptions);

% Display the fit results
disp(fitResult);

% Plot the data and the fit
plot(fitResult, x, y);
xlabel('X-axis');
ylabel('Y-axis');
title('Sigmoid Fit using Least-Squares');

% GPT suggestion
% Perform least-squares fitting
sigmoid = @(p, x) p(1) ./ (1 + exp(-p(2) * (x - p(3))));
p0 = [max(y), 1, mean(x)];
opts = optimset('Display', 'off');
p_opt = lsqcurvefit(sigmoid, p0, x, y, [], [], opts);
% Plot the results
figure;
scatter(x, y, 'b', 'filled'); hold on;
plot(x, sigmoid(p_opt, x), 'r', 'LineWidth', 2);
title('Sigmoidal Curve Fitting');
xlabel('x'); ylabel('y');
legend('Data', 'Fitted Curve');
grid on;

%% Wth repeated measure
% Generate some sample data
x = repelem(linspace(-10, 10, 50), 3); % Repeat x values
y = 5 ./ (1 + exp(-1.5 * (x - 2))) + 0.2 * randn(size(x)); % Add noise

% Define the sigmoid function
sigmoid = @(p, x) p(1) ./ (1 + exp(-p(2) * (x - p(3))));

% Initial guesses for parameters [a, b, c]
p0 = [max(y), 1, mean(x)];

% Perform least-squares fitting
opts = optimset('Display', 'off');
p_opt = lsqcurvefit(sigmoid, p0, x, y, [], [], opts);

% Plot the results
figure;
scatter(x, y, 'b', 'filled'); hold on;
plot(unique(x), sigmoid(p_opt, unique(x)), 'r', 'LineWidth', 2);
title('Sigmoidal Curve Fitting');
xlabel('x'); ylabel('y');
legend('Data', 'Fitted Curve');
grid on;
