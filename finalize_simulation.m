% finalize_simulation.m

function finalize_simulation(fileID1, elapsed_time)
    if fileID1 == -1
        error('File ID is invalid.');
    end
    fprintf(fileID1, '\nElapsed time for simulation: %.2f seconds\n', elapsed_time);
    fclose(fileID1);
end
