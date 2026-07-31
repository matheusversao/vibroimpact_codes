% finalize_simulation.m
% This function writes the elapsed time to the .txt file and closes it.

function finalize_simulation(fileID1, elapsed_time)
    if fileID1 == -1
        error('File ID is invalid.');
    end
    % Write elapsed time to the file
    fprintf(fileID1, '\nElapsed time for simulation: %.2f seconds\n', elapsed_time);
    % Close the file
    fclose(fileID1);
end
