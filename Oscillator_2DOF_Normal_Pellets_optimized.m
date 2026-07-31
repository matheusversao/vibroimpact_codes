%% main_script.m CoR
close all; clear; clc; tic;  
  
% 1) Configuração Inicial  
run('parameters.m');  
  
% Criar uma struct com os parâmetros da simulação para logging  
simulation_params = struct('Mc', Mc, 'Mp1', Mp1, ...  
    'C', C, 'K', K, 'Mu_kc', Mu_kc, 'Mu_kp', Mu_kp, 'g', g, ...  
    'f_start', f_start, 'f_end', f_end, 'X0', X0, 'e', e, 'Xp10', Xp10, ...  
    'Vp10', Vp10, ...  
    'ks', ks, 'x', x, 'Fk', Fk, ...  
    'H1', H1, 'N', N, ...  
    'T_span_all', T_span_all, 'T_step', T_step, 'time_tolerance', time_tolerance, ...  
    'Height', Height, 'Width', Width, 'th', th, 'scale_factor', scale_factor);  
  
results_folder = 'results'; 
if ~exist(results_folder,'dir'), mkdir(results_folder); end 
filename = fullfile(results_folder,'impact_details.txt'); 
fileID = create_simulation_info(filename, simulation_params); 
 
%% Funções de Excitação de Frequência Fixa
fixed_frequency = f_start; % Use f_start, which is now 10Hz
omega_fixed = 2 * pi * fixed_frequency;

phi_func = @(t) omega_fixed * t;
freq_inst_func = @(t) fixed_frequency;
omega_inst_func = @(t) omega_fixed;

% Cladding imposto (Posição e Velocidade)
Xc_func = @(t) X0 * sin(omega_fixed * t);
Vc_func = @(t) X0 * omega_fixed * cos(omega_fixed * t);
Ac_func = @(t) -X0 * (omega_fixed^2) * sin(omega_fixed * t); %aceleração cladding stick-slip

%Swept sinus (comment if fixed frequency)
rate_sec = sweep_rate / 60; 
phi_func = @(t) 2*pi * f_start * (2.^(rate_sec * t) - 1) / (rate_sec * log(2)); 
freq_inst_func = @(t) f_start * 2.^(rate_sec * t); 
omega_inst_func = @(t) 2*pi * freq_inst_func(t); 
 
Xc_func = @(t) X0 * sin(phi_func(t)); 
Vc_func = @(t) X0 * omega_inst_func(t) .* cos(phi_func(t)); 
Ac_func = @(t) -X0 * (omega_inst_func(t).^2) .* sin(phi_func(t)); %aceleração cladding stick-slip 

%% 2) Simulação Passo a Passo  
t_current = T_span_all(1);  
t_final   = T_span_all(2);  
u_current = [Xp10; Vp10]; 
  
n_steps = ceil((t_final - t_current)/T_step) + 1;  
T_all   = zeros(n_steps,1);  
Y_all   = zeros(n_steps,length(u_current));  
T_impact = zeros(n_steps,1);  
Vrel_impact = zeros(n_steps,1);  
impact_count = 0;  
last_impact_time = -inf;  
  
T_all(1) = t_current;  
Y_all(1,:) = u_current';  
step = 1;  
  
% EDO do pellet dentro do cladding imposto  
ode_func = @(t,Y) pellet_dynamics( ... 
    t, Y, Mu_sp, Mu_kp, Mp1, g, Fk, ... 
    Vc_func, Ac_func, v_tol); 
  
% Loop principal  
while t_current < t_final  
    step = step + 1;  
    t_next = t_current + T_step;  
    if t_next > t_final, t_next = t_final; end  
  
    % Integração do pellet  
    [~, Y_step_vec] = ode45(ode_func,[t_current t_next],u_current);  
    u_next = Y_step_vec(end,:)';  
  
    % Extrair variáveis  
    Xp_next = u_next(1); Vp_next = u_next(2);  
    Xc_next = Xc_func(t_next);  
    Vc_next = Vc_func(t_next);  
  
    delta_rel = Xp_next - Xc_next;  
    v_rel     = Vp_next - Vc_next;  
  
    % Detecção e tratamento de impacto  
    if (abs(delta_rel) > H1 + delta_tol) && (abs(v_rel) > vel_rel_tol) && (t_next > last_impact_time + time_tolerance)  
        impact_count = impact_count + 1;  
        last_impact_time = t_next;  
        T_impact(impact_count) = t_next;  
        Vrel_impact(impact_count) = v_rel;  
  
        % Velocidades pós-impacto  
        Vc_plus = ((Mc - e*Mp1)*Vc_next + (1+e)*Mp1*Vp_next)/(Mc + Mp1);  
        Vp_plus = ((Mp1 - e*Mc)*Vp_next + (1+e)*Mc*Vc_next)/(Mc + Mp1);  
        Xp_plus = Xc_next + sign(delta_rel)*H1;  
        u_next = [Xp_plus; Vp_plus];  
  
        % Log do impacto  
        side = "Left"; if delta_rel>0, side="Right"; end  
        fprintf(fileID,'%d\t%.6f\t%.6e\t%s\n',impact_count,t_next,delta_rel,side);  
    end  
  
    % Atualiza variáveis  
    t_current = t_next;  
    u_current = u_next;  
    T_all(step) = t_current;  
    Y_all(step,:) = u_current';  
  
    if mod(step,1000)==0  
        fprintf('Progresso: %.2f%%\n',(t_current/t_final)*100);  
    end  
end  
  
%% 3) Pós-processamento  
T_all = T_all(1:step);  
Y_all = Y_all(1:step,:);  
T_impact = T_impact(1:impact_count);  
Vrel_impact = Vrel_impact(1:impact_count);  
  
Xp_all = Y_all(:,1); Vp_all = Y_all(:,2);  
Xc_all = arrayfun(Xc_func, T_all);  
Vc_all = arrayfun(Vc_func, T_all);  
delta_xp_all = Xp_all - Xc_all;  
  
% Energia  
E_pe = 0.5*K*Xc_all.^2;  
E_k  = 0.5*Mc*Vc_all.^2;  
E_total = E_pe + E_k;  
  
%% Força aplicada ao Cladding 
Force_all = zeros(size(T_all)); 
v_tol_stick = 1e-4; 

for i = 1:length(T_all) 
    F0_inst = Mc * X0 * (omega_fixed^2); 
    v_rel_inst = Vp_all(i) - Vc_all(i);
    
    % Termos estruturais base do cladding
    F_cladding_base = F0_inst * sin(phi_func(T_all(i))) - C*Vc_all(i) - K*Xc_all(i) ...
                      - Mu_kc*((Mc+Mp1)*g).*sign(Vc_all(i));
    
    if abs(v_rel_inst) < v_tol_stick
        Ac_inst = -X0 * (omega_fixed^2) * sin(phi_func(T_all(i)));
        F_pellet = Mp1 * Ac_inst; 
    else
        F_pellet = -Mu_kp * (Mp1*g + Fk) * sign(v_rel_inst);
    end
    
    % Força de excitação total externa
    Force_all(i) = F_cladding_base + F_pellet;  
end 

%% FILTERING
fc = 20;
fs = 1/mean(diff(T_all));
[b, a] = butter(2, fc/(fs/2));
Force_all_filt = filtfilt(b, a, Force_all);
delta_xp_all_filt = filtfilt(b, a, delta_xp_all);
 
%% Plots  
Fs = 1/T_step;  
Y_fft = fft(Xp_all - mean(Xp_all));  
f = (0:length(Y_fft)-1)*(Fs/length(Y_fft));  
Y_mag = abs(Y_fft)/length(Y_fft);  
figure_fft = figure;  
plot(f,Y_mag,'k','LineWidth',1.3); grid on; xlim([0 50]);  
title('FFT - Pellet');  
  
% Plots finais   
green_color = [0.2 0.8 0.6];  
plot_enabled = true;  
  
if plot_enabled  
    figure_displacements = figure;  
    set(figure_displacements,'Name','Final Displacements'); hold on; grid on;  
    xlabel('Time (s)'); ylabel('Displacement (m)'); title('Final Displacements');  
    plot(T_all,Xc_all,'k','LineWidth',1.3,'DisplayName','Cladding');  
    plot(T_all,Xp_all,'Color',green_color,'LineWidth',1.3,'DisplayName','Pellet');  
    legend('show');  
  
    figure_delta_xp = figure;  
    set(figure_delta_xp,'Name','Final Relative Displacement'); hold on; grid on;  
    xlabel('Time (s)'); ylabel('\Delta x_{p} (m)'); title('Final Relative Displacement');  
    plot(T_all,Xc_all,'r','LineWidth',1.3,'DisplayName','Cladding Absolute Displacement');  
    plot(T_all,-delta_xp_all,'k','LineWidth',1.3,'DisplayName','Relative Displacement');  
    yline(H1,'r--','DisplayName','Gap'); yline(-H1,'r--','HandleVisibility','off'); xlim(T_span_all);  
    legend('show');  
  
end  
  
%% Salvar figuras  
saveas(figure_displacements,fullfile(results_folder,'displacements.png'));  
saveas(figure_delta_xp,fullfile(results_folder,'relative_displacement_with_cladding.png'));  
if exist('figure_pid','var')  
    saveas(figure_pid,fullfile(results_folder,'pid.png'));  
end  
  
save(fullfile(results_folder,'simulation_data.mat'), ...  
    'T_all','Y_all','T_impact','Vrel_impact','Xc_all','Vc_all','Xp_all','Vp_all', ...  
    'delta_xp_all','E_total','Force_all','impact_count');  
  
fprintf('Finalizando arquivo de log...\n');  
elapsed_time = toc;  
fclose(fileID); 
	  
fprintf('Simulação concluída e todos os arquivos foram salvos.\n'); 

function dYdt = pellet_dynamics(t,Y,Mu_s,Mu_k,Mp,g,Fk,Vc_func,Ac_func,v_tol) 
	 
Vp = Y(2); 
Vc = Vc_func(t);  
Ac = Ac_func(t); 
	 
v_rel = Vp - Vc; 
N = Mp*g + Fk; 
	 
if abs(v_rel) < v_tol && abs(Mp*Ac) <= Mu_s*N 
    dYdt = [Vc; Ac]; % stick 
else 
    dYdt = [Vp; -Mu_k*N*sign(v_rel)/Mp]; % slip 
end 
 
end 