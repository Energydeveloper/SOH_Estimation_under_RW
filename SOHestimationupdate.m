% Close all previous figures and clear workspace
close all;
clear;

% Load your dataset
load('data/Matlab/RW9.mat');  % Adjust the path if needed

% Initialize arrays for storing data
features = [];
capacities = [];
timeStamps = [];

% Process each step to calculate capacities and extract features
for i = 1:length(data.step)
    if strcmp(data.step(i).comment, 'reference discharge')
        current = data.step(i).current;
        voltage = data.step(i).voltage;
        temperature = data.step(i).temperature;
        relativeTime = data.step(i).relativeTime;

        % Calculate capacity (Ah) by integrating current over time
        if length(current) == length(relativeTime) && ~isempty(current)
            capacity = trapz(relativeTime, current) / 3600; % Convert to Ah
            capacities = [capacities; capacity];
            
            % Store timestamp
            dateTime = datetime(data.step(i).date, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
            timeStamps = [timeStamps; dateTime];

            % Extract features
            avgCurrent = mean(current);
            peakCurrent = max(current);
            avgVoltage = mean(voltage);
            minVoltage = min(voltage);
            avgTemperature = mean(temperature);
            featureArray = [avgCurrent, peakCurrent, avgVoltage, minVoltage, avgTemperature];
            features = [features; featureArray];
        end
    end
end

% Normalize features for better model performance
features = normalize(features);

% Train SVM Regression Model
svmMdl = fitrsvm(features, capacities, 'Standardize', true, 'KernelFunction', 'gaussian');

% Train Lasso Linear Regression Model
lassoMdl = fitrlinear(features, capacities, 'Learner', 'leastsquares', 'Regularization', 'lasso');

% Train Ridge Linear Regression Model
ridgeMdl = fitrlinear(features, capacities, 'Learner', 'leastsquares', 'Regularization', 'ridge');

% Train Gaussian Process Regression Model last as requested
gprMdl = fitrgp(features, capacities, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');

% Predict capacities using the models
YPred_SVM = predict(svmMdl, features);
YPred_Lasso = predict(lassoMdl, features);
YPred_Ridge = predict(ridgeMdl, features);
YPred_GP = predict(gprMdl, features);

% Calculate initial capacity for SoH calculation
initialCapacity = max(capacities);

% Calculate State of Health
SoH = (capacities / initialCapacity) * 100;
predictedSoH_SVM = (YPred_SVM / initialCapacity) * 100;
predictedSoH_Lasso = (YPred_Lasso / initialCapacity) * 100;
predictedSoH_Ridge = (YPred_Ridge / initialCapacity) * 100;
predictedSoH_GP = (YPred_GP / initialCapacity) * 100;

% Compute and display regression metrics for each method
models = {'SVM', 'Lasso', 'Ridge', 'GP'};
predictions = {YPred_SVM, YPred_Lasso, YPred_Ridge, YPred_GP};
for idx = 1:length(models)
    pred = predictions{idx};
    MAE = mean(abs(capacities - pred));
    RMSE = sqrt(mean((capacities - pred).^2));
    MPE = mean((capacities - pred) ./ capacities) * 100;
    MAPE = mean(abs((capacities - pred) ./ capacities)) * 100;
    R2 = 1 - sum((capacities - pred).^2) / sum((capacities - mean(capacities)).^2);
    fprintf('%s Metrics - MAE: %.3f Ah, RMSE: %.3f Ah, MPE: %.3f %%, MAPE: %.3f %%, R2: %.3f\n', models{idx}, MAE, RMSE, MPE, MAPE, R2);
end

% Plotting capacity predictions
figure('Position', [100, 100, 1200, 800], 'PaperPositionMode', 'auto');
hold on;
plot(timeStamps, capacities, 'k-', 'LineWidth', 4, 'DisplayName', 'Measured Capacities');
plot(timeStamps, YPred_GP, 'r--', 'LineWidth', 3, 'DisplayName', 'GP Predictions');
plot(timeStamps, YPred_SVM, 'b--', 'LineWidth', 3, 'DisplayName', 'SVM Predictions');
plot(timeStamps, YPred_Lasso, 'g--', 'LineWidth', 3, 'DisplayName', 'Lasso Predictions');
plot(timeStamps, YPred_Ridge, 'm--', 'LineWidth', 3, 'DisplayName', 'Ridge Predictions');
datetick('x', 'yyyy-mm-dd', 'keeplimits');
xlim([min(timeStamps) max(timeStamps)]);
xlabel('Date', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('Capacity (Ah)', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
title('Capacity Prediction', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
legend('FontName', 'Times New Roman', 'FontSize', 20);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
set(gca, 'YTickLabel', get(gca, 'YTickLabel'), 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
grid on;
hold off;
print('fig1', '-dpdf', '-fillpage');

% Plotting State of Health
figure('Position', [100, 100, 1200, 800], 'PaperPositionMode', 'auto');
hold on;
plot(timeStamps, SoH, 'k-', 'LineWidth', 4, 'DisplayName', 'Measured SoH');
plot(timeStamps, predictedSoH_SVM, 'b--', 'LineWidth', 3, 'DisplayName', 'Predicted SoH (SVM)');
plot(timeStamps, predictedSoH_Lasso, 'g--', 'LineWidth', 3, 'DisplayName', 'Predicted SoH (Lasso)');
plot(timeStamps, predictedSoH_Ridge, 'm--', 'LineWidth', 3, 'DisplayName', 'Predicted SoH (Ridge)');
plot(timeStamps, predictedSoH_GP, 'r--', 'LineWidth', 3, 'DisplayName', 'Predicted SoH (GP)');
datetick('x', 'yyyy-mm-dd', 'keeplimits');
xlim([min(timeStamps) max(timeStamps)]);
xlabel('Date', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
ylabel('State of Health (%)', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
title('State of Health Prediction', 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
legend('FontName', 'Times New Roman', 'FontSize', 20);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
set(gca, 'XTickLabel', get(gca, 'XTickLabel'), 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
set(gca, 'YTickLabel', get(gca, 'YTickLabel'), 'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
grid on;
hold off;
print('fig2', '-dpdf', '-fillpage');
