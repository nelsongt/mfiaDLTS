%%  Author:  George Nelson, Copyright 2019 %%

clear
format long
% Setup PATH
addpath(genpath('.\Subroutines'))


%%%%%%% Begin Main %%%%%%
Folder_Name = 'Historic'
%% File read code  % TODO: Clean up by moving to own function
F_dir = strcat('../Data/',Folder_Name,'\*_*.iso');
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat('../Data/',Folder_Name,'\',F(ii).name));

    Header = textscan(fileID,'%s',67,'Delimiter','\n');

    for jj = 1:length(Header{1,1})  % Pull out the sample temp and sampling rate
        if contains(Header{1,1}{jj,1},'temperature=')
            temp_string = strsplit(Header{1,1}{jj,1},'=');
            temperature = str2double(temp_string{1,2});
        elseif contains(Header{1,1}{jj,1},'Sampling Rate=')
            rate_string = strsplit(Header{1,1}{jj,1},'=');
            sampling_rate = str2double(rate_string{1,2});
        end
    end

    Temps(ii) = temperature;
    Data(ii) = textscan(fileID,'%f64');
    ss_caps(ii) = mean(Data{1,ii}(end-50:end));

    total = ii;  % TODO; not needed, can use length(Data)
    fclose(fileID);
end


%for i=1:total
%    Data{1,i} = Data{1,i}(4:end);  % skip hardware recovery points not properly removed, only use if needed
%end


%% Define list of rate windows           NOTE: May need to be changed depending on filter function
rate_window = logspace(log10(18),log10(2000),500);  % auto generate a list
%rate_window = [20,50,100,200,500,1000,2000,5000];  % suggested windows: 20,50,100,200,500,1000,2000,5000
%rate_window = [32,64,128,256];  % also a good list: 16,32,64,256,512,1024
%rate_window = 4;                     % single rate good for plotting

del_cap = zeros(length(rate_window),total);
del_cap_norm = zeros(length(rate_window),total);


%% List of filter functions, one must be used and only one
%[del_cap,del_cap_norm] = weightboxcar(Data,rate_window,sampling_rate,ss_caps,total);    %TODO: Find proper gating and timing
%[del_cap,del_cap_norm] = weightlockin(Data,rate_window,sampling_rate,ss_caps,total);    % Most trusted
%[del_cap,del_cap_norm] = weightexp(Data,rate_window,sampling_rate,ss_caps,total);       % Good for SNR but aliasing at high frequency
[del_cap,del_cap_norm] = weightexpbs(Data,rate_window,sampling_rate,ss_caps,total);     % Best SNR but slowest
%[del_cap,del_cap_norm] = weightsine(Data,rate_window,sampling_rate,ss_caps,total);      % Trusted alternative, decent SNR
%[del_cap,del_cap_norm] = weightcosine(Data,rate_window,sampling_rate,ss_caps,total);    % Recommended for resolution


%% TODO: Re-arrange all data from smallest to largest temperature here



%% Plot FDLTS Spectra
figure
set(gca,'FontSize',11);
hYLabel = ylabel('\DeltaC_0 (fF)','fontsize',14       );
hXLabel = xlabel('Emission rate (Hz)','fontsize',14           );
%ylim([1 140]);
%xlim([0 400]);
hold on;
for jj = 1:length(Temps)
    scatter(rate_window,del_cap(:,jj),5,'filled');
    %plot(sort(Temps),sortBlikeA(Temps,del_cap(jj,:)));
    %plot (Temps,fit_y(jj,:));
end
set(gca,'xscale','log');
% legend stuff %
lgd = legend(num2str(Temps(:)));
title(lgd,'Temperature (K)');
lgd.FontSize = 11;
box on
% end legend stuff %

hold off;

%% Plot CDLTS Spectra
figure
set(gca,'FontSize',11);
hYLabel = ylabel('\DeltaC_0 (fF)','fontsize',14       );
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
title(lgd,'Rate Constant (1/s)')
lgd.FontSize = 11
box on
% end legend stuff %

hold off;



function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end