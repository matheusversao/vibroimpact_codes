% parameters.m

% Variables and parameters of the problem
Mc = 1.575; % kg
Mp1 = 0.320; % kg
C = 0.5; % N.s/m
K = 3900; % N/m
Mu_kc = 0.22;
Mu_kp = 0.5;
g = 9.81; % m/s²
OMEGA = 0; % rad/s
F0 = 0; % N

% Gap Pellets/Cladding
H1 = 2.8e-3; % m

% Initial conditions (m)
Xc0 = 0.025; 
Xp10 = 0.025; 
Vc0 = 0;
Vp10 = 0;

% Spring parameters
ks = 0; % N/mm
x = 0; % mm
Fk = ks*x; % N

% Coefficient of restitution
e = 0.19; 

% Number of impacts max to simulate
N = 1000000;

% Adjust the time span for solving the ODEs
T_span_all = [0, 1.5];
T_step = 1e-5;
T_span = T_span_all(1) : T_step : T_span_all(2);
time_tolerance = 1e-4;

%% Animation parameters
stop_time   = 1.5;   % Time to stop the animation
NbP         = 1;     % Number of Pellets
Height      = 0.15;  % Height Pellet [m]
Width       = 0.082; % Width Pellet [m]
th          = 0.0055;% Thickness Cladding [m]
scale_factor = 1.5;  % Visual scale factor for gap
lim_axis    = 0.15;  % Visualization axis limit [m]

%% Material and geometry properties (for Hertzian law)
E_p  = 2.1e11;   % Young's modulus pellet [Pa]
nu_p = 0.31;   % Poisson ratio pellet
E_c  = 9.9e10;   % Young's modulus cladding [Pa]
nu_c = 0.31;   % Poisson ratio cladding
R_p = 4.55e-3;   % Pellet radius [m]
R_c = 4.55e-3;  % Cladding inner radius [m]

%% Hertzian contact parameters
% Reduced modulus
E_star = 1 / ((1 - nu_p^2)/E_p + (1 - nu_c^2)/E_c);

% Effective radius for local contact
R_eff_p = R_p; % Raio do pellet
R_eff_c = R_c; % Raio interno do cladding

% Raio efetivo para cilindros paralelos (1/R_eff = 1/R1 + 1/R2)
if R_eff_c == R_eff_p
    R_eff = R_p/2;
else
    R_eff = (R_eff_p * R_eff_c) / (R_eff_c - R_eff_p);
end % Para contato interno (cilindro dentro de um cilindro)

% Hertz stiffness
L = 10*10^-3; % m 
k_line = (pi * E_star * L) / 2; % Rigidez de Hertz para cilindros paralelos

% Reduced mass
m_star = (Mp1 * Mc) / (Mp1 + Mc);

% Empirical constant for viscoelastic Hertz contact
zeta = abs(log(e))/sqrt(pi^2 + (log(e))^2);
c_line = 2 * zeta * sqrt(k_line * m_star);

%% Damping ratio for reference
xi = C / (2 * sqrt(K * (Mc + Mp1)));
