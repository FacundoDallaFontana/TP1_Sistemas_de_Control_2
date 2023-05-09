clear;%close all;
X=-[0; 0; 0];ii=0;t_etapa=1e-7;thetaRef=1 ;tF=.1;
%Constantes del PID
Ts=t_etapa;
%Kp=0.3;Ki=0;Kd=0;color_='r';
Kp=4;Ki=1;Kd=0.026;color_='k';
%Kp=5;Ki=0;Kd=0.027;color_='b';

A1=((2*Kp*Ts)+(Ki*(Ts^2))+(2*Kd))/(2*Ts);
B1=(-2*Kp*Ts+Ki*(Ts^2)-4*Kd)/(2*Ts);
C1=Kd/Ts;
e=zeros(round(tF/t_etapa),1);u=0;
for t=0:t_etapa:tF
 ii=ii+1;k=ii+2;
 X=modmotor_pid(t_etapa, X, u);
 e(k)=thetaRef-X(3); %ERROR
 u=u+A1*e(k)+B1*e(k-1)+C1*e(k-2); %PID
 x1(ii)=X(1);%Omega
 x2(ii)=X(2);%wp
 x3(ii)=X(3);%theta
 acc(ii)=u;
end
t=0:t_etapa:tF;
acc(1)=0;%este primer valor hay que descartarlo,
%para poder observar la accion de control correctamente
subplot(3,1,1);hold on;
plot(t,x3,color_),grid;title('Salida y, \theta_t');
subplot(3,1,2);hold on;
plot(t,x1,color_),grid;title('Salida y, \omega_t');
subplot(3,1,3);hold on;
plot(t,acc,color_),grid;title('Entrada u_t, v_a');
xlabel('Tiempo [Seg.]');
