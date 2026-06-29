%% Progetto del controllore H-Inf con prestazioni sul nominale
[K_inf, Tzw3, gamma, info]  = hinfsyn(P, 2, 1);
%K_inf2  = hinfsyn(P, 2, 1);
K_inf = minreal(K_inf);
%K_inf2 = minreal(K_inf2);
display(K_inf);

figure;
sigma(K_inf, 'b-');
legend('K(s)');
title("Controllore H-inf");
grid on;

% sistema a ciclo chiuso (con le matrici di peso)
minreal(Tzw3);
format longG;
display(pole(Tzw3));
format short;

%figure, sigma(Tzw3,ss(gamma));
%title("Sigma Plot Tzw3(s)");

S = minreal(feedback(eye(2), sys*K_inf));
S_nom = minreal(feedback(eye(2), G0*K_inf));
T = minreal(feedback(sys*K_inf, eye(2))); %closed-loop
T_nom = minreal(feedback(G0*K_inf, eye(2))); %closed-loop (G0)
KS = minreal(K_inf*S);
KS_nom = minreal(K_inf*S_nom);
disp("Poli del sistema a ciclo chiuso: ");
format longG;
display(pole(T));
format short;