function [X]=modmotor2(t_etapa, xant, accion1,accion2,Laa,J,Ra,B,Ki,Km)
%Laa=366e-6; J=5e-9;Ra=55.6;B=0;Ki=6.49e-3;Km=6.53e-3;
Va=accion1;
Tl=accion2;
u=[Va;Tl];
h=1e-7;
theta=xant(3);
omega= xant(2);
I=xant(1);
%xant=[xant(1); xant(2); xant(3)];

%Matrices de espacio de estados
A=[-Ra/Laa -Km/Laa 0; Ki/J -B/J 0; 0 1 0];
B=[1/Laa 0; 0 -1/J; 0 0]; 
C1=[1 0 0];%muestra corriente
C2=[0 1 0];%muestra velocidad angular
%C3=[0 0 1];%muestra angulo

for ii=1:t_etapa/h
 xp=A*xant + B*u;
 wp=C2*xp;
 Ip=C1*xp;
 omega=omega+h*wp;
 theta=theta+h*omega;
 I = I + h*Ip;
end
X=[I ;omega; theta];
end