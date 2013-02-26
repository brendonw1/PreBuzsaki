function model_spike = model_spike(time,variance,threshold)
%model_spike(time,variance,threshold)
%  generates a model cell recording

m = randn(1,time);
m = m * variance - 70;
j = find(m>threshold);
m(j) = m(j) + (40-mean(m(j)));
model_spike = m;