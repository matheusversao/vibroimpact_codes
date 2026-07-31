%% Animation Displacement plots
T_combined = [];
Y_combined = [];
stop_time = 1.5;
frame_skip = 150;

num_impacts = min(N, length(T_impact));

% Combine data segments based on the number of impacts
for i = 1:num_impacts
    if i == 1
        T_segment = T_all_cell{i}(T_all_cell{i} <= T_impact(i));
        Y_segment = Y_all_cell{i}(T_all_cell{i} <= T_impact(i), :);
    else
        T_segment = T_all_cell{i}(T_all_cell{i} >= T_impact(i-1) & T_all_cell{i} <= T_impact(i));
        Y_segment = Y_all_cell{i}(T_all_cell{i} >= T_impact(i-1) & T_all_cell{i} <= T_impact(i), :);
    end

    T_combined = [T_combined; T_segment];
    Y_combined = [Y_combined; Y_segment];
end

% Handle the final segment if there's time left after the last impact
if num_impacts > 0
    if T_impact_last < T_span_all(2)
        [T, Y] = ode113(ode, T_impact_last:T_step:T_span_all(2), initial_conditions);

        T_combined = [T_combined; T];
        Y_combined = [Y_combined; Y];
    end
else
    T_combined = T_all_cell{1};
    Y_combined = Y_all_cell{1};
end

% Prepare the figure for combined animation
figure;
hCladding = plot(T_combined(1), Y_combined(1, 1), 'o', 'Color', color_set{1, 1}, 'MarkerFaceColor', color_set{1, 1}, 'LineWidth', 1.5, 'DisplayName', 'Cladding'); 
hold on;
hPellet1 = plot(T_combined(1), Y_combined(1, 3), 'o', 'Color', color_set{1, 2}, 'MarkerFaceColor', color_set{1, 2}, 'LineWidth', 1.5, 'DisplayName', 'Pellet 1'); 
trailCladding = plot(T_combined(1), Y_combined(1, 1), '-', 'Color', color_set{1, 1}, 'LineWidth', 1.5);
trailPellet1 = plot(T_combined(1), Y_combined(1, 3), '-', 'Color', [color_set{1, 2}, 0.5], 'LineWidth', 1.5); 
xlabel('Time (s)');
ylabel('Displacement (m)');
legend('Cladding', 'Pellet1', 'Location', 'southeast');
title('Displacement vs. Time');
grid on;

% Set axis limits for better visualization
xlim([min(T_combined) max(T_combined)]);
ylim([min(min([Y_combined(:, [1, 3])])) max(max([Y_combined(:, [1, 3])]))]);

results_folder = 'results_animations'; 
if ~exist(results_folder, 'dir')
    mkdir(results_folder); 
end

% Set up video writer
video_filename = fullfile(results_folder, 'Displacement_3DOF_System_With_Multiple_Impacts.mp4');
video_displacement = VideoWriter(video_filename, 'MPEG-4');
video_displacement.FrameRate = 30;
open(video_displacement);

% Adjust x-axis limit to stop_time
xlim([min(T_combined) stop_time]); 

% Track impact lines
impact_lines = [];

for k = 1:frame_skip:length(T_combined)
    T_k = T_combined(k);

    % Update the data for the current time step
    set(hCladding, 'XData', T_combined(k), 'YData', Y_combined(k, 1));
    set(hPellet1, 'XData', T_combined(k), 'YData', Y_combined(k, 3));
    set(trailCladding, 'XData', T_combined(1:k), 'YData', Y_combined(1:k, 1));
    set(trailPellet1, 'XData', T_combined(1:k), 'YData', Y_combined(1:k, 3));

    delete(impact_lines);

    title(['T = ', num2str(round(T_combined(k), 2), '%.2f'), ' s']);
    drawnow;

    frame = getframe(gcf);
    writeVideo(video_displacement, frame);

    if T_combined(k) >= stop_time
        break;
    end
end

close(video_displacement);