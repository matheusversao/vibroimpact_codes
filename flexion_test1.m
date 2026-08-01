%% flexion_test1.m
clear; clc; tic;
close all
run('parameters.m'); 

%% =======================
% 1) CONFIGURAÇÃO DE SAÍDA
results_folder = 'results_multi_pellet_hertz'; 
if ~exist(results_folder,'dir'), mkdir(results_folder); end 
filename = fullfile(results_folder,'impact_details.txt'); 

simulation_params = struct( ... 
    'N_pellets', N_pellets, 'Mp_individual', Mp_individual, 'Fk', Fk, ... 
    'L',L,'E',E,'rho',rho,'Do',Do,'Di',Di,'A',A,'I',I, ... 
    'Ne',Ne,'Mu_kp',Mu_kp,'g',g,'H1',H1,'e',e_restitution, ... 
    'k_hertz', k_hertz, 'c_hertz', c_hertz, ...
    'F0',F0,'OMEGA',OMEGA, ... 
    'Xp0',Xp0(1),'Vp0',Vp0(1), ... 
    'T_span_all',T_span_all,'T_step',T_step,'time_tolerance',time_tolerance); 

% Simulação do create_simulation_info_flexion
fileID = create_simulation_info_flexion(filename, simulation_params);

%% =======================
% 2) FEM DA VIGA  
y_nodes = linspace(0,L,Nn); 
Ke = E*I/l^3 * [ 12 6*l -12 6*l; 6*l 4*l^2 -6*l 2*l^2; -12 -6*l 12 -6*l; 6*l 2*l^2 -6*l 4*l^2 ]; 
Me = (rho*A*l/420) * [ 156, 22*l, 54, -13*l; 22*l, 4*l^2, 13*l, -3*l^2; 54, 13*l, 156, -22*l; -13*l, -3*l^2, -22*l, 4*l^2 ]; 
K_mat = spalloc(Ndof, Ndof, 16*Ne); M_mat = spalloc(Ndof, Ndof, 16*Ne); 
for el = 1:Ne, gdls = [2*el-1 2*el 2*el+1 2*el+2]; K_mat(gdls,gdls) = K_mat(gdls,gdls) + Ke; M_mat(gdls,gdls) = M_mat(gdls,gdls) + Me; end 
fixed_dofs = [1 2 Ndof-1 Ndof]; free_dofs = setdiff(1:Ndof,fixed_dofs); 
Kf = K_mat(free_dofs,free_dofs); Mf = M_mat(free_dofs,free_dofs); nd = length(free_dofs); 
zeta_ray = 0.01; omega1 = (4.730/L)^2*sqrt(E*I/(rho*A)); omega2 = (7.855/L)^2*sqrt(E*I/(rho*A)); 
alpha_ray = zeta_ray * (2*omega1*omega2)/(omega1+omega2); beta_ray = zeta_ray*2/(omega1+omega2); 
Cf = alpha_ray*Mf + beta_ray*Kf; 
use_dense_solver = nd <= 120; 
if use_dense_solver, Mf = full(Mf); Kf = full(Kf); Cf = full(Cf); Mf_solver = chol(Mf,'lower'); else, Mf_solver = decomposition(Mf,'chol'); end 

%% =======================
% 3) INTERPOLAÇÃO E FORÇA  
y_pellets = linspace(L/N_pellets, L, N_pellets) - L/(2*N_pellets); 
N_interp_all = zeros(N_pellets, nd); 
for p = 1:N_pellets 
    y_p = y_pellets(p); elem = find(y_nodes <= y_p, 1, 'last'); 
    if isempty(elem), elem = 1; end; if elem > Ne, elem = Ne; end 
    xi = (y_p - y_nodes(elem))/l; 
    h1=1-3*xi^2+2*xi^3; h2=l*(xi-2*xi^2+xi^3); h3=3*xi^2-2*xi^3; h4=l*(-xi^2+xi^3); 
    H_shape = [h1 h2 h3 h4]; dofs_elem = [2*elem-1 2*elem 2*elem+1 2*elem+2]; 
    [~,idx_free] = ismember(dofs_elem,free_dofs); N_interp_p = zeros(1,nd); 
    for k=1:4, if idx_free(k)>0, N_interp_p(idx_free(k)) = H_shape(k); end, end 
    N_interp_all(p, :) = N_interp_p; 
end 
y_center = L/2; delta_L_ratio = 0.1; delta_L = delta_L_ratio * L; 
y_start = y_center - delta_L/2; y_end = y_center + delta_L/2; F_dist = zeros(nd, 1); 
for el = 1:Ne 
    y_el_start = y_nodes(el); y_el_end = y_nodes(el+1); 
    overlap_start = max(y_el_start, y_start); overlap_end = min(y_el_end, y_end); 
    if overlap_end > overlap_start 
        xi1 = (overlap_start - y_el_start) / l; xi2 = (overlap_end - y_el_start) / l; 
        int_h1 = (xi2 - xi2^3 + 0.5*xi2^4) - (xi1 - xi1^3 + 0.5*xi1^4); 
        int_h2 = l * ((0.5*xi2^2 - (2/3)*xi2^3 + 0.25*xi2^4) - (0.5*xi1^2 - (2/3)*xi1^3 + 0.25*xi1^4)); 
        Fe_unit = [int_h1; int_h2; (xi2^3 - 0.5*xi2^4) - (xi1^3 - 0.5*xi1^4); l * ((-(1/3)*xi2^3 + 0.25*xi2^4) - (-(1/3)*xi1^3 + 0.25*xi1^4))]; 
        d_el = [2*el-1 2*el 2*el+1 2*el+2]; [~,idx_f] = ismember(d_el,free_dofs); 
        for k=1:4, if idx_f(k)>0, F_dist(idx_f(k)) = F_dist(idx_f(k)) + Fe_unit(k); end, end 
    end 
end 
F_dist = F_dist / delta_L; 

%% =======================
% 4) INICIALIZAÇÃO DA SIMULAÇÃO 
t_current = T_span_all(1); t_final = T_span_all(2); 
u_current = [zeros(nd,1); zeros(nd,1); Xp0; Vp0]; 
n_steps = ceil((t_final - t_current)/T_step) + 1; 
T_all = zeros(n_steps, 1); Y_all = zeros(n_steps, length(u_current)); 
impact_count = 0; 
last_impact_time = -inf(N_pellets, 1); 
T_all(1) = t_current; Y_all(1, :) = u_current'; 
step = 1; 
impact_data = zeros(n_steps, 2);  
Impulses = zeros(n_steps, 1); 

%% =======================
% 5) LOOP DE TEMPO PRINCIPAL 
ode_func = @(t,y) fem_multi_pellet_hertz_ode(t,y,Mf_solver,use_dense_solver,Kf,Cf,F_dist,F0,OMEGA,Mp,Mu_kp,g,Fk,N_interp_all,N_pellets,k_hertz,c_hertz,H1); 

while t_current < t_final 
    step = step + 1; 
    t_next = t_current + T_step; 
    if t_next > t_final, t_next = t_final; end 
    
    % Integração
    [~, Y_step_vec] = ode45(ode_func, [t_current, t_next], u_current); 
    u_next = Y_step_vec(end, :)'; 
    
    % Detecção de impacto para logging
    w_next = u_next(1:nd); 
    Xp_next = u_next(2*nd+1 : 2*nd+N_pellets); 
    Xc_next = N_interp_all * w_next; 
    delta_rel_all = Xp_next - Xc_next; 
    
    for p = 1:N_pellets 
        if (abs(delta_rel_all(p)) > H1) && (t_next > last_impact_time(p) + time_tolerance) 
            impact_count = impact_count + 1; 
            last_impact_time(p) = t_next; 
            impact_data(impact_count, :) = [t_next, p]; 
            side = "Left"; if delta_rel_all(p) > 0, side = "Right"; end 
            fprintf(fileID,'%d\t%.6f\t%d\t%.6e\t%s\n', impact_count, t_next, p, delta_rel_all(p), side); 
        end 
    end 
    
    u_current = u_next; 
    t_current = t_next; 
    T_all(step) = t_current; 
    Y_all(step, :) = u_current'; 
    
    if mod(step, 100) == 0, fprintf('Progresso: %.2f%%\n', (t_current/t_final)*100); end 
end 

%% =======================
% 6) PÓS-PROCESSAMENTO E SALVAMENTO
fprintf('Simulação concluída. Iniciando pós-processamento...\n'); 
T_all = T_all(1:step); Y_all = Y_all(1:step, :); 
w_free = Y_all(:, 1:nd); dw_free = Y_all(:, nd+1:2*nd); 
Xp_all = Y_all(:, 2*nd+1 : 2*nd+N_pellets); 
Vp_all = Y_all(:, 2*nd+N_pellets+1 : 2*nd+2*N_pellets); 
Xc_points = (N_interp_all * w_free')'; 
Vc_points = (N_interp_all * dw_free')'; 
impact_data = impact_data(1:impact_count, :); 

% Resumo de Impactos  
impacts_per_pellet = zeros(N_pellets, 1); 
if impact_count > 0, impacts_per_pellet = histcounts(impact_data(:, 2), 1:N_pellets+1)'; end 
fprintf('\n==================================================\n'); 
fprintf('                 IMPACT SUMMARY (HERTZ)\n'); 
fprintf('==================================================\n'); 
fprintf('Total de Impactos Registados: %d\n\n', impact_count); 
for p = 1:N_pellets, fprintf('  - Pellet %2d: %d impactos\n', p, impacts_per_pellet(p)); end 
fprintf('==================================================\n\n'); 

%% Salvamento .mat
save(fullfile(results_folder,'flexional_simulation_data_hertz.mat'), ... 
    'T_all', 'Y_all', ... 
    'w_free', 'dw_free', 'Xp_all', 'Vp_all', 'Xc_points', 'Vc_points', ... 
    'impact_data', ... 
    'y_nodes', 'y_pellets', 'N_pellets', 'Ndof', 'free_dofs', ... 
    'L', 'H1', 'F0', 'OMEGA', 'E', 'rho', 'I', 'A', 'Mp', 'Fk', ... 
    'Kf', 'Mf', 'Cf'); 

fclose(fileID);
elapsed_time = toc; 
fprintf('Simulação concluída em %.2f s. Resultados em ''%s''.\n', elapsed_time, results_folder); 

%% =======================
% FUNÇÃO ODE COM METODOLOGIA DE HERTZ
function dydt = fem_multi_pellet_hertz_ode(t, y, Mf_solver, use_dense_solver, Kf, Cf, F_dist, F0, OMEGA, Mp, Mu_k, g, Fk, N_interp_all, N_pellets, k_hertz, c_hertz, H1)
    nd = size(Kf, 1);
    w = y(1:nd);
    dw = y(nd+1:2*nd);
    Xp = y(2*nd+1 : 2*nd+N_pellets);
    Vp = y(2*nd+N_pellets+1 : 2*nd+2*N_pellets);
    
    Xc = N_interp_all * w;
    Vc = N_interp_all * dw;
    
    delta_rel = Xp - Xc;
    v_rel = Vp - Vc;
    
    F_contact_all = zeros(N_pellets, 1);
    F_friction_all = zeros(N_pellets, 1);
    
    for p = 1:N_pellets
        F_c = 0;
        if delta_rel(p) > H1 
            penetration = delta_rel(p) - H1;
            F_c = -(k_hertz * penetration + c_hertz * v_rel(p));
            if F_c > 0, F_c = 0; end 
        elseif delta_rel(p) < -H1 
            penetration = abs(delta_rel(p)) - H1;
            F_c = (k_hertz * penetration - c_hertz * v_rel(p));
            if F_c < 0, F_c = 0; end 
        end
        F_contact_all(p) = F_c;
        
        % Força Normal e Atrito
        N_normal = Mp(p)*g + Fk + abs(F_c);
        F_friction_all(p) = Mu_k * N_normal * sign(v_rel(p));
    end
    
    % Dinâmica da Viga
    F_ext = F_dist * F0 * sin(OMEGA * t);
    F_reaction_beam = - (N_interp_all' * F_contact_all);
    
    RHS_beam = F_ext + F_reaction_beam - Cf*dw - Kf*w;
    if use_dense_solver
        ddw = Mf_solver' \ (Mf_solver \ RHS_beam);
    else
        ddw = Mf_solver \ RHS_beam;
    end
    
    % Dinâmica dos Pellets
    ddXp = (F_contact_all - F_friction_all) ./ Mp;
    
    dydt = [dw; ddw; Vp; ddXp];
end