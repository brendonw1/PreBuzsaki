function targets=complextarget(xycoords,radius,numtargs,varargin);

if nargin==4;
    mode=varargin{1};
elseif nargin==3;
    mode='both';
end
%available modes are 'before', 'after', 'both', 'neither' indicating
%when to put imaging targets relative to stimulation targets

targets=ones(6,numtargs);%set up a matrix for target output... in format necessary to write to vnt file
x=radius*cos((2*pi)*[1:numtargs]./numtargs)+xycoords(1);%calculate x values for going around a circle
y=radius*sin((2*pi)*[1:numtargs]./numtargs)+xycoords(2);%y values
targets(1,:)=x;%put in matrix
targets(2,:)=y;

mode=lower(mode);%put string in lower case to standardize (for comparison)
switch mode
    case 'neither'
    case 'before'
        targets=cat(2,[xycoords(1);xycoords(2);1;1;0;1],targets);%add an imaging target at the beginning of the target list, centered at input point
    case 'after'
        targets=cat(2,targets,[xycoords(1);xycoords(2);1;1;0;1]);%add such a point on the end of the list
    case 'both'
        targets=cat(2,[xycoords(1);xycoords(2);1;1;0;1],targets,[xycoords(1);xycoords(2);1;1;0;1]);%add a point to both the beginning and end
end
            
