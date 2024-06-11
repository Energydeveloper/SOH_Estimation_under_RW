%% Load Data
load('data/Matlab/RW9.mat'); % Ensure this path is correct

%% Extract Data
% Accessing the steps from the data struct
steps = data.step;

% Initialize arrays to hold data
numSteps = numel(steps);
voltage = zeros(numSteps, 1);
current = zeros(numSteps, 1);
temperature = zeros(numSteps, 1);
times = NaT(numSteps, 1, 'Format', 'dd-MMM-yyyy HH:mm:ss'); % Adjusted format initialization
types = cell(numSteps, 1);

% Populate arrays
for i = 1:numSteps
    voltage(i) = mean(steps(i).voltage); % Assuming the actual values are vectors and taking the mean
    current(i) = mean(steps(i).current); % Adjust as necessary if your data is different
    temperature(i) = mean(steps(i).temperature);

    % Check if the date string contains time, adjust format accordingly
    if contains(steps(i).date, ':')
        times(i) = datetime(steps(i).date, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss', 'Locale', 'en_US');
    else
        times(i) = datetime(steps(i).date, 'InputFormat', 'dd-MMM-yyyy', 'Locale', 'en_US');
    end
    
    types{i} = steps(i).type;
end

%% Filter data for one specific day - February 1st
selectedDate = datetime('01-Feb-2014', 'Format', 'dd-MMM-yyyy'); % Adjust the year as necessary
dayFilter = (times >= selectedDate) & (times < (selectedDate + days(1)));

% Apply filter
times = times(dayFilter);
voltage = voltage(dayFilter);
current = current(dayFilter);
temperature = temperature(dayFilter);
types = types(dayFilter);

% Distinguish between different types of operations
chargeIdx = strcmp(types, 'C');
dischargeIdx = strcmp(types, 'D');
restIdx = strcmp(types, 'R');

%% Plotting
fontName = 'Times New Roman';
fontSize = 18;

% Voltage Plot
figure;
hold on;
plot(times(chargeIdx), voltage(chargeIdx), 'b-', 'LineWidth', 2, 'DisplayName', 'Charge');
plot(times(dischargeIdx), voltage(dischargeIdx), 'r-', 'LineWidth', 2, 'DisplayName', 'Discharge');
plot(times(restIdx), voltage(restIdx), 'g-', 'LineWidth', 2, 'DisplayName', 'Rest');
legend show;
%title('Voltage over Time on February 1st', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
xlabel('Time', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
grid on;
hold off;

% Current Plot
figure;
hold on;
plot(times(chargeIdx), current(chargeIdx), 'b-', 'LineWidth', 2, 'DisplayName', 'Charge');
plot(times(dischargeIdx), current(dischargeIdx), 'r-', 'LineWidth', 2, 'DisplayName', 'Discharge');
plot(times(restIdx), current(restIdx), 'g-', 'LineWidth', 2, 'DisplayName', 'Rest');
legend show;
%title('Current over Time on February 1st', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
xlabel('Time', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Current (A)', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
grid on;
hold off;

% Temperature Plot
figure;
hold on;
plot(times(chargeIdx), temperature(chargeIdx), 'b-', 'LineWidth', 2, 'DisplayName', 'Charge');
plot(times(dischargeIdx), temperature(dischargeIdx), 'r-', 'LineWidth', 2, 'DisplayName', 'Discharge');
plot(times(restIdx), temperature(restIdx), 'g-', 'LineWidth', 2, 'DisplayName', 'Rest');
legend show;
%title('Temperature over Time on February 1st', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
xlabel('Time', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Temperature (°C)', 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontName', fontName, 'FontSize', fontSize, 'FontWeight', 'bold');
grid on;
hold off;
