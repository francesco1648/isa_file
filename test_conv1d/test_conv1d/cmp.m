% Nomi dei file da confrontare
file1 = 'matrice_risultante.txt';
file2 = 'output.txt';

% Apertura dei file
fid1 = fopen(file1, 'r');
fid2 = fopen(file2, 'r');

if fid1 == -1 || fid2 == -1
    error('Errore nell''apertura di uno dei file.');
end

% Lettura dei file
data1 = textscan(fid1, '%s', 'Delimiter', '\n');
data2 = textscan(fid2, '%s', 'Delimiter', '\n');

% Chiudi i file dopo la lettura
fclose(fid1);
fclose(fid2);

% Conversione dei contenuti in celle di stringhe
lines1 = data1{1};
lines2 = data2{1};

% Controllo delle dimensioni
if length(lines1) ~= length(lines2)
    fprintf('I file hanno un numero diverso di righe.\n');
    isEqual = false;
else
    % Confronto riga per riga
    isEqual = true;
    for i = 1:length(lines1)
        if ~strcmp(lines1{i}, lines2{i})
            fprintf('Differenza trovata alla riga %d:\n', i);
            fprintf('File1: %s\n', lines1{i});
            fprintf('File2: %s\n', lines2{i});
            isEqual = false;
        end
    end
end

% Risultato del confronto
if isEqual
    fprintf('I due file sono identici.\n');
else
    fprintf('I due file non sono identici.\n');
end
