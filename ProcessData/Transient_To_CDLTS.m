%%  Author:  George Nelson, Copyright 2021 %%

clear
format long
% Setup PATH
addpath(genpath('.\Subroutines'))


%%%%%%% Begin Main %%%%%%
Folder_Name = 'GAP500-3_Pre';

[Sample_Name,Data,Temps,ss_caps,sampling_rate] = FolderRead(Folder_Name,'iso');
total = length(Data);

%for i=1:total
%    Data{1,i} = Data{1,i}(10:end);  % skip hardware recovery points not properly removed, only use if needed
%end

%% Define list of rate windows           NOTE: May need to be changed depending on weighting function
%rate_window = logspace(log10(20),log10(1000),100);  % auto generate a list
rate_window = [20,50,100,200,500,1000];  % suggested windows: 20,50,100,200,500,1000,2000,5000
%rate_window = [16,32,64,128,256,512];  % also a good list: 16,32,64,256,512,1024
%rate_window = 20;                     % single rate good for plotting

% Initialize matrices
del_cap = zeros(length(rate_window),total);
del_cap_norm = zeros(length(rate_window),total);


%% List of weighting functions, one must be used and only one
%[del_cap,del_cap_norm] = weightboxcar(Data,rate_window,sampling_rate,ss_caps,total);    %TODO: Find proper gating and timing
%[del_cap,del_cap_norm] = weightlockin(Data,rate_window,sampling_rate,ss_caps,total);    % Most trusted
%[del_cap,del_cap_norm] = weightexp(Data,rate_window,sampling_rate,ss_caps,total);       % Good for SNR but aliasing at high frequency
[del_cap,del_cap_norm] = weightexpaa(Data,rate_window,sampling_rate,ss_caps,total);     % Best SNR, slowest. Default
%[del_cap,del_cap_norm] = weightsine(Data,rate_window,sampling_rate,ss_caps,total);      % Alternative, decent SNR
%[del_cap,del_cap_norm] = weightcosine(Data,rate_window,sampling_rate,ss_caps,total);    % Supposed to be good for resolution


%% Re-arrange all data from smallest to largest temperature
for nn = 1:length(rate_window)
    del_cap(nn,:) = sortBlikeA(Temps,del_cap(nn,:));
    del_cap_norm(nn,:) = sortBlikeA(Temps,del_cap_norm(nn,:));
end
ss_caps = sortBlikeA(Temps,ss_caps);
Temps = sort(Temps);


%% Write to spectra data file
SpectraFile(Sample_Name,Folder_Name,rate_window,Temps,ss_caps,del_cap);


%%%% PLOTTING %%%%

%% Fit each spectrum     % TODO: Find a way to fit only a certain range of data
%for jj = 1:length(rate_window)
%    figure
%    hold on
%    scatter(Temps,del_cap(jj,:),5,'filled');
%    f = ezfit('gauss');
%    fit_y(jj,:) = f.m(1)*exp(-((Temps-f.m(3)).^2)/(2*f.m(2).^2))';
%    fit_temps(jj) = f.m(3);
%    hold off
%    close
%end
%for jj = 1:length(rate_window)
%    f = ezfit(Temps, del_cap(jj,:), 'ngauss');
%    g = str2sym(f.eq);
%    fitvars = symvar(g);
%    h = subs(g,fitvars(1:length(f.m)),f.m);
%    fit_y(jj,:) = subs(h,fitvars(length(fitvars)),Temps);
%    dh = diff(h);
%    fit_temps(jj) = solve(dh);
%end



%% Plot CDLTS Spectra
figure
set(gca,'FontSize',11);
hYLabel = ylabel('\DeltaC (fF)','fontsize',14       );
hXLabel = xlabel('Temp (K)','fontsize',14           );
%ylim([1 140]);
%xlim([0 400]);
hold on;
for jj = 1:length(rate_window)
    scatter(Temps,(del_cap(jj,:)),5,'filled');
    %plot(sort(Temps),sortBlikeA(Temps,del_cap(jj,:)));
    %plot (Temps,fit_y(jj,:));
end
%set(gca,'yscale','log');
% legend stuff %
lgd = legend(num2str(rate_window(:)));
title(lgd,'Rate Constant (1/s)');
lgd.FontSize = 11;
box on
% end legend stuff %

hold off;

%% Plot Arrhenius plot
%figure
%hold on;
%set(gca,'FontSize',11)
%gYLabel = ylabel('ln(T^2/e)','fontsize',13       );
%gXLabel = xlabel('1000/T (K^{-1})','fontsize',13           );
%arr_temps = 1000 ./ fit_temps;
%arr_emits = log(fit_temps.^2 ./ rate_window);
%scatter(arr_temps,arr_emits);
%g = ezfit('a*x+b');
%box on
%showfit(g);
%hold off;

%% Plot steady-state capacitance
figure
plot(Temps,ss_caps);
set(gca,'FontSize',11);
jYLabel = ylabel('Diode Capacitance at Bias (pF)','fontsize',14       );
jXLabel = xlabel('Temp (K)','fontsize',14           );
%set(gca,'yscale','log');


%% Plot normalized CDLTS Spectra
figure
set(gca,'FontSize',11);
%kYLabel = ylabel('|2*N_D*\DeltaC/C| (cm^{-3})','fontsize',14       );
kYLabel = ylabel('|\DeltaC/C|','fontsize',14       );
kXLabel = xlabel('Temp (K)','fontsize',14           );
%ylim([10^9 10^15]);
xlim([0 400]);
hold on;
for jj = 1:length(rate_window)
    %scatter(Temps,del_cap_norm(jj,:),5,'filled');
    %plot(Temps,2*1e15*abs(del_cap_norm(jj,:)),'LineWidth',2);
    plot(Temps,del_cap_norm(jj,:),'LineWidth',2);
    %plot (Temps,fit_y(jj,:));
end
%set(gca,'yscale','log');

 %legend stuff %
lgd2 = legend(num2str(rate_window(:)));
title(lgd2,'Rate Constant (1/s)');
lgd2.FontSize = 11;
box on
 %end legend stuff %
hold off;

%%%%%%%% End Main %%%%%%%%


function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end