function [X]=modmotor_pid(t_etapa, xant, accion)
Laa=366e-6; J=5e-9;Ra=55.6;B=0;Ki=6.49e-3;Km=6.53e-3;
Va=accion;
u=Va;
h=1e-7;
omega= xant(1);
wp= xant(2);
theta= xant(3);
%xant=[xant(1); xant(2); xant(3)];
for ii=1:t_etapa/h
 wpp =(-wp*(Ra*J+Laa*B)-omega*(Ra*B+Ki*Km)+Va*Ki)/(J*Laa);
 wp=wp+h*wpp;
 omega = omega + h*wp;
 theta= theta+h*omega;
end
X=[omega;wp;theta];
end