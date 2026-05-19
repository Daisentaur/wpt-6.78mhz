%% WPT Simulation at 6.78 MHz (ISM Band)
clear; clc;

% --- 1. Parameters ---
f0 = 6.78e6;             % Resonant Frequency (Hz)
w0 = 2*pi*f0;            % Angular frequency
Lp = 10e-6;              % Primary Inductance (10 uH)
Ls = 10e-6;              % Secondary Inductance (10 uH)
Rp = 0.5;                % Primary ESR (Ohms)
Rs = 0.5;                % Secondary ESR (Ohms)
RL = 50;                 % Load Resistance (Ohms)
k = 0.075;                % Coupling Coefficient
M = k * sqrt(Lp * Ls);   % Mutual Inductance

% --- 2. Compensation (Series-Series) ---
Cp = 1 / (w0^2 * Lp);    % Primary Cap
Cs = 1 / (w0^2 * Ls);    % Secondary Cap

% --- 3. Frequency Sweep ---
f = linspace(5e6, 8e6, 1000); % Sweep around 6.78 MHz
w = 2*pi*f;
Vin = 10;                % Input Voltage (V)

% Pre-allocate arrays
Eff = zeros(size(f));
Gain = zeros(size(f));
Phase = zeros(size(f));

% --- 4. Simulation Loop ---
for i = 1:length(w)
    Zp = Rp + 1j*w(i)*Lp + 1/(1j*w(i)*Cp);
    Zs = (Rs + RL) + 1j*w(i)*Ls + 1/(1j*w(i)*Cs);
    Zm = 1j*w(i)*M;
    
    % Solving the Mesh Equations: V = Z * I
    % [Vin; 0] = [Zp, -Zm; -Zm, Zs] * [Ip; Is]
    Z_matrix = [Zp, -Zm; -Zm, Zs];
    I = Z_matrix \ [Vin; 0];
    Ip = I(1); Is = I(2);
    
    % Calculations
    Pout = abs(Is)^2 * RL;
    Pin = real(Vin * conj(Ip));
    Eff(i) = (Pout / Pin) * 100;
    Gain(i) = abs(Is * RL) / Vin;
    Phase(i) = angle(Zp + (w(i)^2 * M^2)/Zs) * (180/pi);
end

% --- 5. Plotting ---
figure;
subplot(3,1,1); plot(f/1e6, Eff, 'r', 'LineWidth', 1.5); ylabel('Efficiency (%)'); grid on;
title('WPT System Performance at 6.78 MHz');
subplot(3,1,2); plot(f/1e6, Gain, 'b', 'LineWidth', 1.5); ylabel('Voltage Gain'); grid on;
subplot(3,1,3); plot(f/1e6, Phase, 'g', 'LineWidth', 1.5); ylabel('Phase (deg)'); xlabel('Frequency (MHz)'); grid on;