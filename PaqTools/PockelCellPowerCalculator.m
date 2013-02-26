function power=PockelCellPowerCalculator(bias,max,current)
% power=PockelCellPowerCalculator(bias,max,current)
% Calculates the current power (0-100%) given the bias and max power.
% Assumes the Pockel Cell transforms the power as a function of sin
% squared.

x=[0 1];
y=[bias max];
p=polyfit(x,y,1);
power=((sin((current/100)*(pi/2))).^2)*p(1)+p(2);
