%% letura del señal ECG
Fs = 500;
fid = fopen('rec_1.dat', 'r');
datos = fread(fid, [2 Inf], 'int16', 0, 'ieee-le');   
fclose(fid);

ecg_raw  = datos(1,:) / 200;    
ecg_filt = datos(2,:) / 200;    

N_total = size(datos, 2);
fprintf('Registro: rec_1 | Fs = %d Hz | %d muestras | %.1f s | canal: ECG I\n', ...
    Fs, N_total, N_total/Fs);

%% SEGMENTO DE 10 s (del segundo 2 al 12)
t_ini = 2;  t_fin = 12;
idx   = t_ini*Fs + 1 : t_fin*Fs;

x     = ecg_raw(idx);           
x_ref = ecg_filt(idx);         
t_ecg = (0:length(x)-1)/Fs;     

figure; plot(t_ecg, x); grid on;
xlabel('Tiempo (s)'); ylabel('Amplitud (mV)'); title('ECG original x[n]');

%% CONVOLUCIÓN MANUAL

function y = miConvolucion(x, h)
Nx = length(x);  Nh = length(h);  Ny = Nx + Nh - 1;
y = zeros(1, Ny);
for n = 1:Ny
    suma = 0;
    for k = max(1, n-Nh+1) : min(n, Nx)    
        suma = suma + x(k) * h(n-k+1);
    end
    y(n) = suma;
end
end

%% FILTRO PASA BANDA
Fs = 500; M = 100; fL = 0.5; fH = 40;
hBP = fir1(M, [fL fH]/(Fs/2), 'bandpass', hamming(M+1));

figure;
stem(0:M, hBP, 'filled');
xlabel('n'); ylabel('h_{BP}[n]');
title('Respuesta al impulso - Filtro pasa banda (M=100)');
grid on;

%% respuesta al impulso
delta = 1;                         
y_delta = miConvolucion(delta, hBP);
figure;
subplot(2,1,1); stem(0:M, hBP, 'filled'); title('h_{BP}[n]'); grid on;
subplot(2,1,2); stem(0:M, y_delta, 'filled'); title('\delta[n] * h_{BP}[n]'); grid on;
fprintf('Diferencia máxima (debe ser ~0): %g\n', max(abs(hBP - y_delta)));

%% EXPERIMENTO 1: CONVOLUCIÓN CON EL ECG 

yBP_manual = miConvolucion(x, hBP);     
yBP_matlab = conv(x, hBP);              

fprintf('¿Coinciden ambas convoluciones? %d\n', isequal(round(yBP_manual,10), round(yBP_matlab,10)));

%% EXPERIMENTO 2: ANÁLISIS TEMPORAL
t_y = (0:length(yBP_manual)-1)/Fs;

figure;
subplot(3,1,1); plot(t_ecg, x); xlabel('s'); ylabel('Amplitud'); title('ECG original x[n]'); grid on;
subplot(3,1,2); plot((0:M)/Fs, hBP); xlabel('s'); ylabel('h_{BP}[n]'); title('Respuesta al impulso'); grid on;
subplot(3,1,3); plot(t_y, yBP_manual); xlabel('s'); ylabel('Amplitud'); title('Salida y_{BP}[n]'); grid on;

%% EXPERIMENTO 3: EFECTO DEL ORDEN (M=20,50,100) 
ordenes = [20 50 100];
figure;
for i = 1:length(ordenes)
    Mi = ordenes(i);
    hi = fir1(Mi, [fL fH]/(Fs/2), 'bandpass', hamming(Mi+1));
    yi = miConvolucion(x, hi);

    retardo_muestras = Mi/2;            
    retardo_seg = retardo_muestras/Fs;
    fprintf('M=%d -> retardo teorico = %.4f s (%d muestras)\n', Mi, retardo_seg, retardo_muestras);

    subplot(length(ordenes),1,i);
    plot((0:length(yi)-1)/Fs, yi);
    title(sprintf('Salida pasa banda, M=%d (retardo ~%.3f s)', Mi, retardo_seg));
    xlabel('s'); grid on;
end