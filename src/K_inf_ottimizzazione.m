
K_AS = info.AS;

ordine_Q = 6;
Q_hinf_tunable = tunableSS('Q_hinf', ordine_Q, 1, 2);

Q_hinf_tunable.D.Value = zeros(1, 2);

% Blocca la matrice D in modo che systune non possa modificarla
Q_hinf_tunable.D.Free = false;

AP_in  = AnalysisPoint('Q_in', 2);  % 2 segnali che entrano in Q
AP_out = AnalysisPoint('Q_out', 1); % 1 segnale che esce da Q

Q_wrapped = AP_out * Q_hinf_tunable * AP_in;

K_tunable = minreal(lft(K_AS, Q_wrapped));
Tzw_tunable = lft(P1, K_tunable);

% norma inf < 1 (soft - prestazioni)
In_Tzw = {'d_in', 'd(1)', 'd(2)', 'n(1)', 'n(2)'};
Out_Tzw = {'ze(1)', 'ze(2)', 'zu', 'zc(1)', 'zc(2)'};
Req_Hinf = TuningGoal.Gain(In_Tzw, Out_Tzw, 1);

% norma di Q < gamma (hard - stabilità)
Req_Q_norm = TuningGoal.Gain('Q_in', 'Q_out', gamma * 0.99);
Req_Q_norm.Name = 'Vincolo_Norma_Q';

Options = systuneOptions('RandomStart', 30);

[Tzw_opt, fSoft, ~, Info] = systune(Tzw_tunable, Req_Hinf, Req_Q_norm, Options);

% estrazione del controllore ottimizzato
Q_opt_hinf = getBlockValue(Tzw_opt, 'Q_hinf');
K_opt_hinf = minreal(lft(K_AS, Q_opt_hinf));

%%
figure('Name', 'K_inf ottimizzato');
sigma(K_opt_hinf, 'b-', K_inf, 'r-');
title("K-inf(s) ottimizzato vs K-inf(s)");
legend;
grid on;
format longG;
display(pole(Tzw_opt));
format short;

%% Analisi del Ciclo Chiuso
S = minreal(feedback(eye(2), sys*K_opt_hinf));
S_nom = minreal(feedback(eye(2), G0*K_opt_hinf));
T = minreal(feedback(sys*K_opt_hinf, eye(2))); % closed-loop
T_nom = minreal(feedback(G0*K_opt_hinf, eye(2))); % closed-loop (G0)
KS = minreal(K_opt_hinf*S);
KS_nom = minreal(K_opt_hinf*S_nom);

disp("Poli del sistema a ciclo chiuso: ");
format longG;
display(pole(T));