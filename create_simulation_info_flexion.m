function fileID = create_simulation_info_flexion(filename, params)
    fileID = fopen(filename, 'w');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, '      MULTI-PELLET FLEXIONAL VIBRATION SIMULATION\n');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, 'Date: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

    fprintf(fileID, '--- Pellet Parameters ---\n');
    fprintf(fileID, 'Number of Pellets: %d\n', params.N_pellets);
    fprintf(fileID, 'Individual Pellet Mass (Mp): %.4f kg\n', params.Mp_individual);
    fprintf(fileID, 'Axial Compression Force (Fk): %.2f N\n\n', params.Fk);

    fprintf(fileID, '--- Cladding (Beam) Parameters ---\n');
    fprintf(fileID, 'Length (L): %.3f m\n', params.L);
    fprintf(fileID, 'Young''s Modulus (E): %.2e Pa\n', params.E);
    fprintf(fileID, 'Density (rho): %.1f kg/m^3\n', params.rho);
    fprintf(fileID, 'Outer Diameter (Do): %.4f m\n', params.Do);
    fprintf(fileID, 'Inner Diameter (Di): %.4f m\n', params.Di);
    fprintf(fileID, 'Area (A): %.4e m^2\n', params.A);
    fprintf(fileID, 'Moment of Inertia (I): %.4e m^4\n\n', params.I);

    fprintf(fileID, '--- Interaction Parameters ---\n');
    fprintf(fileID, 'Friction Coefficient (Mu_kp): %.2f\n', params.Mu_kp);
    fprintf(fileID, 'Gravity (g): %.2f m/s^2\n', params.g);
    fprintf(fileID, 'Gap (H1): %.6f m\n', params.H1);
    fprintf(fileID, 'Coefficient of Restitution (e): %.2f\n\n', params.e);

    fprintf(fileID, '--- Excitation Parameters ---\n');
    fprintf(fileID, 'Force Amplitude (F0): %.2f N\n', params.F0);
    fprintf(fileID, 'Frequency (OMEGA): %.2f rad/s\n\n', params.OMEGA);

    fprintf(fileID, '--- Initial Conditions ---\n');
    fprintf(fileID, 'Initial Pellet Displacement (Xp0): %.4f m\n', params.Xp0);
    fprintf(fileID, 'Initial Pellet Velocity (Vp0): %.4f m/s\n\n', params.Vp0);

    fprintf(fileID, '--- FEM Discretization ---\n');
    fprintf(fileID, 'Number of Elements (Ne): %d\n\n', params.Ne);

    fprintf(fileID, '--- Simulation Control ---\n');
    fprintf(fileID, 'Time Span: [%.2f, %.2f] s\n', params.T_span_all(1), params.T_span_all(2));
    fprintf(fileID, 'Time Step (T_step): %.1e s\n', params.T_step);
    fprintf(fileID, 'Time Tolerance: %.1e s\n\n', params.time_tolerance);
    
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, '               IMPACT LOG STARTED\n');
    fprintf(fileID, '==================================================\n');
end
