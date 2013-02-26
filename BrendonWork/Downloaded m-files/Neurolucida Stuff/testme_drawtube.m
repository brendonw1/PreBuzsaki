N = 100;

x = rand(10) * 100.;
y = rand(10) * 100.;
d = rand(10) * 10.;


X = rand(10) * 100.;
Y = rand(10) * 100.;
D = rand(10) * 10.;


for i=1:N-1,
 clf;
 hold on;
 drawtube(x(i),y(i),X(i),Y(i),5, 5);%d(1),D(1));
 plot(x(i),y(i),'ro',X(i),Y(i),'ro');
 set(gca, 'XLim', [0 150], 'YLim', [0 150]);
 axis square;
 pause;
end

