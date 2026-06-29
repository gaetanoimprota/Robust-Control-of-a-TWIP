%% Two Wheeled Inverted Pendulum
clear;
clc;

% parametri struttura
Mp_nom = 0.8;      
L_nom  = 0.07;     
h_top   = 0.1425;     

Mp = ureal('Mp', Mp_nom, 'Percentage', [-1, 50]);
Num_L = (Mp_nom * L_nom + (Mp - Mp_nom) * h_top);
L =  Num_L / Mp;

mw = 0.08;       % massa di una singola ruota + rotore (kg)
R  = 0.0325;      % raggio della ruota (m)
Jp = ureal('Jp', 0.004, 'Plusminus', 0.001);   % inerzia del corpo (kg*m^2)
Jw = 0.00002;    % inerzia della singola ruota (kg*m^2)
g  = 9.81;      % accelerazione di gravità (m/s^2)

% parametri motori DC
K_mot = ureal('K_mot', 0.01, 'Percentage', 10);
Kt = K_mot;      % costante di coppia (Nm/A)
Ke = K_mot;      % costante controelettromotrice (V*s/rad)
Rm = ureal('Rm', 10.0, 'Percentage', 15);       % resistenza dell'avvolgimento (Ohm)
n  = 50;        % rapporto di riduzione (50:1)

Meq = Mp + 2*mw + 2*(Jw/(R^2));
Jeq = Jp + Mp*(L^2);
c   = Num_L;

alpha = (2 * n * Kt) / Rm;
beta  = (2 * n^2 * Kt * Ke) / Rm;

E = Meq*Jeq - c^2;

% termini da inserire nelle matrici A e B
a22 = -(Jeq*beta + c*R*beta) / (E*R^2);
a23 = -(c^2 * g) / E;                 
a24 = (Jeq*beta + c*R*beta) / (E*R);

a42 = (c*beta + Meq*R*beta) / (E*R^2);
a43 = (Meq*c*g) / E;
a44 = -(c*beta + Meq*R*beta) / (E*R);

b2 = (Jeq*alpha + c*R*alpha) / (E*R);
b4 = -(c*alpha + Meq*R*alpha) / (E*R);  

% matrici spazio di stato
% stati: [posizione, velocità, angolo di pitch, velocità angolare]
A = [0,   1,   0,   0;
     0, a22, a23, a24;
     0,   0,   0,   1;
     0, a42, a43, a44];

B = [0;
     b2;
     0;
     b4];

C = [1 0 0 0;
     0 0 1 0];

D = [0; 0]; 

sys = ss(A, B, C, D); % creazione dello spazio di stato
sys = simplify(sys, 'Full'); % el

% aggiungo le etichette alle variabili
sys.StateName = {'Posizione', 'Vel_Lin', 'Angolo_Pitch', 'Vel_Ang'};
sys.InputName = {'Tensione_V'};
sys.OutputName = {'Posizione', 'Angolo_Pitch'};

display(sys);

%%
G0 = sys.nominal;
G0 = minreal(G0);
display(G0);
% figure('Name', 'Valori Singolari di G0');
% sigma(G0);
% grid on;

display(pole(G0));
display(zero(G0(1,1)));
display(zero(G0(2,1)));

% analisi della controllabilità
Cb = ctrb(sys.A, sys.B);
if rank(Cb) == size(sys.A, 1)
    fprintf("\nSistema completamente controllabile.\n\n");
else
    fprintf("\nSistema NON completamente controllabile.\n\n");
end

% analisi dell' osservabilità
Ob = obsv(sys.A, sys.C);
if rank(Ob) == size(sys.A, 1)
    fprintf("\nSistema completamente osservabile.\n\n");
else
    fprintf("\nSistema NON completamente osservabile.\n\n");
end