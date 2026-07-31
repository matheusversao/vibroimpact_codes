% parameters.m  CoR
% PROPRIEDADES DO SISTEMA  
Mc = 1.575;    % kg (Cladding)
Mp1 = 0.320;   % kg (Pellet)  
Mu_kc = 0.22;   
Mu_kp = 0.55;     
g = 9.81;       % m/s²  
Mu_sp = 0.6;    
v_tol = 1e-4; 
  
% AMPLITUDE E EXCITAÇÃO (Sweep Sinus)  
X0 = 4e-3;           % ±4 mm  
f_start = 5;         % Hz (Frequência inicial) 
f_end = 10;          % Hz (Frequência final) 
sweep_rate = 1;      % Oct/min (Taxa de varredura) 
 
% Cálculo do tempo total para 1 Oct/min de 5 a 10 Hz: 
T_total = 60;        % s  
k_sweep = (sweep_rate/60) * log(2); 
  
% MOLAS E AMORTECIMENTO   
K = 0;  
C = 0;  
  
% GAP 
H1 = 2.8e-3;  
  
% CONDIÇÕES INICIAIS (somente Pellet)  
Xp10 = -2.8e-3;  
Vp10 = 0;       
Xc0 = 0;        
Vc0 = 0;         
  
% PARÂMETROS DE COMPRESSÃO
ks = 0;  
x = 0;  
Fk = 0;  
  
% IMPACTO 
e = 0.19;      
N = 1000000;  
 
% TEMPO E TOLERÂNCIAS
T_span_all = [0, T_total];  
T_step = 1e-5;         
time_tolerance = 2e-5; 
delta_tol = 1e-7;     
vel_rel_tol = 1e-6;   
 
% PARÂMETROS DE ANIMAÇÃO 
stop_time = 1.5;     
NbP = 2;             
Height = 0.15;       
Width = 0.082;       
th = 0.0055;         
scale_factor = 1.5;  
lim_axis = 0.15;  