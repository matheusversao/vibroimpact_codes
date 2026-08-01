%% parameters.m 
 
% 1) PARÂMETROS (Baseado no parameters.m original)
N_pellets = 40;  
pellet_volume = pi * (8.19e-3 / 2)^2 * 10e-3; 
pellet_density_eff = 10970 * 0.95; 
Mp_individual = pellet_volume * pellet_density_eff; 
Mp = repmat(Mp_individual, N_pellets, 1); 

L = 0.5;         % m, Comprimento entre duas grelhas de espaçamento 
E = 9.5e10;      % Pa, Módulo de Young para Zircaloy-4 
rho = 6550;      % kg/m^3, Densidade do Zircaloy-4 
Do = 9.5e-3;     % m, Diâmetro externo 
Di = 8.3e-3;     % m, Diâmetro interno 
A = pi*(Do^2 - Di^2)/4; 
I = pi*(Do^4 - Di^4)/64; 

Mu_kp = 0.3;      
g = 9.81; 
Fk = 0;         
H1 = 0.1e-3; 
e_restitution = 0.3; 

%% =======================
% 2) PARÂMETROS DE HERTZ 
E_p  = 12.6e9;   % Pellet [Pa]
nu_p = 0.3;      
nu_c = 0.37;     
L_p = 10e-3;     % Altura do pellet (comprimento de contato)

E_star = 1 / ((1 - nu_p^2)/E_p + (1 - nu_c^2)/E);
k_hertz = (pi * E_star * L_p) / 2; 

% Amortecimento viscoso equivalente
zeta_hertz = abs(log(e_restitution))/sqrt(pi^2 + (log(e_restitution))^2);
c_hertz = 2 * zeta_hertz * sqrt(k_hertz * Mp_individual);

%% ======================= 
% EXCITAÇÃO
F0 = 0.1;       % N
OMEGA = 150;     % rad/s 
 
%% ======================= 
% CONDIÇÕES INICIAIS 
Xp0 = zeros(N_pellets, 1); 
Vp0 = zeros(N_pellets, 1); 
 
%% ======================= 
% DISCRETIZAÇÃO FEM DA VIGA 
Ne = 80; 
Nn = Ne + 1; 
l = L/Ne; 
Ndof = 2*Nn; 
 
%% ======================= 
% SIMULAÇÃO 
T_span_all = [0 1]; 
T_step = 1e-5; 
time_tolerance = 1e-6; 
delta_tol = 1e-8; 
vel_rel_tol = 1e-6; 