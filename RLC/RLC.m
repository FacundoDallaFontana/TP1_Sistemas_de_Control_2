
clc;clear all;
L=10e-6; R1=4700; R2=5600; R3=10000; C=100e-9;
h=0.000001;tiempo=(0.01/h); t=0:h:tiempo*h;
u=linspace(0,0,tiempo+1);
%Versión linealizada en el equilibrio estable
A1=[-R1/L -1/L;1/C 0];
A2=[-R2/L -1/L;1/C 0];
A3=[-R3/L -1/L;1/C 0];
B=[1/L;0]; 
C1=[R1 0];%muestra tension en R=4,7k
C2=[R2 0];%muestra tension en R=5,6k
C3=[R3 0];%muestra tension en R=10k
C4=[0 1];%muestra tension en C
sys1=ss(A1,B,C1,[]);
sys2=ss(A2,B,C2,[]);
sys3=ss(A3,B,C3,[]);
sys4=ss(A1,B,C4,[]);
sys5=ss(A2,B,C4,[]);
sys6=ss(A3,B,C4,[]);
i=1000;%mantiene la entrada en 0 hasta aproximadamente 1ms

%Defino la entrada U
U=-12;
while(i<(tiempo+1))
 if(mod(i,(0.001/h))==0)%cuando pasan 1ms, cambia el signo de la entrada,
     U=-U;
 end
 u(i)=U;
 i=i+1;
end
u(i)=U;
figure
subplot(4,1,1), plot(t,u), title('Entrada V_e (t)'),grid, ylabel('Amplitude'),xlabel('Time (seconds)');
subplot(4,1,2),lsim(sys1,sys2,sys3,u,t),title('Salida V_R (t)'),grid,legend('R=4,7K','R=5,6K','R=10K');
subplot(4,1,3), lsim(sys4,sys5,sys6,u,t),title('Salida V_C (t)'),grid,legend('R=4,7K','R=5,6K','R=10K');
subplot(4,1,4);hold on;plot(t,lsim(sys1/R1,u,t));plot(t,lsim(sys2/R2,u,t));plot(t,lsim(sys3/R3,u,t));
title('Salida I (t)'),grid,legend('R=4,7K','R=5,6K','R=10K'),ylabel('Amplitude'),xlabel('Time (seconds)');
hold off;
%Identificacion de funcion de transferencia por Chen
clear; clc;

t1=0.002;
yt1=3.467338816;
y2t1=6.607045154;
y3t1=8.602641821;
K=12;

k1=(yt1/K)-1;
k2=(y2t1/K)-1;
k3=(y3t1/K)-1;

b=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(b))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(b))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1)
T2=-t1/log(alfa2)
T3=beta*(T1-T2)+T1
%para evitar numeros complejos
T1=real(T1)
T2=real(T2)
T3=real(T3)

sys_G=tf(K*[T3 1],conv([T1 1],[T2 1]))
sys_G=sys_G/K%Normalizo
sys_G1=tf(K*[0 1],conv([T1 1],[T2 1]))%Se puede despreciar el cero
sys_G1=sys_G1/K;%Normalizo

opt = stepDataOptions('StepAmplitude',K);
figure
subplot(211),step(sys_G,opt),title('Sin despreciar T3'),grid;
subplot(212),step(sys_G1,opt,'red'),title('Despreciando T3'),grid;%Comparamos y demostramos que posible despreciar T3

%Comprobamos cuanto nos acercamos
t=0:0.000001:0.035;
p=step(sys_G1,t,opt);
p=[t' p];

yt1_idn=p(find(p==t1),2)
y2t1_idn=p(find(p==2*t1),2)
y3t1_idn=p(find(p==3*t1),2)

%errores relativos
e1=(yt1_idn-yt1)/yt1 
e2=(y2t1_idn-y2t1)/y2t1
e3=(y3t1_idn-y3t1)/y3t1

%Buscar pico de corriente para calcular C
%
%     I(s)          sC          Vc(s)    sC
%     ---- = --------------- = ------ x ----
%     Vi(s)  LCs^2 + RCs + 1    Vi(s)     1
%
%   LC=cte; RC=cte; Por lo tanto recurrimos a respuesta al escalon de la
%   corriente, sabiendo que el pico de corriente que tendremos sera
%   proporcional a C.

peak_tabla=0.0460;%valor redondeado para poder realizar menos iteraciones
peak_encontrado=1;%le damos un valor para que cumpla el while y pueda comenzar
i=1;
t=0:0.000001:0.035;
iter=1;
C=1
while((peak_encontrado-peak_tabla)>peak_tabla*0.001)%Encontramos el valor 
                                                    %de C, con un e%=0.1%
    sys_G2=tf([C 0],conv([T1 1],[T2 1]));
    p=step(sys_G2,t,opt);   %armo un vector con los valores de la respuesta al escalon
    peak_encontrado=findpeaks(p);%busco el pico
    i=i+((peak_encontrado-peak_tabla)*iter*iter/10); %aumento i
    C=1/i                                  %para luego achicar C
    iter=iter+1;                           
end
peak_encontrado
iter

%Ahora podemos calcular R y L
%Teniamos:
%
%     Vc(s)          1                    1
%     ---- = --------------- = -------------------------
%     Vi(s)  LCs^2 + RCs + 1    (T1*T2)s^2+(T1+T2)s + 1
%
LC=(T1*T2);
RC=(T1+T2);
C
L=LC/C
R=RC/C

%
%
sys_G2s=tf([C 0],[L*C R*C 1]);


t=0:0.000001:0.1;
t1=t(0.01>t);
t2=t((0.05>t)&(t>=0.01));
t3=t(t>=0.05);
y1=0*heaviside(t1);
y2=12*heaviside(t2);
y3=-12*heaviside(t3);
Y=[y1 y2 y3];

H=lsim(sys_G2s,Y,t);
G=lsim(sys_G1,Y,t);
peak_max=max(H)
peak_min=min(H)
figure
subplot(311),plot(t,Y),title('Entrada V_a'),grid;
subplot(312),plot(t,H),title('Salida I_t'),grid;
subplot(313),plot(t,G),title('Salida V_c'),grid;
