close all; clear; clc; tic;  
run('parameters.m');

% Create a struct with the simulation parameters
simulation_params = struct('Mc', Mc, 'Mp1', Mp1, ...
    'C', C, 'K', K, 'Mu_kc', Mu_kc, 'Mu_kp', Mu_kp, 'g', g, ...
    'OMEGA', OMEGA, 'F0', F0, 'e', e, 'Xc0', Xc0, 'Xp10', Xp10, ...
    'Vc0', Vc0, 'Vp10', Vp10, ...
    'ks', ks, 'x', x, 'Fk', Fk, ...
    'H1', H1, 'N', N, ...
    'T_span_all', T_span_all, 'T_step', T_step, 'time_tolerance', time_tolerance, ...
    'Height', Height, 'Width', Width, 'th', th, 'scale_factor', scale_factor);

% Create the .txt file with simulation information
results_folder = 'results';
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end
filename = fullfile(results_folder, 'impact_details.txt');
fileID = create_simulation_info(filename, simulation_params);

% Define the differential equations
ode = @(T, Y) [ Y(2);
    (F0 * sin(OMEGA * T)) - C * Y(2) - K * Y(1) - ((Mu_kc * ((Mc+Mp1) * g) * sign(Y(2)) + (Mu_kp * (Mp1*g + Fk) * sign(Y(2)-Y(4)))) ) / Mc;
    Y(4);
    (Mu_kp * (Mp1*g + Fk) * sign(Y(2)-Y(4))) / Mp1 ];

% Initial conditions
initial_conditions = [Xc0, Vc0, Xp10, Vp10];
%T_span = [T_span_all(1), T_span_all(2)];
T_span = T_span_all(1):T_step:T_span_all(2);

% Plot and simulation control flags
plot_enabled = true;
verbose = false;

% Preallocation
T_all_cell = cell(N+1,1);
Y_all_cell = cell(N+1,1);
V_all_cell = cell(N+1,1);
impact_details = {};
T_impact = zeros(N,1);
delta_xp_all = cell(N,1);

color_set = repmat({[0.3, 0.3 , 0.3], [0.2, 0.8, 0.6], [0.3010, 0.7450, 0.9330], [0, 0.4470, 0.7410], [0.4940, 0.1840, 0.5560], [0.4, 0, 0.4]}, N, 1);

% Pre-plot setup
if plot_enabled
    figure_displacements = figure; hold on; grid on; xlabel('Time (s)'); ylabel('Displacement (m)'); title('Displacement of masses over time');
    figure_displacements_clean = figure; hold on; grid on; xlabel('Time (s)'); ylabel('Displacement (m)'); title('Displacement (no lines of impact)');
    figure_velocities = figure; hold on; grid on; xlabel('Time (s)'); ylabel('Velocity (m/s)'); title('Velocity of masses');
    figure_delta_xp = figure; hold on; grid on; xlabel('Time (s)'); ylabel('\Delta x_{p} (m)'); title('Relative displacement of the Pellets');
end

T_impact_last = 0;
last_impact_time_p1 = -inf;
i = 1;
while i <= N
    [T, Y] = ode45(ode, T_span, initial_conditions);
    V = Y(:, 2:2:end);
    delta_xp1 = -(Y(:, 1) - Y(:, 3));
    indices_p1 = find(delta_xp1 > H1 | delta_xp1 < -H1);
    valid_indices_p1 = indices_p1(T(indices_p1) > last_impact_time_p1 + time_tolerance);
    if isempty(valid_indices_p1)
        T_all_cell{i} = T;
        Y_all_cell{i} = Y;
        V_all_cell{i} = V;
        break;
    end
    impact_index = valid_indices_p1(1);
    T_impact(i) = T(impact_index);
    last_impact_time_p1 = T(impact_index);
    Xc_imp = Y(impact_index, 1);
    Xp_imp = Y(impact_index, 3);
    Vc_imp = Y(impact_index, 2);
    Vp_imp = Y(impact_index, 4);
    Vca_imp = ((Mc - e * Mp1) * Vc_imp + (1 + e) * Mp1 * Vp_imp) / (Mc + Mp1);
    Vpa_imp = ((Mp1 - e * Mc) * Vp_imp + (1 + e) * Mc * Vc_imp) / (Mc + Mp1);
    initial_conditions = [Xc_imp, Vca_imp, Xp_imp, Vpa_imp];
    delta_x_impact = delta_xp1(impact_index);
    impact_side = 'Right wall';
    if delta_x_impact < 0
        impact_side = 'Left wall';
    end
    impact_details{end + 1} = sprintf('Impact Mp1\nTime of impact %d: %.5f\nDelta x: %.5f', i, T_impact(i), delta_x_impact);
    fprintf(fileID, '%d\t%.6f\t%d\t%.6f\t%s\n', i, T_impact(i), 1, delta_x_impact, impact_side);
    T_all_cell{i} = T(1:impact_index);
    Y_all_cell{i} = Y(1:impact_index, :);
    V_all_cell{i} = V(1:impact_index, :);
    delta_xp_all{i} = delta_xp1(1:impact_index);
    if plot_enabled
        figure(figure_displacements);
        plot(T(1:impact_index), Y(1:impact_index,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T(1:impact_index), Y(1:impact_index,3), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        yl = ylim;
        plot([T_impact(i), T_impact(i)], yl, '--', 'Color', [0.6, 0.6, 0.6, 0.7], 'LineWidth', 0.5);
        plot([T_impact_last, T_impact_last], yl, '--', 'Color', [0.6, 0.6, 0.6, 0.7], 'LineWidth', 0.5);
        
        figure(figure_displacements_clean);
        plot(T(1:impact_index), Y(1:impact_index,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T(1:impact_index), Y(1:impact_index,3), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        
        figure(figure_velocities);
        plot(T(1:impact_index), V(1:impact_index,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T(1:impact_index), V(1:impact_index,2), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        
        figure(figure_delta_xp);
        plot(T(1:impact_index), -delta_xp1(1:impact_index), 'Color', color_set{i,2}, 'LineWidth', 1.5);
    end
    T_impact_last = T_impact(i);
    T_span = T_impact(i):T_step:T_span_all(2);
    i = i + 1;
end

% Simulate final segment if needed
if T_impact(i-1) < T_span_all(2)
    [T, Y] = ode45(ode, T_impact(i-1):T_step:T_span_all(2), initial_conditions);
    V = Y(:, 2:2:end);
    T_all_cell{i} = T;
    Y_all_cell{i} = Y;
    V_all_cell{i} = V;
    delta_xp_all{i} = -(Y(:, 1) - Y(:, 3));
    if plot_enabled
        figure(figure_displacements);
        plot(T, Y(:,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T, Y(:,3), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        legend('Cladding', 'Pellet1');
        
        figure(figure_displacements_clean);
        plot(T, Y(:,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T, Y(:,3), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        legend('Cladding', 'Pellet1');
        
        figure(figure_velocities);
        plot(T, V(:,1), 'Color', color_set{i,1}, 'LineWidth', 1.5);
        plot(T, V(:,2), 'Color', color_set{i,2}, 'LineWidth', 1.5);
        legend('Cladding', 'Pellet1');
        
        figure(figure_delta_xp);
        plot(T, -delta_xp_all{i}, 'Color', color_set{i,2}, 'LineWidth', 1.5);
        legend('\Delta x_{p1}');
    end
end

%% Concat results and save
T_all = vertcat(T_all_cell{:});
Y_all = vertcat(Y_all_cell{:});
V_all = vertcat(V_all_cell{:});
save('results/simulation_data.mat', 'T_all', 'Y_all', 'V_all');

%% Finalize the simulation information file
elapsed_time = toc;
finalize_simulation(fileID, elapsed_time);

%% Save 
results_2DOF = 'results'; 
if ~exist(results_2DOF, 'dir')
    mkdir(results_2DOF); 
end

saveas(figure_displacements, fullfile(results_2DOF, 'displacements.png'));
saveas(figure_displacements_clean, fullfile(results_2DOF, 'displacements_clean.png'));
saveas(figure_velocities, fullfile(results_2DOF, 'velocities.png'));
saveas(figure_delta_xp, fullfile(results_2DOF, 'delta_xp.png'));

mat_filename = fullfile(results_2DOF, 'simulation_data.mat');
save(mat_filename, 'T_all', 'Y_all', 'V_all', 'T_impact', 'impact_details', 'T_impact', 'color_set', 'T_all_cell', 'Y_all_cell');
