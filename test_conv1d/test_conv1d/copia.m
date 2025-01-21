% Nome del file di input e di output
inputFile = 'mem.txt';    % Nome del file di testo di input
outputFile = 'mem.xlsx';   % Nome del file Excel di output

% Leggere il file di testo
data = dlmread(inputFile);

% Scrivere i dati in un file Excel
xlswrite(outputFile, data);

fprintf('I dati sono stati copiati con successo in %s\n', outputFile);
