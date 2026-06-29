% Approccio moderno
We_ang = makeweight(5, 16, 0.5);
Wd_ang = ss(1);
Wn_ang = makeweight(0.1, 40, 10);
Wc_ang = ss(1);

We_pos = makeweight(25, 1.5, 0.1);
Wd_pos = ss(1);
Wn_pos = makeweight(0.1, 100, 2);
Wc_pos = ss(1);

We = [We_pos 0;
      0 We_ang];

Wd = [Wd_pos 0;
      0 Wd_ang];

Wc = [Wc_pos 0;
      0 Wc_ang];

Wn = [Wn_pos 0;
      0 Wn_ang];

Wi = ss(1);
Wu = makeweight(0.05, 60, 5);


%% Costruzione impianto generalizzato
P = [ -We*G0*Wi,      -We*Wd,        -We*Wn,     -We*G0;
          0    ,   zeros(1,2),    zeros(1,2),       Wu ;
       Wc*G0*Wi,       Wc*Wd,     zeros(2,2),     Wc*G0;
         -G0*Wi,         -Wd,           -Wn,        -G0];

P = minreal(P);

%% Equivalente: 'connect'
%(1) posizione, (2) angolo pitch
G0.InputName = 'u_tot';
G0.OutputName = {'g_out(1)', 'g_out(2)'};

We.InputName = {'e(1)', 'e(2)'};
We.OutputName = {'ze(1)', 'ze(2)'};

Wc.InputName = {'c(1)', 'c(2)'};
Wc.OutputName = {'zc(1)', 'zc(2)'};

Wu.InputName = 'u';
Wu.OutputName = 'zu';

Wi.InputName = 'd_in';
Wi.OutputName = 'di_pesato';

Wd.InputName = {'d(1)', 'd(2)'};
Wd.OutputName = {'d_pesato(1)', 'd_pesato(2)'};

Wn.InputName = {'n(1)', 'n(2)'};
Wn.OutputName = {'n_pesato(1)', 'n_pesato(2)'};

Nodo_U = sumblk('u_tot = u + di_pesato');
Nodo_C = sumblk('c = g_out + d_pesato', 2); 
Nodo_E = sumblk('e = - c - n_pesato', 2);
Nodo_Y = sumblk('y = e', 2);

Ingressi_P = {'d_in', 'd(1)', 'd(2)', 'n(1)', 'n(2)', 'u'};
Uscite_P = {'ze(1)', 'ze(2)', 'zu', 'zc(1)', 'zc(2)', 'y(1)', 'y(2)'};

% Creazione della matrice
P1 = minreal(connect(G0, We, Wu, Wc, Wi, Wd, Wn, Nodo_U, Nodo_C, Nodo_E, Nodo_Y, Ingressi_P, Uscite_P));