clear;
% Arduino Connection
myBoard = arduino('COM4', 'Nano3');  % Initialize Arduino on COM4 with Nano3 board
% Pin for given components 
soilReader = 'A1'; % Pin for moisture sensor
PumpPin = 'D2';    % Pin for controlling the pump
% Thresholds for the soil moisture sensor
reallyDryValue = 3.64;
moistureThreshold = 3;
saturatedValue = 2.75;
% Variables to store and plot
moistureReadings = []; % Store moisture readings
timeStamps = [];       % Store time stamps for x-axis of the plot
iteration = 0;         % Track iterations for time labels
disp("Monitoring Soil Moisture...");
while true
   iteration = iteration + 1;
  
   % Read soil moisture voltage
   soilMoisture = readVoltage(myBoard, soilReader); 
  
   % Log the moisture value for graphing purposes
   moistureReadings = [moistureReadings, soilMoisture];
   timeStamps = [timeStamps, iteration * 3];  % Time increment in seconds
  
   % Display and control the pump based on soil moisture
   Pump(myBoard, PumpPin, soilMoisture, reallyDryValue, moistureThreshold, saturatedValue);
  
   % Plot the soil moisture over time
   graph(timeStamps, moistureReadings);
  
   % Pause for 2 seconds before the next reading
   pause(2);
end
% Function to control the pump
function Pump(myBoard, PumpPin, soilMoisture, reallyDryValue, moistureThreshold, saturatedValue)
   if soilMoisture <= saturatedValue
       disp("Soil is wet.");
       writeDigitalPin(myBoard, PumpPin, 0);  % Turn pump OFF
   elseif soilMoisture <= moistureThreshold
       disp("Soil is wet, but not too wet.");
       writeDigitalPin(myBoard, PumpPin, 1);  % Turn pump ON
   elseif soilMoisture <= reallyDryValue
       disp("Soil is dry.");
       writeDigitalPin(myBoard, PumpPin, 1);  % Turn pump ON
   else
       disp("Air Being Detected");
       writeDigitalPin(myBoard, PumpPin, 0);  % Turn pump OFF
   end
end
% Function to plot the soil moisture over time
function graph(timeStamps, moistureReadings)
   plot(timeStamps, moistureReadings);
   title('Soil Moisture vs Time');
   xlabel('Time (s)');
   ylabel('Voltage (Volts)');
   grid on;  % Add grid to the plot for better readability
   drawnow;  % Update the plot dynamically
end

