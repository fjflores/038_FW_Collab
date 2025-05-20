% Visual comparison: constant phi vs variable phi
clear; clc; close all;
rng(42);

n = 500;
X = [ones(n,1), linspace(-2, 2, n)']; % One predictor X in [-2, 2]
Z = X; % Same predictor used for phi model

% True parameters
true_beta = [0; 2];       % mean increases with X
true_gamma = [1; -2];      % precision DECREASES with X (variance increases)

% Generate data
mu = 1 ./ (1 + exp(-X * true_beta));
phi = exp(Z * true_gamma);

a = mu .* phi;
b = (1 - mu) .* phi;
y = betarnd(a, b);

% Clip if needed
y = max(min(y, 1-1e-6), 1e-6);

% --- 1. Fit simple Beta regression (constant phi)
[beta_simple, phi_simple] = beta_regression(X, y);

mu_simple = 1 ./ (1 + exp(-X * beta_simple));
phi_simple_val = phi_simple * ones(size(y)); % constant phi

% --- 2. Fit variable-phi Beta regression
[beta_var, gamma_var] = beta_regression_variable_phi(X, Z, y);

mu_var = 1 ./ (1 + exp(-X * beta_var));
phi_var = exp(Z * gamma_var);

% --- 3. Plot

figure;

% Top plot: Observations and fitted means
subplot(2,1,1);
scatter(X(:,2), y, 10, 'b', 'filled', 'MarkerFaceAlpha', 0.3);
hold on;
plot(X(:,2), mu, 'k-', 'LineWidth', 2, 'DisplayName', 'True \mu');
plot(X(:,2), mu_simple, 'r--', 'LineWidth', 2, 'DisplayName', 'Simple model');
plot(X(:,2), mu_var, 'g-', 'LineWidth', 2, 'DisplayName', 'Variable-phi model');
xlabel('Predictor X');
ylabel('y');
legend('Data','True \mu','Simple \mu','Variable-phi \mu','Location','northwest');
title('Beta Regression: Mean Prediction');
grid on;

% Bottom plot: Fitted precision (phi)
subplot(2,1,2);
plot(X(:,2), phi, 'k-', 'LineWidth', 2, 'DisplayName', 'True \phi');
hold on;
yline(phi_simple, 'r--', 'LineWidth', 2, 'DisplayName', 'Simple model \phi');
plot(X(:,2), phi_var, 'g-', 'LineWidth', 2, 'DisplayName', 'Variable-phi \phi');
xlabel('Predictor X');
ylabel('Precision \phi');
legend('Location','northwest');
title('Beta Regression: Precision (phi)');
grid on;

sgtitle('Beta Regression: Constant vs Variable Precision');



function [beta_est, phi_est] = beta_regression(X, y)

    % X: n x p design matrix
    % y: n x 1 response vector (bounded between 0 and 1)

    % Initialize
    [n, p] = size(X);
    init_params = [zeros(p,1); log(2)]; % beta and log(phi)

    % Negative log-likelihood
    negloglik = @(params) negloglik_beta(params, X, y);

    % Optimization
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'iter');
    est_params = fminunc(negloglik, init_params, options);

    beta_est = est_params(1:p);
    phi_est = exp(est_params(p+1)); % precision parameter (positive)

end

function nll = negloglik_beta(params, X, y)
    beta = params(1:end-1);
    log_phi = params(end);
    phi = exp(log_phi);

    mu = 1 ./ (1 + exp(-X*beta)); % inverse logit

    a = mu * phi;
    b = (1 - mu) * phi;

    % Avoid issues at boundaries
    y = max(min(y, 1-1e-6), 1e-6);

    ll = gammaln(a + b) - gammaln(a) - gammaln(b) + ...
         (a - 1) .* log(y) + (b - 1) .* log(1 - y);

    nll = -sum(ll); % negative log-likelihood
end

function [beta_est, gamma_est] = beta_regression_variable_phi(X, Z, y)

    % X: n x p1 design matrix for mean
    % Z: n x p2 design matrix for precision
    % y: n x 1 response vector (in (0,1))

    [n, p1] = size(X);
    [~, p2] = size(Z);

    init_params = [zeros(p1,1); zeros(p2,1)]; % init beta and gamma

    % Negative log-likelihood
    negloglik = @(params) negloglik_beta_variable_phi(params, X, Z, y);

    % Optimization
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'iter');
    est_params = fminunc(negloglik, init_params, options);

    beta_est = est_params(1:p1);
    gamma_est = est_params(p1+1:end);

end

function nll = negloglik_beta_variable_phi(params, X, Z, y)
    p1 = size(X,2);
    beta = params(1:p1);
    gamma = params(p1+1:end);

    mu = 1 ./ (1 + exp(-X*beta)); % mean model (logit link)
    phi = exp(Z*gamma);           % precision model (log link)

    a = mu .* phi;
    b = (1 - mu) .* phi;

    % Clip to avoid boundary problems
    y = max(min(y, 1-1e-6), 1e-6);

    ll = gammaln(a + b) - gammaln(a) - gammaln(b) + ...
         (a - 1) .* log(y) + (b - 1) .* log(1 - y);

    nll = -sum(ll); % negative log-likelihood
end

