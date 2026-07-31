%% Drawing with movement (Cladding and Pellets)

NbP = 1; % Number of Pellets
scale_factor = 1.5; % Factor to increase the gap visually

T_combined = vertcat(T_all_cell{:});
Y_combined = vertcat(Y_all_cell{:});

h = max([H1]); % Máximo Gap entre Pellet e Cladding
h_scaled = h * scale_factor;

% Geometria do Pellet (Mp1)
Mp1_x = [-Width/2, Width/2, Width/2, -Width/2];
Mp1_y = [0, 0, Height, Height];

% Geometria do Cladding (Mc)
Mc_x = [-((Width/2) + h_scaled + th), -((Width/2) + h_scaled + th), -((Width/2)+h_scaled), -((Width/2)+h_scaled), ...
         ((Width/2)+h_scaled), ((Width/2)+h_scaled), ((Width/2) + h_scaled + th), ((Width/2) + h_scaled + th), ...
         -((Width/2) + h_scaled + th)];
Mc_y = [-th, NbP*Height, NbP*Height, 0, 0, NbP*Height, NbP*Height, -th, -th];

% Criar figura
figure;
hold on;
hMc = fill(Mc_x, Mc_y, color_set{1, 1}, 'FaceAlpha', 0.3);
hMp1 = fill(Mp1_x, Mp1_y, color_set{1, 2}, 'FaceAlpha', 0.5);

xlabel('x (m)');
ylabel('y (m)');
title('Animation of Displacements (With impacts)');
legend('Cladding', 'Pellet 1');

y_margin = 0.2 * (NbP*Height - (-th)); % 10% de margem vertical
ylim([-th, NbP*Height + y_margin]);

axis equal;
grid on;

max_displacement = max(abs(Y_combined(:,1))) + max(abs(Y_combined(:,3)));

% Aumentar a margem horizontal para garantir que o gráfico não seja cortado
x_margin_factor = 1.2; % Aumenta a margem em 20%
x_lim_min = min(Mc_x) - max_displacement * scale_factor * x_margin_factor;
x_lim_max = max(Mc_x) + max_displacement * scale_factor * x_margin_factor;
xlim([x_lim_min, x_lim_max]);


% Pasta de saída para vídeo
results_folder = 'results_animations';
if ~exist(results_folder, 'dir')
    mkdir(results_folder);
end

% Criação do arquivo de vídeo
video_filename = fullfile(results_folder, '2DOF_System_With_Impacts.mp4');
video2 = VideoWriter(video_filename, 'Motion JPEG AVI');
frame_skip = 150; % Adjust for a smoother/faster animation (normal 100, câmera 1)
video2.FrameRate = 30; 
open(video2);

% Loop de animação
for k = 1:frame_skip:length(T_combined)
    Xc_abs = -Y_combined(k, 1); 
    Xp1_abs = -Y_combined(k, 3); 

    Mc_x_updated = Mc_x + Xc_abs * scale_factor;
    Mp1_x_updated = Mp1_x + Xp1_abs * scale_factor;

    set(hMc, 'XData', Mc_x_updated);
    set(hMp1, 'XData', Mp1_x_updated);

    title(['Displacement Pellet/Cladding for T = ', num2str(T_combined(k), '%.2f'), ' s']);

    frame = getframe(gcf);
    writeVideo(video2, frame);

    pause(0.01);

    if exist('stop_time', 'var') && T_combined(k) >= stop_time
        break;
    end
end

close(video2);