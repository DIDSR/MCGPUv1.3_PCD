% Open the file for reading in binary mode
fid = fopen(filename, 'rb');

% Check if the file was successfully opened
if fid == -1
    error('Failed to open the raw file.');
end

% Determine the size of the file
file_info = dir(filename);

file_size = file_info.bytes;

% Read the binary data
binary_data = fread(fid, file_size/4, 'float32');

% Close the file
fclose(fid);

% reshape data to help extract the data that the user requested
binary_data_reshaped = reshape(binary_data, Nx * Nz, Nbin, [])

% Get the data the user requested
% Switch-case structure
switch read_binary(2)
    case '1'
        % Data for All types of scatter
        M = binary_data_reshaped(:,:,1)
    case '2'
        % Non-scattered data
        M = binary_data_reshaped(:,:,2)
    case '3'
        % Compton data
        M = binary_data_reshaped(:,:,3)
    case '4'
        % Rayleigh data
        M = binary_data_reshaped(:,:,4)
    case '5'
        % Multi-Scatter data
        M = binary_data_reshaped(:,:,5)
    otherwise
        % Unknown type of data
        disp('Unknown Type of binary data; All interaction data is sentby default');
        M = binary_data_reshaped(:,:,1)
end