%% WPT Analysis: Gain, Power, Efficiency, and Smith Chart (System Match)
clear; clc;

% --- 1. Parameters ---
f0 = 6.78e6; 
Lp = 10e-6; Ls = 10e-6;
Rp = 0.5; Rs = 0.5; RL = 50;
Vin = 10; Z0 = 50; % Reference Impedance
Cp = 1/( (2*pi*f0)^2 * Lp ); Cs = 1/( (2*pi*f0)^2 * Ls );

% --- 2. Coupling Values ---
k_crit = 0.0118;  % Perfect match between coils only
k_bif = 0.075;    % The flat-top bifurcation threshold
k_match = 0.117;  % The PERFECT 50-Ohm System Match
k_over = 0.20;    % Deep splitting regime

k_sweep = [k_crit, k_bif, k_match, k_over];
colors = {'b', 'm', 'g', 'r'}; 
labels = {'Coil Critical (k=0.011)', 'Bifurcation (k=0.075)', 'System Match (k=0.117)', 'Over-coupled (k=0.20)'};

f = linspace(6e6, 7.5e6, 1000); 
w = 2*pi*f;

% Setup Figure 1: Characteristics
fig1 = figure('Color', 'w', 'Position', [50 100 600 800], 'Name', 'WPT Characteristics');

% Pre-allocate a matrix to hold all Gamma data for the Smith Chart
Gamma_all = zeros(length(w), length(k_sweep));

% --- 3. Calculation Loop ---
for i = 1:length(k_sweep)
    k = k_sweep(i);
    M = k * sqrt(Lp * Ls);
    Gain = zeros(size(w)); P_load = zeros(size(w)); Eff = zeros(size(w));
    Gamma = zeros(size(w)); 
    
    for j = 1:length(w)
        % Impedance calculations
        Zp = Rp + 1j*w(j)*Lp + 1/(1j*w(j)*Cp);
        Zs = (Rs + RL) + 1j*w(j)*Ls + 1/(1j*w(j)*Cs);
        Zm = 1j*w(j)*M;
        
        detZ = Zp*Zs - Zm^2;
        Ip = (Vin * Zs) / detZ;
        Is = (Vin * Zm) / detZ;
        
        % Core Data
        Gain(j) = abs(Is * RL) / Vin;
        P_out = (abs(Is)^2 * RL) / 2;
        P_in = real(Vin * conj(Ip)) / 2;
        P_load(j) = P_out;
        Eff(j) = (P_out / P_in) * 100;
        
        % Calculate Reflection Coefficient
        Z_in = Vin / Ip;
        Gamma(j) = (Z_in - Z0) / (Z_in + Z0);
    end
    
    % Store this loop's Gamma as a column in our master matrix
    Gamma_all(:, i) = Gamma.'; 
    
    % Plot 2D Data to Figure 1
    figure(fig1);
    subplot(3,1,1); hold on; plot(f/1e6, Gain, colors{i}, 'LineWidth', 2); ylabel('Gain'); grid on;
    subplot(3,1,2); hold on; plot(f/1e6, P_load, colors{i}, 'LineWidth', 2); ylabel('Power (W)'); grid on;
    subplot(3,1,3); hold on; plot(f/1e6, Eff, colors{i}, 'LineWidth', 2); ylabel('Eff (%)'); grid on;
end

% Final Formatting for Figure 1
figure(fig1); subplot(3,1,3); xlabel('Frequency (MHz)');
legend(labels, 'Location', 'southoutside', 'Orientation', 'horizontal');

% --- 4. Render the Smith Chart ---
% We pass the entire Gamma_all matrix to smithplot at once
fig2 = figure('Color', 'w', 'Position', [700 100 600 600], 'Name', 'Impedance Trajectory');
s_chart = smithplot(f, Gamma_all, 'LineWidth', 1.5);
figure(fig2);
title('WPT Impedance Trajectory (Z_0 = 50 \Omega)');
legend(labels, 'Location', 'northeast');