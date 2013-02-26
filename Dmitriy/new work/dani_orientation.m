function dani_orientation

[filename, pathname] = uigetfile({'*.txt'}, 'Choose file to read');
fnm = strcat(pathname,filename)
fid = fopen(fnm);

st = fgetl(fid);
m = [];
for c = 1:100
    st = fgetl(fid);
    m(c,:) = str2num(st);
end

theta = mean(m(:,1:2),2);
x = m(:,3).*cos(theta);
y = m(:,3).*sin(theta);
[or mag] = orientation([x y],[0 0]);
fprintf(['Orientation: ' num2str(or*180/pi) '\n']);
fprintf(['Magnitude  : ' num2str(mag) '\n']);

fclose('all');