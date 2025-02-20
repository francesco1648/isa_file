% Nome del file di input e di output
inputFile = 'mem_s0_f0_dec_spaces.txt';    % Nome del file di testo di input
outputFile = 'mem_s0_f0_dec_spaces.xlsx';   % Nome del file Excel di output

% Leggere il file di testo
data = dlmread(inputFile);

% Scrivere i dati in un file Excel
xlswrite(outputFile, data);

fprintf('I dati mem_s0_f0_dec_spaces sono stati copiati con successo in %s\n', outputFile);

inputFile = 'mem_s0_f1_dec_spaces.txt';    % Nome del file di testo di input
outputFile = 'mem_s0_f1_dec_spaces.xlsx';   % Nome del file Excel di output

% Leggere il file di testo
data = dlmread(inputFile);

% Scrivere i dati in un file Excel
xlswrite(outputFile, data);

fprintf('I dati mem_s0_f1_dec_spaces sono stati copiati con successo in %s\n', outputFile);

inputFile = 'mem_s1_f1_dec_spaces.txt';    % Nome del file di testo di input
outputFile = 'mem_s1_f1_dec_spaces.xlsx';   % Nome del file Excel di output

% Leggere il file di testo
data = dlmread(inputFile);

% Scrivere i dati in un file Excel
xlswrite(outputFile, data);

fprintf('I dati mem_s1_f1_dec_spaces sono stati copiati con successo in %s\n', outputFile);

% Nome del file di input e di output
inputFile = 'mem_s0_f1_dec_spaces.txt';    % Nome del file di testo di input
outputFile = 'mem_s0_f1_dec_spaces.xlsx';   % Nome del file Excel di output

% Leggere il file di testo
data = dlmread(inputFile);

% Scrivere i dati in un file Excel
xlswrite(outputFile, data);

fprintf('I dati mem_s0_f1_dec_spaces sono stati copiati con successo in %s\n', outputFile);




