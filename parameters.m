% parameters.m
% This script contains all the variables and parameters for the simulation.

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

%% Parameters animation
stop_time = 1.5; % Choose the time to stop the ANIMATION
NbP = 2; % Number of Pellets
Height = 0.15; % Height Pellet m
Width = 0.082; % Width Pellet m
th = 0.0055; % Thickness Cladding m
scale_factor = 1.5; % Factor to increase the gap visually
lim_axis = 0.15; % Define the limit of visualization of axis X

% Value of Factor of Damping xi
xi = C / (2 * sqrt(K * (Mc + Mp1)));
