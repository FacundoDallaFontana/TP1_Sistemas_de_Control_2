%2.1
clear;clc;
X=-[0; 0; 0];ii=0;t_etapa=1e-7;
tF=2;%tF=5;%lo hago para 2 seg por la carga computacional

color_='k';

Ts=t_etapa;
Laa=366e-6; J=5e-9;Ra=55.6;B=0;Ki=6.49e-3;Km=6.53e-3;
Va=0;
Tl=0;
for t=0:t_etapa:tF
 ii=ii+1;
 X=modmotor2(t_etapa, X, Va, Tl,Laa,J,Ra,B,Ki,Km);
 Va=12;
 if(t>0.1)
 Tl=Tl+1e-10;%inyecto una Tl
 end
 x1(ii)=X(2);%Omega
 x2(ii)=X(1);%I
 acc1(ii)=Va;
 acc2(ii)=Tl;
end
t=0:t_etapa:tF;
%Calculo Tl limite
l=find(x1<0,1);
Tl_limite=(acc2(l)+acc2(l-1))/2%Tl_limite=0.0014

figure
subplot(4,1,1);
plot(t,x1,color_),grid;title('Salida \omega_t');
subplot(4,1,2);
plot(t,x2,color_),grid;title('Salida i_t');
subplot(4,1,3);
plot(t,acc1,color_),grid;title('Entrada  V_a');
subplot(4,1,4);
plot(t,acc2,color_),grid;title('Entrada  T_L')%,ylim([-0.001 0.01]);
xlabel('Tiempo [Seg.]');

%2.2
%Valor maximo de corriente
clear X ii x1 x2 acc1 acc2
X=-[0; 0; 0];ii=0;t_etapa=1e-7;
tF=1;%tF=5;

color_='k';

Ts=t_etapa;

Va=0;
Tl=0;
for t=0:t_etapa:tF
 ii=ii+1;k=ii+2;
 X=modmotor2(t_etapa, X, Va, Tl,Laa,J,Ra,B,Ki,Km);
 if(t>0.1)
 Va=12;
 end
 if(t>0.3)
 Va=-12;
 end
 if(t>0.4)
 Va=12;
 end
 if(t>0.6)
 Va=-12;
 end
 if(t>0.5)
 %Tl=0;  
 Tl=(Va/12)*Tl_limite;%inyecto una Tl que tiene el mismo signo que Va
 end
 x1(ii)=X(2);%Omega
 x2(ii)=X(1);%I
 acc1(ii)=Va;
 acc2(ii)=Tl;
end
t=0:t_etapa:tF;
figure
subplot(4,1,1);
plot(t,x1,color_),grid;title('Salida \omega_t');
subplot(4,1,2);
plot(t,x2,color_),grid;title('Salida i_t');
subplot(4,1,3);
plot(t,acc1,color_),grid;title('Entrada  V_a');
subplot(4,1,4);
plot(t,acc2,color_),grid;title('Entrada  T_L')%,ylim([-0.001 0.01]);
xlabel('Tiempo [Seg.]');
I_max=max([max(x2) abs(min(x2))]);% 0.4291[A]
%La corriente maxima es aquella que se obtiene del cambio en la entrada de 12 a -12
%para el caso sin torque externo
