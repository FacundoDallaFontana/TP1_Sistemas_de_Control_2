clear;clc;
%Funcion de transferencia W/Va
%Utilizamos datos del excel
t1=0.0003;
yt1=101.9904241;
y2t1=152.1137514;
y3t1=176.1370343;


%t1=0.00001;
%yt1=2.626974205;
%y2t1=7.068399362;
%y3t1=11.65803382;

K=198.2488022;%Valor final

k1=(yt1/K)-1;
k2=(y2t1/K)-1;
k3=(y3t1/K)-1;

b=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(b))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(b))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;
%para evitar numeros complejos
T1=real(T1)
T2=real(T2)
T3=real(T3)

sys_G=tf(K*[T3 1],conv([T1 1],[T2 1]));
sys_G=sys_G/12%Normalizo con 12 porque es la entrada de tension
sys_G1=tf(K*[0 1],conv([T1 1],[T2 1]));%Se puede despreciar el cero
sys_G1=sys_G1/12%Normalizo con 12 porque es la entrada de tension
%Comprobamos cuanto nos acercamos
opt = stepDataOptions('InputOffset',0,'StepAmplitude',12);
t=0:0.00001:0.005;
p=step(sys_G1,t,opt);
p=[t' p];

yt1_idn=p(find(p==t1),2)
y2t1_idn=p(find(p==2*t1),2)
y3t1_idn=p(find(p==3*t1),2)

%errores relativos
e1=(yt1_idn-yt1)/yt1 
e2=(y2t1_idn-y2t1)/y2t1
e3=(y3t1_idn-y3t1)/y3t1

%Funcion de transferencia (W/Tl + W/Va*(-24/-0.00103))-24--->(de 12 a -12)
%Utilizamos datos del excel                        -0.00103-->(para que las unidades coincidan)
%resto 200 para suponer que arranca en 0
t1=0.000225;
yt1=97.40917307-200;
y2t1=-3.90087875-200;
y3t1=-13.77536774-200;
K=-27-200;%Valor final 


k1=(yt1/K)-1;
k2=(y2t1/K)-1;
k3=(y3t1/K)-1;

b=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(b))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(b))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;
%para evitar numeros complejos
T1=real(T1)
T2=real(T2)
T3=real(T3)

sys_T=tf(K*[0 1],conv([T1 1],[T2 1]));
sys_T=sys_T/-0.00103%Normalizo

s=tf('s');
opt = stepDataOptions('InputOffset',0,'StepAmplitude',-0.00103);
figure

subplot(211),step(sys_T*exp(-s*0.15),opt),title('\omega_t'),grid;%wt despues de t=0.15 seg
subplot(212),step(sys_T,opt),grid;

%Comprobamos cuanto nos acercamos
t=0:0.00000001:0.035;
p=step(sys_T,t,opt);
p=[t' p];

yt1_idn=p(find(p==t1),2)
y2t1_idn=p(find(p==2*t1),2)
y3t1_idn=p(find(p==3*t1),2)

%errores relativos
e1=(yt1_idn-yt1)/yt1 
e2=(y2t1_idn-y2t1)/y2t1
e3=(y3t1_idn-y3t1)/y3t1


%%%%%%%%%%%%%%%%%%%%%

%Calculamos W/Tl (por superposicion)
sys_TL=sys_T-sys_G1*(-24/-0.00103)
figure
step(sys_TL,opt),title('W/T_L con escalon de T_L = -0.00103'),grid;
%%%%%%%%%%%%%%%%%%%%%
%Ahora con las funciones de transferencia lo hacemos mas directamente
ss1=ss(sys_G1);
ss2=ss(sys_TL);
h=0.0000001;
t=0:h:0.35;
n=0.35/h;
Va(t<0.025)=0;
Va(t>=0.025)=12;
Va(t>0.15)=-12;
Tl(t<0.15)=0;
Tl(t>=0.15)=-0.00103;

W=lsim(ss1,Va,t)+lsim(ss2,Tl,t);

%Volvemos a emular las datos de la tabla
figure
plot(t,W),title('Emulando grafico de tablas'),grid;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear;clc;
%Ahora con la corriente-Calculamos I/Va
%Utilizamos datos del excel
t1=0.0000225;
yt1=0.115033293;
y2t1=0.11020409;
y3t1=0.104304968;
K=3.47e-14;%Valor final

k1=(yt1/K)-1;
k2=(y2t1/K)-1;
k3=(y3t1/K)-1;

b=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(b))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(b))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;
%para evitar numeros complejos
T1=real(T1)
T2=real(T2)
T3=real(T3)

sys_I=tf(K*[T3 1],conv([T1 1],[T2 1]));
sys_I=sys_I/12%Normalizo con 12 porque es la entrada de tension

%Comprobamos cuanto nos acercamos
opt = stepDataOptions('InputOffset',0,'StepAmplitude',12);
t=0:0.00000001:0.005;
p=step(sys_I,t,opt);
p=[t' p];

yt1_idn=p(find(p==t1),2)
y2t1_idn=p(find(p==2*t1),2)
y3t1_idn=p(find(p==3*t1),2)

%errores relativos
e1=(yt1_idn-yt1)/yt1 
e2=(y2t1_idn-y2t1)/y2t1
e3=(y3t1_idn-y3t1)/y3t1

%Funcion de transferencia (I/Tl + I/Va*(-24/-0.00103))-24--->(de 12 a -12)
%Utilizamos datos del excel                        -0.00103-->(para que las unidades coincidan)
%
t1=0.00015;
yt1=-0.170411411;
y2t1=-0.119807323;
y3t1=-0.114707095;
K=-0.106;%Valor final 

t1=0.0000075;
yt1=-0.184331666;
y2t1=-0.224425338;
y3t1=-0.230066585;
K=-0.106;%Valor final 



k1=(yt1/K)-1;
k2=(y2t1/K)-1;
k3=(y3t1/K)-1;

b=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3;
alfa1=(k1*k2+k3-sqrt(b))/(2*(k1^2+k2));
alfa2=(k1*k2+k3+sqrt(b))/(2*(k1^2+k2));
beta=(k1+alfa2)/(alfa1-alfa2);

T1=-t1/log(alfa1);
T2=-t1/log(alfa2);
T3=beta*(T1-T2)+T1;
%para evitar numeros complejos
T1=real(T1)
T2=real(T2)
T3=real(T3)

sys_I2=tf(K*[T3 1],conv([T1 1],[T2 1]));
sys_I2=sys_I2/-0.00103%Normalizo

s=tf('s');
opt = stepDataOptions('InputOffset',0,'StepAmplitude',-0.00103);
figure

subplot(211),step(sys_I2*exp(-s*0.15),opt),title('I_t'),grid;%It despues de t=0.15 seg
subplot(212),step(sys_I2,opt),grid;

%Comprobamos cuanto nos acercamos
t=0:0.00000001:0.035;
p=step(sys_I2,t,opt);
p=[t' p];

yt1_idn=p(find(p==t1),2)
y2t1_idn=p(find(p==2*t1),2)
y3t1_idn=p(find(p==3*t1),2)

%errores relativos
e1=(yt1_idn-yt1)/yt1 
e2=(y2t1_idn-y2t1)/y2t1
e3=(y3t1_idn-y3t1)/y3t1

%Calculamos I/Tl
sys_Is=sys_I2-sys_I*(-24/-0.00103)
figure
step(sys_Is,opt),title('I/T_L con escalon de T_L = -0.00103'),grid;
%%%%%%%%%%%%%%%%%%%%%
%Ahora con las funciones de transferencia lo hacemos mas directamente
ss1=ss(sys_I);
ss2=ss(sys_Is);
h=0.0000001;
t=0:h:0.35;
n=0.35/h;
Va(t<0.025)=0;
Va(t>=0.025)=12;
Va(t>0.15)=-12;
Tl(t<0.15)=0;
Tl(t>=0.15)=-0.00103;

I=lsim(ss1,Va,t)+lsim(ss2,Tl,t);

%Volvemos a emular las datos de la tabla
figure
plot(t,I),title('Emulando grafico de tablas'),grid;

figure
subplot(4,1,1),plot(t,W),title('\omega_t'),grid,ylim([-40 220]);
subplot(4,1,2),plot(t,I),title('i_t'),grid,ylim([-0.3 0.15]);
subplot(4,1,3),plot(t,Va),title('Va_t'),grid,ylim([-14 14]);
subplot(4,1,4),plot(t,Tl),title('TL_t'),grid,ylim([-0.0015 0.001]);
