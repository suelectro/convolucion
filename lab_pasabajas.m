%% Abrir el archivo
archivo = fopen('rec_1.dat','r');
%% leer el archivo
leer_archivo = fread(archivo,Inf,'int16');
fclose(archivo);
%% Separar canal
canal_1 = leer_archivo(1:2:end);
%% pasar a mV
ecg_mV= canal_1/200;
%% frecuencia de muestro:
fs = 500;
%% formula cantidad de muestras en 5 segundos:
N = 5* fs;
x = ecg_mV(1:N);
%% Hacer el vector de tiempo
n= 0:N-1;
t= n/fs;
%% graficar
figure;
plot(t,x);
xlabel('Tiempo en segundos');
ylabel('Amplitud en mV');
title('Electrocardiograma');
%% filtro pasa bajas:
M= 50;
fc = 40;
hLP= fir1(M,fc/(fs/2), 'low', hamming(M+1));
%% Respuesta al impulso:
nh= 0:M;
figure;
stem(nh, hLP);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso filtro pasa bajas');
%% experimento 1 convolucion:
Nx = length(x);
Nh = length(hLP);
Ny = Nx + Nh-1 ;
y = zeros(Ny,1);
for n_salida = 1:Ny
    for k = 1:Nx
        pos_h = (n_salida -1)-(k-1)+1;
            if pos_h>= 1 && pos_h <= Nh
                y(n_salida)= y(n_salida)+x(k)*hLP(pos_h);
            end
        end
end

%% graficar señal salida del filtro pasa bajas
n_y= 0: Ny-1;
t_y = n_y/fs;
figure;
plot(t_y, y);
xlabel('Segundos');
ylabel('Amplitud En mV');
title('señal salida del filtro pasa bajas');
%% Vamos a Comprobar la convolucion:
Can_impulso= 10;
impulso = zeros(Can_impulso,1);
impulso(1)= 1;

%% convolucion del impulso:
Ny_impulso =Can_impulso + Nh -1 ;
y_impulso = zeros (Ny_impulso,1);
for n_salida = 1:Ny_impulso
    for k = 1:Can_impulso
        pos_h = (n_salida -1)-(k-1)+1;
        if pos_h>=1 && pos_h <= Nh
            y_impulso(n_salida) = y_impulso(n_salida) + impulso(k)*hLP(pos_h);
        end
    end
end
%% comparar
n_impulso = 0: Ny_impulso-1;
figure;
subplot(2,1,1);
stem(n_impulso, y_impulso);
xlabel('Indice n');
ylabel('Amplitud');
title('Resultado Convolucion del impulso con h');
subplot(2,1,2);
stem(nh, hLP);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso h[n]');
%% comparamos con la funcion convolucion de matlab:
y_convolucion = conv(x,hLP);
diferencia = max(abs(y-y_convolucion(:)));
%% experimento 2:
figure;
subplot(3,1,1);
plot(t,x);
xlabel('Segundos');
ylabel('Amplitud en mV');
title('Señal electrocardiográfica original x[n]');
subplot(3,1,2);
stem(nh, hLP);
xlabel('Indice n');
ylabel('Amplitud');
title('Respuesta al impulso del filtro pasa bajas');
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