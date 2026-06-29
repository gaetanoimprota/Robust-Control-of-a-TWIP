%% Analisi e riduzione del controllore H-inf
R = reducespec(K_inf, "balanced");

figure('Name', 'Analisi delle Energie degli Stati (reducespec)');
view(R);
% fa tutto in automatico
K_ridotto = getrom(R, 'order', 5);

fprintf('\n--- Report di Riduzione ---\n');
fprintf('Ordine K originale: %d\n', order(K_inf));
fprintf('Ordine K ridotto: %d\n', order(K_ridotto));

%% Alternativa 'manuale':
stati_da_mantenere = 5;
% K in rapp. bilanciata
[K_bal, H] = balreal(K_inf);
display(H);
stati_da_eliminare = (stati_da_mantenere + 1):order(K_bal);
K_ridotto = xelim(K_bal, stati_da_eliminare);

fprintf('\n--- Report di Riduzione ---\n');
fprintf('Ordine K originale: %d\n', order(K_inf));
fprintf('Ordine K ridotto: %d\n', order(K_ridotto));

%% Confronto
figure;
sigma(K_ridotto, 'r', K_inf, 'b');
title('K Ridotto vs K_inf');
legend;
grid on;

%% Verifica finale ad Anello Chiuso sul sistema nominale
S = minreal(feedback(eye(2), sys*K_ridotto));
S_nom = minreal(feedback(eye(2), G0*K_ridotto));
T = minreal(feedback(sys*K_ridotto, eye(2))); %closed-loop
T_nom = minreal(feedback(G0*K_ridotto, eye(2))); %closed-loop (G0)
KS = minreal(K_ridotto*S);
KS_nom = minreal(K_ridotto*S_nom);
disp("Poli del sistema a ciclo chiuso: ");
format longG;
display(pole(T));
format short;

