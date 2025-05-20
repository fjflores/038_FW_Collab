% Example: Synthetic Beta Regression in MATLAB

% 1. Generate synthetic data
rng(1); % for reproducibility
n = 200; % number of samples
X = [ones(n,1), randn(n,1)]; % intercept + one predictor

true_beta = [0.5; 2]; % intercept + slope
true_phi = 10;        % precision

mu = 1 ./ (1 + exp(-X * true_beta)); % logistic link
a = mu * true_phi;
b = (1 - mu) * true_phi;

y = betarnd(a, b); % generate beta-distributed data

% Clip to avoid perfect 0 or 1 (if needed)
y = max(min(y, 1-1e-6), 1e-6);

% 2. Fit Beta regression model
[beta_est, phi_est] = beta_regression(X, y);

% 3. Display results
disp('True coefficients:');
disp(true_beta);
disp('Estimated coefficients:');
disp(beta_est);

disp('True phi:');
disp(true_phi);
disp('Estimated phi:');
disp(phi_est);

% 4. Plot true vs predicted
mu_est = 1 ./ (1 + exp(-X * beta_est)); % fitted mu

figure;
scatter(mu, y, 'b.');
hold on;
plot(mu, mu, 'k--', 'LineWidth', 1.5); % reference line
xlabel('True mean \mu');
ylabel('Observed y');
title('Beta Regression: Observed vs True Mean');
grid on;
legend('Data', 'True \mu','Location','best');

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