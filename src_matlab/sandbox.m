% clear
% 
% load('D:\ATOMIX\Data\RDI4beam_TidalChannel_GP130620BPb\L3.mat')
% %%
% L4 = calc_level4_ATOMIX(L3,optionsLev4);


clear
close all


x = linspace(0, 2.5, 15); % Create Data
% y = 2 + 3*x.^2 + 5*randn(size(x)); % Create Data
y = 2+3*x + 5*randn(size(x));


xhat = linspace(min(x), max(x))'; % Optional High-Resolution Vector
mdl = fitlm(x,y,'linear');
[yhat ci] = predict(mdl,xhat,'Alpha',0.05);

figure(1)
plot(x, y, 'bp')
hold on
plot(xhat,yhat,'linewidth',2)
plot(xhat,ci,'k')
grid on 

X = [ones(size(x')) x'];
[b,bint] = regress(y',X);
[top_int, bot_int,xfit,yfit] = plot_CI_regression_line(0.95,b,x,y,struct());

plot(xfit,yfit,'--r','linewidth',2)
hold all
plot(xfit,bot_int,'b')
plot(xfit,top_int,'b')

% determine confidence limits
% determine confidence limits
xi = x;
y_hat = b(2)*xi+b(1);
        n = length(xi);
        s2 = (y-y_hat)*(y-y_hat)'/(n-2); %variance of the residuals (eqn given by Keith)
        xfit = 0:0.01:max(xi);
        X0 = [ones(size(xfit')) xfit'];
        Y0 = X0*b;
        sigma_Y0 = NaN*ones(size(Y0));
        for ii = 1:length(xfit)
            sigma_Y0(ii) = sqrt(X0(ii,:)*inv(X'*X)*X0(ii,:)'*s2);
        end
        % confidence intervals (95% - assuming normal dist)
        yfit = Y0;
        ylow = Y0 - 1.96*sigma_Y0; % lower confidence limit
        yupp = Y0 + 1.96*sigma_Y0; % upper confidence limit
        
        
        plot(xfit,ylow,'m')
        plot(xfit,yupp,'m')