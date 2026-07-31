% create_simulation_info.m

function fileID = create_simulation_info(filename, simulation_params)
    fileID = fopen(filename, 'w');

    % Get current date and time
    currentDateTime = datestr(now, 'dd/mm/yyyy at HH:MM');

    % Write title and header information in the .txt file
    fprintf(fileID, '2DOF Damped Oscillating System with N impacts\n');
    fprintf(fileID, '========================\n\n');
    fprintf(fileID, 'Simulation created on: %s\n\n', currentDateTime);

    % Write simulation parameters in the .txt
    fprintf(fileID, 'Simulation Parameters:\n');
    fprintf(fileID, 'Mc = %.3f kg\n', simulation_params.Mc);
    fprintf(fileID, 'Mp1 = %.3f kg\n', simulation_params.Mp1);
    fprintf(fileID, 'C = %.2f Ns/m\n', simulation_params.C);
    fprintf(fileID, 'K = %.2f N/m\n', simulation_params.K);
    fprintf(fileID, 'mu_kc = %.2f \n', simulation_params.Mu_kc);
    fprintf(fileID, 'mu_kp = %.2f \n', simulation_params.Mu_kp);
    fprintf(fileID, 'g = %.2f m/s^2\n', simulation_params.g);
    fprintf(fileID, 'e = %.2f \n', simulation_params.e);

    fprintf(fileID, 'Initial Conditions:\n');
    fprintf(fileID, 'Xp10 = %.4f m\n', simulation_params.Xp10);
    fprintf(fileID, 'Vp10 = %.4f m/s\n', simulation_params.Vp10);

    fprintf(fileID, 'Spring Parameters:\n');
    fprintf(fileID, 'ks = %.2f N/mm\n', simulation_params.ks);
    fprintf(fileID, 'x = %.2f mm\n', simulation_params.x);
    fprintf(fileID, 'Fk = %.2f N\n', simulation_params.Fk);

    fprintf(fileID, 'Gap Pellets/Cladding:\n');
    fprintf(fileID, 'H1 = %.4f m\n', simulation_params.H1);

    fprintf(fileID, 'Number of Impacts Simulated:\n');
    fprintf(fileID, 'N = %d\n', simulation_params.N);

    fprintf(fileID, 'Time parameters:\n');
    fprintf(fileID, 'T_span = [%.1f s, %.1f s]\n', simulation_params.T_span_all(1), simulation_params.T_span_all(2));
    fprintf(fileID, 'T_step = %.1e s\n', simulation_params.T_step);
    fprintf(fileID, 'Impact tolerance = %.1e\n', simulation_params.time_tolerance);

    fprintf(fileID, '\nImpact Details:\n');
    fprintf(fileID, 'Impact Number\tTime(s)\tImpacting Mass(Mp)\tdelta_x\tPlace of impact\n');
end