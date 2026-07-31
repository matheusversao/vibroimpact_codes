%% Animation Displacement plots (absolute + relative)
stop_time = 1.5;
frame_skip = 150;

% Combinar dados de todas as etapas já simuladas
T_combined = vertcat(T_all_cell{:});
Y_combined = vertcat(Y_all_cell{:});

% === Relative displacement ===
Y_rel = -(Y_combined(:,3) - Y_combined(:,1));

results_folder = 'results_animations';
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

%% === Figure 1: Absolute Displacements ===
fig_abs = figure('Name', 'Absolute Displacements', 'Color', 'w');
hCladding = plot(T_combined(1), Y_combined(1,1), 'o', 'Color', color_set{1,1}, ...
    'MarkerFaceColor', color_set{1,1}, 'LineWidth', 1.5, 'DisplayName', 'Cladding'); 
hold on;
hPellet1 = plot(T_combined(1), Y_combined(1,3), 'o', 'Color', color_set{1,2}, ...
    'MarkerFaceColor', color_set{1,2}, 'LineWidth', 1.5, 'DisplayName', 'Pellet 1'); 
trailCladding = plot(T_combined(1), Y_combined(1,1), '-', 'Color', color_set{1,1}, 'LineWidth', 1.5);
trailPellet1 = plot(T_combined(1), Y_combined(1,3), '-', 'Color', [color_set{1,2}, 0.5], 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('Cladding', 'Pellet1', 'Location', 'best');
title('Absolute Displacements vs. Time');
grid on;
xlim([min(T_combined) stop_time]);
ylim([min(min([Y_combined(:,[1,3])])) max(max([Y_combined(:,[1,3])]))]);

% Video writer for absolute displacement
video_abs_filename = fullfile(results_folder, 'Displacement_Absolute.mp4');
video_abs = VideoWriter(video_abs_filename, 'MPEG-4');
video_abs.FrameRate = 30;
open(video_abs);

%% === Figure 2: Relative Displacement ===
fig_rel = figure('Name', 'Relative Displacement', 'Color', 'w');
hRel = plot(T_combined(1), Y_rel(1), 'o', 'Color', 'k', 'MarkerFaceColor', 'k', 'DisplayName', 'Pellet1 - Cladding');
hold on;
trailRel = plot(T_combined(1), Y_rel(1), '-', 'Color', [0 0 0 0.5], 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Relative Displacement (m)');
legend('Relative', 'Location', 'best');
title('Relative Displacement vs. Time');
grid on;
xlim([min(T_combined) stop_time]);
ylim([min(Y_rel) max(Y_rel)]);

% Video writer for relative displacement
video_rel_filename = fullfile(results_folder, 'Displacement_Relative.mp4');
video_rel = VideoWriter(video_rel_filename, 'MPEG-4');
video_rel.FrameRate = 30;
open(video_rel);

%% === Animation loop ===
for k = 1:frame_skip:length(T_combined)
    % --- Update absolute displacement ---
    figure(fig_abs);
    set(hCladding, 'XData', T_combined(k), 'YData', Y_combined(k,1));
    set(hPellet1, 'XData', T_combined(k), 'YData', Y_combined(k,3));
    set(trailCladding, 'XData', T_combined(1:k), 'YData', Y_combined(1:k,1));
    set(trailPellet1, 'XData', T_combined(1:k), 'YData', Y_combined(1:k,3));
    title(['Absolute Displacements | T = ', num2str(round(T_combined(k),2)), ' s']);
    drawnow;
    frame_abs = getframe(fig_abs);
    writeVideo(video_abs, frame_abs);

    % --- Update relative displacement ---
    figure(fig_rel);
    set(hRel, 'XData', T_combined(k), 'YData', Y_rel(k));
    set(trailRel, 'XData', T_combined(1:k), 'YData', Y_rel(1:k));
    title(['Relative Displacement | T = ', num2str(round(T_combined(k),2)), ' s']);
    drawnow;
    frame_rel = getframe(fig_rel);
    writeVideo(video_rel, frame_rel);

    % Stop if reached time limit
    if T_combined(k) >= stop_time
        break;
    end
end

close(video_abs);
close(video_rel);
