function drawtube(x, y, xold, yold, D, Dold, sp)

% Let's compute the four points of the rectangle..

Rold = Dold * 0.5;
R    = D    * 0.5;


if ((x-xold)==0), 
 a = [ xold + Rold, yold];
 b = [ xold - Rold, yold];
 c = [ x + R, y];
 d = [ x - R, y]; 

% plot([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],'o');
 patch([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],[0 0 0]);
 if (sp)
  hold on;   
  RRR = rectangle('Position', [xold - Rold, yold - Rold, 2*Rold, 2*Rold]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  RRR = rectangle('Position', [x - R, y - R, 2*R, 2*R]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  hold off;
 end 
 return;
end


if ((y-yold)==0), 
 a = [ xold, yold + Rold];
 b = [ xold, yold - Rold];
 c = [ x, y + R];
 d = [ x, y - R]; 
 
% plot([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],'o');
 patch([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],[0 0 0]);
 if (sp)
  hold on;   
  RRR = rectangle('Position', [xold - Rold, yold - Rold, 2*Rold, 2*Rold]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  RRR = rectangle('Position', [x - R, y - R, 2*R, 2*R]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  hold off;
 end 
 return;
end

m = (y-yold) / (x-xold);
n = -1./m;

 a = [ xold + Rold/sqrt(1+n^2), n * Rold/sqrt(1+n^2) + yold];
 b = [ xold - Rold/sqrt(1+n^2), -n* Rold/sqrt(1+n^2) + yold];
 c = [ x    + R/sqrt(1+n^2), n * R/sqrt(1+n^2) + y];
 d = [ x    - R/sqrt(1+n^2), -n* R/sqrt(1+n^2) + y]; 
 
% plot([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],'o');
 patch([a(1), b(1), d(1), c(1)], [a(2), b(2), d(2), c(2)],[0 0 0]);
 if (sp)
  hold on;   
  RRR = rectangle('Position', [xold - Rold, yold - Rold, 2*Rold, 2*Rold]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  RRR = rectangle('Position', [x - R, y - R, 2*R, 2*R]);
  set(RRR, 'Curvature', [1 1], 'FaceColor', [0 0 0], 'EdgeColor', [0 0 0]);
  hold off;
 end 
return;
