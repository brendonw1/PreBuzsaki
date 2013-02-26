function [yt, lmax]=boxcox(a, lambda)

%function to do a Box-Cox transformation
%by Emiliano Rial Verde. 11/19/2002. Modified 07/24/2003.
%
%Finds the optimal lambda parameter 
%Plots L vs lambda
%transforms the data in the vector a using the "best" lambda
%If lambda is omitted a default between -4 and 4 is set with 0.001 interval
%Lambda should ve a vector of this form: lambda=x:interval:y, 
%	where x and y are the min and max lambdas to try
%
%Ref.: "Biometry" (Third Ed.) R.R. Sokal and F.J. Rohlf
%      W.H. Freeman and Co., New York. 1995.

b=max(size(a));
y=reshape(a,b,1);
v=size(y,1)-1;
n=size(y,1);

if (nargin==2) & ~isempty(lambda)
else
   lambda=-4:0.001:4;
end

c=max(size(lambda));

ytrans=(repmat(y,1,c).^repmat(lambda,b,1))-1;
for i=1:c
   if lambda(i)==0
      ytrans(:,i)=log(y);
   else
      ytrans(:,i)=ytrans(:,i)./lambda(i);
   end
end

ytransvar=var(ytrans);
firstterm=(-v/2).*log(ytransvar);

lny=log(y);
secondterm=(lambda-1).*(v/n)*sum(lny);

%Log-likelihood calculation
l=firstterm+secondterm;
lmax=max(l);
lambdamax=lambda(1,find(l==lmax));

% 95% confidence intervals of lambda.
interval=lmax-(chisqq(.95,1)/2);
lmaxindex=find(l==lmax);
lambdamin95=interp1(l(1:lmaxindex),lambda(1:lmaxindex),interval, 'nearest');
lambdamax95=interp1(l(lmaxindex:end),lambda(lmaxindex:end),interval, 'nearest');
lambdamin95index=find(lambda==lambdamin95);
lambdamax95index=find(lambda==lambdamax95);

%Help text
helptext='Lambda=1 gives a simple linear transformation. When the 95% confidence intervals of lambda include lambda=1, a transformation is not necessary for that data. In the other cases, a transformation using lambda_max will give a distribution closer to the normal distribution.';
helptitle='Box-Cox transformation help';
h=msgbox(helptext, helptitle, 'help', 'replace');
set(h, 'units', 'normalized', ...
   'position', [ 0.005859375 0.05078125 0.416015625 0.143229166666667 ]);


%Plot
lplot=plot(lambda,l);
ylabel('Log-likelihood (L)');
xlabel('\lambda');
hold on;
plot(lambdamax, lmax, 'ok', 'markerfacecolor', 'k', 'markeredgecolor', 'k');
plot(lambdamin95, l(lambdamin95index), 'ok', 'markerfacecolor', 'k', 'markeredgecolor', 'k');
plot(lambdamax95, l(lambdamin95index), 'ok', 'markerfacecolor', 'k', 'markeredgecolor', 'k');
line([lambdamax lambdamax],[min(get(gca,'ylim')) lmax], 'color', 'k');
line([lambdamin95 lambdamin95],[min(get(gca,'ylim')) l(lambdamin95index)], 'color', 'k');
line([lambdamax95 lambdamax95],[min(get(gca,'ylim')) l(lambdamin95index)], 'color', 'k');
title(['L_m_a_x=', num2str(lmax), '. \lambda_m_a_x=', num2str(lambdamax), '. \lambda_1_(_0_._9_5_)=', num2str(lambdamin95), '. \lambda_2_(_0_._9_5_)=', num2str(lambdamax95)]);
hold off;

%Transformed data
yt=ytrans(:,lmaxindex);