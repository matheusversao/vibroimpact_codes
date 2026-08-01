function finalize_simulation_flexion(fileID, elapsed_time, summary)
    fprintf(fileID, '\n==================================================\n');
    fprintf(fileID, '             SIMULATION FINISHED\n');
    fprintf(fileID, '==================================================\n');
    fprintf(fileID, 'Total Simulation Time: %.2f seconds\n\n', elapsed_time);

    fprintf(fileID, '--- Simulation Summary ---\n');
    fprintf(fileID, 'Total Number of Impacts: %d\n', summary.n_impacts);
    fprintf(fileID, 'Max Cladding Disp. (at L/2): %.4e m\n', summary.q_max_mid);
    fprintf(fileID, 'RMS Cladding Disp. (at L/2): %.4e m\n', summary.q_rms_mid);
    fprintf(fileID, 'Mean Flexural Energy: %.4f J\n', summary.E_flex_mean);
    fprintf(fileID, '==================================================\n');
    
    fclose(fileID);
end
