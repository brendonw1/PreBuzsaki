function filt=imagewavelet(image);

[C, S] = wavedec2(image, 6, 'db5');
C(1:(S(1,1)*S(1,2)+S(2,1)*S(2,2)+S(3,1)*S(3,2))+S(4,1)*S(4,2))=0;
sz=size(S);
% C(end-S(size(S,1),1)*S(size(S,1),2)+1:end)=0;%filter out small stuff
filt = waverec2(C, S, 'db5');