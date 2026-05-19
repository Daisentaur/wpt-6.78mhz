%% WPT Rectenna Integration: 6.78 MHz AC to DC Rectification
clear; clc;

% --- 1. System Parameters ---
f0 = 6.78e6;                % Operating Frequency (6.78 MHz)
T = 1/f0;                   % Period of one cycle
t = linspace(0, 15*T, 5000); % Simulate 15 RF cycles
dt = t(2) - t(1);

% --- 2. Receiver Coil & Rectifier Specs ---
Vac_pk = 22;                % Peak AC Voltage induced in secondary coil
Vf = 0.45;                  % Forward voltage drop of High-Freq Schottky Diodes
C_out = 2.2e-6;             % Output Smoothing Capacitor (2.2 uF)
R_dc = 10;                  % DC Load Resistance (Represents a charging battery)

% --- Equivalent AC Resistance (For your previous EM slides) ---
Rac_eq = (8 / pi^2) * R_dc; 

% --- 3. Transient Time-Domain Simulation ---
% Initialize arrays
V_ac = Vac_pk * sin(2*pi*f0*t); % The incoming RF wave
V_dc = zeros(size(t));          % The smoothed DC output
I_load = zeros(size(t));        % Current into the battery

% Initial condition (Capacitor is discharged)
V_dc(1) = 0; 
R_source = 0.1; % Small internal resistance of the receiver coil

% Step through time to simulate the Diode Bridge and Capacitor charging
for i = 2:length(t)
    % The full-bridge rectifies the AC wave (absolute value)
    V_rectified_ideal = abs(V_ac(i));
    
    % Diode Conduction Condition: 
    % Are we overcoming the smoothing cap voltage + 2 diode drops?
    if V_rectified_ideal > (V_dc(i-1) + 2*Vf)
        % Diodes are ON: Coil charges the capacitor AND feeds the load
        dV = (V_rectified_ideal - 2*Vf - V_dc(i-1)) / (R_source * C_out) ...
             - V_dc(i-1) / (R_dc * C_out);
        V_dc(i) = V_dc(i-1) + dV * dt;
    else
        % Diodes are OFF: Capacitor discharges into the load
        dV = -V_dc(i-1) / (R_dc * C_out);
        V_dc(i) = V_dc(i-1) + dV * dt;
    end
    
    I_load(i) = V_dc(i) / R_dc;
end

% --- 4. Efficiency & Power Calculations ---
% Wait for steady-state (last 5 cycles) to calculate power
steady_state_idx = floor(length(t) * 0.6):length(t);
Vdc_steady = mean(V_dc(steady_state_idx));
Idc_steady = mean(I_load(steady_state_idx));

P_out_dc = Vdc_steady * Idc_steady;
% AC Input Power approx: P = Vpk^2 / (2 * Rac_eq)
P_in_ac = (Vac_pk^2) / (2 * Rac_eq); 
Rectifier_Eff = (P_out_dc / P_in_ac) * 100;

% --- 5. Plotting the Rectenna Integration ---
fig = figure('Color', 'w', 'Position', [100 100 800 600], 'Name', 'Rectenna Time-Domain Simulation');

% Subplot 1: Voltage Waveforms (AC to DC)
subplot(2,1,1); hold on; grid on;
plot(t*1e6, V_ac, 'Color', [0.7 0.7 0.7], 'LineWidth', 1.5, 'DisplayName', 'Incoming 6.78 MHz AC Wave');
plot(t*1e6, abs(V_ac), '--', 'Color', [0.8 0.5 0.5], 'LineWidth', 1, 'DisplayName', 'Rectified AC (Pre-Smoothing)');
plot(t*1e6, V_dc, 'b', 'LineWidth', 2.5, 'DisplayName', 'Smoothed DC Output Voltage');
yline(Vdc_steady, 'k:', 'LineWidth', 1.5, 'DisplayName', sprintf('Avg DC: %.1f V', Vdc_steady));

title('Rectenna Integration: AC Magnetic Field to DC Battery Power');
xlabel('Time (\mu seconds)'); ylabel('Voltage (V)');
legend('Location', 'northeast');
set(gca, 'FontSize', 11);
ylim([-Vac_pk-5, Vac_pk+5]);

% Subplot 2: Power and Efficiency Metrics
subplot(2,1,2); hold on; grid on;
% Calculate instantaneous ripple
ripple_pk_pk = max(V_dc(steady_state_idx)) - min(V_dc(steady_state_idx));

% Text Display box for System Metrics
dim = [0.2 0.1 0.6 0.3];
str = {
    '=== RECTENNA STEADY-STATE METRICS ===',
    sprintf('AC Input Power: %.2f W', P_in_ac),
    sprintf('DC Output Power: %.2f W', P_out_dc),
    sprintf('DC Ripple Voltage: %.2f V', ripple_pk_pk),
    sprintf('High-Frequency Rectifier Efficiency: %.1f %%', Rectifier_Eff),
    sprintf('Equivalent AC Resistance (R_{ac}): %.2f \\Omega', Rac_eq)
};
annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on', ...
    'BackgroundColor', 'w', 'EdgeColor', 'k', 'FontSize', 12, 'FontName', 'Courier');
axis off;