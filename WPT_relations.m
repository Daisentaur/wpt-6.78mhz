%% WPT Spatial EM: Distance and Turns vs. Coupling
clear; clc;

% --- Parameters ---
r = 0.05; % Coil radius (5 cm)
mu0 = 4*pi*1e-7;

% ==========================================
% GRAPH 1: Distance (z) vs. k
% ==========================================
z_dist = linspace(0.001, 0.15, 100); % Distance from 1mm to 15cm
k_dist = zeros(size(z_dist));

% Using the simplified filamentary coaxial coil approximation
for i = 1:length(z_dist)
    z = z_dist(i);
    % Geometric approximation of k for identical circular coils
    k_dist(i) = (r^3) / ((r^2 + z^2)^(1.5));
end

fig = figure('Color', 'w', 'Position', [100 100 900 450], 'Name', 'Spatial EM Analysis');

subplot(1,2,1); hold on;
plot(z_dist * 100, k_dist, 'b', 'LineWidth', 3);
yline(0.0118, '--k', 'Critical Coupling (k=0.0118)'); % Your specific target
yline(0.075, '--m', 'Bifurcation Target (k=0.075)');

title('Near-Field Decay: Distance vs. k');
xlabel('Axial Distance (cm)'); ylabel('Coupling Coefficient (k)');
grid on; set(gca, 'FontSize', 11);
% Add an annotation to show the 1/d^3 relationship
text(8, 0.4, 'Decay \propto 1/z^3', 'FontSize', 12, 'Color', 'r', 'FontWeight', 'bold');

% ==========================================
% GRAPH 2: Number of Turns (N) vs. k (The EM Flex)
% ==========================================
N_turns = linspace(1, 20, 20); % Sweeping from 1 to 20 turns
z_fixed = 0.03; % Fixed at 3cm distance

% Base geometric factor at this distance
geom_factor = (r^3) / ((r^2 + z_fixed^2)^(1.5));

% Preallocate
k_turns = zeros(size(N_turns));
L_turns = zeros(size(N_turns));
M_turns = zeros(size(N_turns));

for i = 1:length(N_turns)
    N = N_turns(i);

    % Simplified inductance proportional to N^2
    L_base = 1e-6; % Let's say a 1-turn loop is 1uH
    L_turns(i) = L_base * N^2; 

    % Mutual inductance proportional to N1*N2
    M_turns(i) = geom_factor * L_base * (N * N);

    % Calculate k
    k_turns(i) = M_turns(i) / sqrt(L_turns(i) * L_turns(i));
end

subplot(1,2,2);
yyaxis left; % Left axis for k
plot(N_turns, k_turns, 'g', 'LineWidth', 3);
ylabel('Coupling Coefficient (k)', 'Color', 'g');
ylim([0 1]);
set(gca, 'YColor', 'g');

yyaxis right; % Right axis for Inductances
plot(N_turns, L_turns*1e6, '--b', 'LineWidth', 2); hold on;
plot(N_turns, M_turns*1e6, ':r', 'LineWidth', 2);
ylabel('Inductance (\muH)');
set(gca, 'YColor', 'k');

title('The Geometric Ratio: Turns (N) vs. k');
xlabel('Number of Turns (N)'); 
grid on; set(gca, 'FontSize', 11);
legend('Coupling (k)', 'Self Inductance (L \propto N^2)', 'Mutual Inductance (M \propto N^2)', 'Location', 'northwest');