%% WPT Spatial EM: Lateral and Angular Misalignment (Symmetrical Coils)
clear; clc;

% --- 1. Coil Parameters (Symmetrical) ---
R = 0.05;          % Radius of both coils (5 cm)
a = 0.001;         % Wire thickness (1 mm)
z_gap = 0.05;      % Vertical gap distance (5 cm)
mu0 = 4*pi*1e-7;   % Permeability of free space

% Self Inductance of a circular loop: L = mu0 * R * (ln(8R/a) - 2)
L_self = mu0 * R * (log(8*R/a) - 2);

% Integration parameters for Neumann's formula
N_points = 100; 
phi = linspace(0, 2*pi, N_points);
dphi = phi(2) - phi(1);
[P1, P2] = meshgrid(phi, phi);

% Tx Coil Vectors (Base)
x1 = R * cos(P1);  y1 = R * sin(P1);
dl1x = -R * sin(P1); dl1y = R * cos(P1);

% --- 2. Lateral Misalignment Sweep ---
x_sweep = linspace(0, 0.15, 100); % Offset from 0 to 15 cm
k_lateral = zeros(size(x_sweep));

for i = 1:length(x_sweep)
    dx = x_sweep(i);
    
    % Rx Coil Position (Translated by dx)
    x2 = R * cos(P2) + dx;
    y2 = R * sin(P2);
    z2 = z_gap;
    
    dl2x = -R * sin(P2); dl2y = R * cos(P2);
    
    % Distance between every point pair
    dist = sqrt((x1-x2).^2 + (y1-y2).^2 + z2^2);
    
    % Dot product of differential elements (dl1 . dl2)
    dot_dl = dl1x.*dl2x + dl1y.*dl2y;
    
    % Neumann Integral for M
    M = (mu0/(4*pi)) * sum(sum((dot_dl ./ dist) * dphi^2));
    k_lateral(i) = M / L_self; % Since Lp = Ls = L_self
end

% --- 3. Angular Misalignment Sweep ---
theta_sweep = linspace(0, 90, 100); % Tilt from 0 to 90 degrees
k_angular = zeros(size(theta_sweep));

for i = 1:length(theta_sweep)
    theta = deg2rad(theta_sweep(i));
    
    % Rx Coil Position (Rotated around Y-axis by theta)
    x2 = R * cos(P2) * cos(theta);
    y2 = R * sin(P2);
    z2 = -R * cos(P2) * sin(theta) + z_gap;
    
    dl2x = -R * sin(P2) * cos(theta);
    dl2y = R * cos(P2);
    dl2z = R * sin(P2) * sin(theta);
    
    dist = sqrt((x1-x2).^2 + (y1-y2).^2 + z2.^2);
    
    % Dot product (dl1 . dl2) Note: dl1z is 0
    dot_dl = dl1x.*dl2x + dl1y.*dl2y;
    
    M = (mu0/(4*pi)) * sum(sum((dot_dl ./ dist) * dphi^2));
    k_angular(i) = M / L_self;
end

% --- 4. Plotting the Results ---
fig = figure('Color', 'w', 'Position', [100 100 900 400], 'Name', 'Spatial Misalignment');

% Lateral Plot
subplot(1,2,1); hold on; grid on;
plot(x_sweep * 100, k_lateral, 'b', 'LineWidth', 2.5);
yline(0, 'k--', 'LineWidth', 1);
title('Lateral Misalignment (\Delta X)');
xlabel('Horizontal Offset (cm)'); ylabel('Coupling Coefficient (k)');
set(gca, 'FontSize', 11);

% Annotate the Null Point
null_idx = find(k_lateral < 0, 1);
if ~isempty(null_idx)
    plot(x_sweep(null_idx)*100, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    text(x_sweep(null_idx)*100 + 0.5, 0.02, 'Flux Null Point (\Phi = 0)', 'Color', 'r', 'FontWeight', 'bold');
end

% Angular Plot
subplot(1,2,2); hold on; grid on;
plot(theta_sweep, k_angular, 'r', 'LineWidth', 2.5);
title('Angular Misalignment (\theta)');
xlabel('Tilt Angle (Degrees)'); ylabel('Coupling Coefficient (k)');
set(gca, 'FontSize', 11);