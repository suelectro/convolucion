clc
clear
close all


%--abrir el archivo de la señal
archivo = fopen('rec_1.dat','r');
leer_archivo = fread(archivo,Inf,'int16');
fclose(archivo);

%--se obtiene el canla 1 (el sin filtrar)
canal_1 = leer_archivo(1:2:end);

%--pasar de unidades del conversor analógico-digital (ADC) a milivoltios (mV).
ecg_mV = canal_1/200;

%--tomar muestra de 5 seg
Fs = 500; %--frecuencia de muestreo Hz
N = 10*Fs;
x = ecg_mV(1:N); % x[n] con info hasta los 5 seg

%--vector de tiempo
n = 0:N-1;
t = n/Fs;

%--grafica de la señal original hasta los 10s
%figure;
%plot(t,x);
%xlabel('Tiempo en segundos');
%ylabel('Amplitud en mV');
%title('Señal Original ECG');

%--filtro pasa altas (h[n])
M = 100; %--Orden
fc = 0.5; %--frecuencia de corte Hz
hHP = fir1 (M, fc/(Fs/2) ,'high', hamming(M+1)) ; %--repuesta al impulso hHP[n]

%   yHP[n] = x[n] ∗ hHP[n]

%--grafica
nh= 0:M;
figure;
stem(nh, hHP);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso filtro pasa altas');

%--comprobamos δ[n] ∗ h[n] = h[n]
%--se crea δ[n]
impulso = zeros(10,1);
impulso(1)= 1; %--en todos los caso vale 0, exepto en la posicion 0 (en matlab es 1)

y_impulso = conv(impulso,hHP); %--calcula δ[n] ∗ h[n]

%-- grafica comparacion
%Ny_impulso =10 + Nh -1 ;
%n_impulso = 0: Ny_impulso-1;

%figure;
%subplot(2,1,1);
%stem(n_impulso, y_impulso);
%title('δ[n] ∗ h[n]');

%subplot(2,1,2);
%stem(nh, hHP);
%title('h[n]');




%--Experimento 1: Convolución con la señal ECG

% y[n] = ∑︂ x[k] h[n−k]

Nx = length(x); %--longitud de la señal original N
Nh = length(hHP); %--longitud de la respuesta al impulso M+1

Ny = Nx+Nh-1; %--longitud que deberia tener la salida
y = zeros(Ny,1); %--vector inicial de longitud Ny donde se guadara la salida, ahora esta con ceros

for n_salida = 1:Ny   %--bucle para recorrer posiciones de y (variable n en la sumatoria)
    for k = 1:Nx   %--bucle para recorrer posiciones de x (variable k en la sumatoria)
        pos_h = n_salida-k +1;   %--se calcula n-k (+1 para el caso n-k=0 ya que da error)
            if pos_h>=1 && pos_h<=Nh    %--limitar la covolucion a la longitud de hHP[n]
                y(n_salida)= y(n_salida) + x(k)*hHP(pos_h);    %--se hace la ecuacion de la serie ∑︂ x[k] h[n−k]
            end
    end
end

%--grafica de la salida de la convolucion:
t_y = (0: Ny-1)/Fs;
figure;
plot(t_y, y);
xlabel('Segundos');
ylabel('Amplitud En mV');
title('señal salida del filtro pasa altas');

%--comprobamos usando la convolucion de matlab
y_convolucion = conv(x,hHP);

figure;
subplot(2,1,1);
plot(t_y, y);
xlabel('Segundos');
ylabel('Amplitud En mV');
title('señal salida del filtro pasa altas');

subplot(2,1,2);
stem(t_y, y_convolucion);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso h[n]');

error_absoluto = max(abs(y-y_convolucion(:)));



%-- Experimento 2: Análisis temporal
figure;
subplot(3,1,1);
plot(t,x);
xlabel('Segundos');
ylabel('Amplitud en mV');
title('Señal electrocardiográfica original x[n]');

subplot(3,1,2);
stem(nh, hHP);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso del filtro pasa altas');

subplot(3,1,3);
plot(t_y, y);
xlabel('Segundos');
ylabel('Amplitud en mV');
title('Señal filtrada y[n]');

%% figura experimento 2:
figure;
plot(t, x, t_y, y);
xlabel('Segundos');
ylabel('Amplitud en mV');
title('Retraso de la señal filtrada respecto a la original');
legend('x[n] original','y[n] filtrada');