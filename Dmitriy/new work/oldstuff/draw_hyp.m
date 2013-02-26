function draw_hyp(n)
%drawhyp(n)
%   Draws a hyperbola approximation diagram with n points

hold on;

for c = 1:n
   plot([0,c],[n-c+1,0]);
   plot([0,c],[-n+c-1,0]);
   plot([0,-c],[n-c+1,0]);
   plot([0,-c],[-n+c-1,0]);
end

plot([0,0],[-n,n]);
plot([-n,n],[0,0]);

axis equal;
set(gca,'Visible','off');
hold off;