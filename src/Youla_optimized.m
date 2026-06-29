%% Youla Parametrization (Versione Ottimizzata "Black-Box")

% Estrazione delle sottomatrici da P1
Ap = P1.A;            
B2 = P1.B(:, 6);      % Ingresso u di controllo
C2 = P1.C(6:7, :);    % Uscite misurate y(1), y(2)
D22 = P1.D(6:7, 6);   % Direct feedthrough

n = size(Ap, 1);      
ny = size(C2, 1);    
nu = size(B2, 2);    

Q_f = eye(n);
R_f = eye(nu);     
F = -lqr(Ap, B2, Q_f, R_f);

Q_l = eye(n);
R_l = eye(ny);        
L = -lqr(Ap', C2', Q_l, R_l)';

% Costruzione della matrice J
A_J = Ap + B2*F + L*C2 + L*D22*F;
B_J = [-L, B2 + L*D22];
C_J = [F; -(C2 + D22*F)];
D_J = [zeros(nu, ny), eye(nu); 
       eye(ny),      -D22];

J = ss(A_J, B_J, C_J, D_J);
J = minreal(J);

%% Ottimizzazione di Q tramite systune (Black-Box)
disp("--- Avvio Ottimizzazione di Q(s) Generico ---");

% Definizione di Q come sistema in spazio di stato sintonizzabile
% tunableSS('nome', Nx_stati, Ny_uscite, Nu_ingressi)
% Q riceve 2 segnali da J e restituisce 1 segnale verso J. Fissiamo 3 stati.
ordine_Q = 6; 
Q_blackbox = tunableSS('Q_gen', ordine_Q, 1, 2);

Q_hinf_tunable.D.Value = zeros(1, 2);

% Blocca la matrice D in modo che systune non possa modificarla
Q_hinf_tunable.D.Free = false;

% Costruzione della pianta a ciclo chiuso sintonizzabile
K_tunable = minreal(lft(J, Q_blackbox));
Tzw_tunable = lft(P1, K_tunable);

In_Tzw = {'d_in', 'd(1)', 'd(2)', 'n(1)', 'n(2)'};
Out_Tzw = {'ze(1)', 'ze(2)', 'zu', 'zc(1)', 'zc(2)'};

% Definizione Ingressi/Uscite per il requisito H-infinito
Req_Hinf = TuningGoal.Gain(In_Tzw, Out_Tzw, 1);

% Avvio dell'ottimizzazione
Options = systuneOptions('RandomStart', 30); 
[Tzw_opt, fSoft, ~, Info] = systune(Tzw_tunable, Req_Hinf, Options);

% Estrazione del controllore ottimizzato
Q_opt = getBlockValue(Tzw_opt, 'Q_gen');
K_opt = minreal(lft(J, Q_opt));

disp("Il controllore K parametrizzato è stato ottimizzato con successo.");

%%
figure('Name', 'Parametrizzazione di Youla - Ottimizzata');
sigma(K_opt, 'b-');
title("Sigma Plot: Controllore K(s) Ottimizzato");
grid on;
format longG;
display(pole(Tzw_opt));
format short;

%% Analisi del Ciclo Chiuso
S = minreal(feedback(eye(2), sys*K_opt));
S_nom = minreal(feedback(eye(2), G0*K_opt));
T = minreal(feedback(sys*K_opt, eye(2))); % closed-loop
T_nom = minreal(feedback(G0*K_opt, eye(2))); % closed-loop (G0)
KS = minreal(K_opt*S);
KS_nom = minreal(K_opt*S_nom);

disp("Poli del sistema a ciclo chiuso: ");
format longG;
display(pole(T));
format short;