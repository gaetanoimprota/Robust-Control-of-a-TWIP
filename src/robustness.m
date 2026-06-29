%% Analisi della stabilità robusta 'manuale'
[M, Delta, BlkStruct] = lftdata(T); % comando che mi separa direttamente la M e la Delta!

% M = [M11, M12;
%      M21, M22]

% Delta = matrice diagonale a blocchi delle mie incertezze delta

% Perchè? Perchè qui è difficile calcolare a mano la M11

% Analisi 'veloce': norma infinito (se <1 già stabile robusto!)
M11 = M(1:40, 1:40);
disp('Norma infinito di M11: ');
N_inf = norm(M11, 'inf');
disp(N_inf); % >1 (49.07)

% Analisi della Norma mu
[bounds, muinfo] = mussv(M11, BlkStruct); % nota: gli do la struttura del delta
disp('Norma-Mu di M11: ');
disp(max(max(squeeze(bounds.ResponseData)))); % valore singolare strutturato massimo
% E' lui che mi dice se il sistema è robusto

%%
% Estrazione dei dati dall'oggetto frd
omega = bounds.Frequency;
upper_bound = squeeze(bounds.ResponseData(1,1,:)); % Prima riga, prima colonna
lower_bound = squeeze(bounds.ResponseData(1,2,:)); % Prima riga, seconda colonna

% Creazione del grafico
figure('Name', 'Analisi mu: Upper e Lower Bounds', 'Color', 'w');
semilogx(omega, upper_bound, 'b', 'LineWidth', 2); hold on;
semilogx(omega, lower_bound, 'r', 'LineWidth', 1.5);

% Linea critica di stabilità robusta
yline(1, 'k--', 'Limite di Stabilità (\mu = 1)', 'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');

% Formattazione
grid on;
xlabel('Frequenza [rad/s]');
ylabel('Valore Singolare Strutturato \mu');
title('Analisi di Stabilità Robusta (\mu-Analysis)');
legend('Upper Bound', 'Lower Bound', 'Location', 'best');

%% Analisi della stabilità robusta con robstab

% Check controllore K_inf
opt = robOptions('Display', 'on', 'Sensitivity', 'on');
[StabilityMargin, destabunc] = robstab(T, opt);