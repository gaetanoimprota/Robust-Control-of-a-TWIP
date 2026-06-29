function gamma_opt = norma_inf(sys)
    % input: sys -> sistema LTI (modello ss)
    
    gamma_min = 0;
    gamma_max = 50;
    % tolleranza dell'algoritmo di bisezione
    tol_bisezione = 1e-3;

    A = sys.A; B = sys.B; C = sys.C; D = sys.D;
    
    % Se il gamma_max iniziale è troppo piccolo, lo alziamo.
    while testGammaRiccati(A, B, C, D, gamma_max)==false
        gamma_max = gamma_max * 5;
        if(gamma_max>1000000)
            gamma_opt = 'Inf';
            return;
        end
    end

    % Bisezione
    iter = 0;
    while (gamma_max - gamma_min) > tol_bisezione
        iter = iter + 1;
        gamma_mid = (gamma_min + gamma_max) / 2;
        
        if testGammaRiccati(A, B, C, D, gamma_mid)
            % gamma_mid è un tetto valido, lo abbassiamo
            gamma_max = gamma_mid;
        else
            % gamma_mid è troppo basso, alziamo
            gamma_min = gamma_mid;
        end
    end
    
    gamma_opt = gamma_max;
end

function is_valid = testGammaRiccati(A, B, C, D, gamma)
    % Costruisce la matrice Hamiltoniana parametrica e la testa
    
    I = eye(size(D, 2));
    R = (gamma^2) * I - (D' * D);
    
    % R deve essere definita positiva. E' il primo step: se non lo è, non
    % va avanti, ma alza direttamente gamma.
    if min(eig(R)) <= 0
        is_valid = false;
        return;
    end
    
    % Costruzione della matrice hamiltoniana
    invR = R \ eye(size(R));
    H11 = A + B * invR * D' * C;
    H12 = B * invR * B';
    H21 = -C' * (eye(size(C,1)) + D * invR * D') * C;
    H22 = -H11';
    
    H_gamma = [H11, H12; H21, H22];
    
    % Verifica tramite la logica di Riccati
    is_valid = checkRiccatiDomain(H_gamma);
end

function is_riccati = checkRiccatiDomain(H)
    % questa funzione verifica se la matrice Hamiltoniana H appartiene 
    % al dominio dell'operatore di Riccati.
    
    n = size(H, 1) / 2;
    tol = 1e-9; % è usata una tolleranza numerica per approssimazioni
    % macchina
    
    % Calcolo autovalori e autovettori
    [W, D] = eig(H);
    autovalori = diag(D);
    
    % H non deve avere autovalori sull'asse immaginario
    if any(abs(real(autovalori)) < tol)
        is_riccati = false;
        return;
    end
    
    % V1 deve essere invertibile
    % Identifichiamo gli autovalori stabili (parte reale negativa)
    indici_stabili = real(autovalori) < -tol;

    % Estraiamo la base del sottospazio stabile e prendiamo il blocco superiore V1
    V_stabile = W(:, indici_stabili);
    V1 = V_stabile(1:n, :);
    
    % controllo se V1 è invertibile   
    if rank(V1) < n
        is_riccati = false;
        return;
    end

    is_riccati = true;
end