model = "PID_control";

%% Configurations

% Define the configurations
configs = {
    struct('kp', 0.2, 'ki', 0, 'kd', 0);
    struct('kp', 0.2, 'ki', 0.2, 'kd', 0);
    struct('kp', 0.2, 'ki', 0.1, 'kd', 0.01);
};

% Initialize cell array to store results
results = cell(length(configs), 1);

% Loop over each configuration
for s = 1:length(configs)
    config = configs{s};
    
    % Create a SimulationInput object
    simIn = Simulink.SimulationInput(model);
    
    % Set variables
    simIn = simIn.setVariable('kp', config.kp);
    simIn = simIn.setVariable('ki', config.ki);
    simIn = simIn.setVariable('kd', config.kd);
    
    % Run the simulation
    simIn = simIn.setModelParameter('StopTime', '60');
    out = sim(simIn);
    
    % Store results
    results{s} = struct(...
        'measured', out.logsout.get('measured').Values, ...
        'reference', out.logsout.get('reference').Values, ...
        'voltage', out.logsout.get('voltage').Values);
end

%% Plot results
figure;
subplot(2,1,1);
hold on;
for s = 1:length(configs)
    label = sprintf('kp = %.2f, ki = %.2f, kd = %.2f', configs{s}.kp, configs{s}.ki, configs{s}.kd);
    plot(results{s}.measured.Time, results{s}.measured.Data, 'LineWidth', 2, 'DisplayName', label);
end
stairs(results{1}.reference.Time, results{1}.reference.Data, '--', 'LineWidth', 2, 'DisplayName', 'Setpoint');
hold off;
grid on;
legend('Location', 'best');
ylabel('Angle (rad)');
title('Angular Position');

subplot(2,1,2);
hold on;
for s = 1:length(configs)
    label = sprintf('kp = %.2f, ki = %.2f, kd = %.2f', configs{s}.kp, configs{s}.ki, configs{s}.kd);
    stairs(results{s}.voltage.Time, results{s}.voltage.Data, 'LineWidth', 2, 'DisplayName', label);
end
hold off;
grid on;
legend('Location', 'best');
ylabel('Voltage (V)');
title('Voltage');