clc

% Determine total number of lines in the file
fid = fopen(filename, 'rt');
nLines = sum(~feof(fid)*fread(fid, Inf, '*char')' == char(10));
fclose(fid);

% Read the data
dataAll = importdata(filename, '\n', nLines);

% Remove lines starting with '#' sign
dataAll = dataAll(~startsWith(dataAll, '#'));

%if (ii == 0)
    % Check if dataAll is a structure or a cell array
    if isstruct(dataAll) && isfield(dataAll, 'textdata')
        data = dataAll.textdata(1:end);
    elseif iscell(dataAll)
        data = dataAll(1:end);
    else
        error('Unexpected data format');
    end
%end

%% Assuming 'data' is your cell array
nRows = length(data);
nCols = numel(str2num(data{1}));  % Assuming space-separated values; adjust for your delimiter

M = zeros(nRows, nCols);

for i = 1:nRows
    M(i, :) = str2num(data{i});
end
