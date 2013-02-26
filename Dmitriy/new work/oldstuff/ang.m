function ang = ang(x1,x2,y1,y2)
%ang = ang(x1,x2,y1,y2)
%   Cosine of the dihedral angle between planes X and Y
%   defined by vectors x1, x2 and y1, y2 respectively

x1 = x1/norm(x1);
x2 = x2/norm(x2);
y1 = y1/norm(y1);
y2 = y2/norm(y2);

a1 = x1 + x2;
a1 = a1/norm(a1);
a2 = x1 - x2;
a2 = a2/norm(a2);
b1 = y1 + y2;
b1 = b1/norm(b1);
b2 = y1 - y2;
b2 = b2/norm(b2);

ang = abs(det([sum(a1.*b1) sum(a1.*b2); sum(a2.*b1) sum(a2.*b2)]));