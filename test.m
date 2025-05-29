% Simple spinning wheel in MATLAB command window
spinner = ['-', '\', '|', '/'];
numCycles = 20;  % Number of times to spin
for i = 1:numCycles
    idx = mod(i-1, length(spinner)) + 1;
    fprintf('\b%s', spinner(idx)); % \b erases previous character
    pause(0.1); % Adjust the speed as needed
end
fprintf('\b'); % Clean up spinner at the end