%%  Author:  George Nelson, Copyright 2019 %%

clear
format long

%% Natural constants
expconst = (exp(-2)-1)/2;


%%%%%%% Begin Main %%%%%%
Folder_Name = 'FGA015_3'
%% File read code  % TODO: Clean up by moving to own function
F_dir = strcat(Folder_Name, '\*_*.iso');
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat(Folder_Name,'\',F(ii).name));

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

%% Experimental constants
%sampling_rate = 107143;  % Critically important and must be correct. MFIA max rate is 107143, half rate is 53571. LDLTS software uses 68000. Higher is better for SNR.

sampling_period = (1 / sampling_rate) * (length(Data{1,1}));



%% Define list of rate windows           NOTE: May need to be changed depending on filter function
%rate_window = logspace(log10(20),log10(110),10);  % auto generate a list
rate_window = [20,50,100,200,500,1000];  % suggested windows: 20,50,100,200,500,1000,2000,5000
%rate_window = [32,64,128,256,512,1024];  % also a good list: 16,32,64,256,512,1024
%rate_window = 20;                     % single rate good for plotting

del_cap = zeros(length(rate_window),total);
del_cap_norm = zeros(length(rate_window),total);


%% List of filter functions, one must be used and only one
%[del_cap,del_cap_norm] = weightboxcar(Data,rate_window,sampling_rate,ss_caps,total);    %TODO: Find proper gating and timing
%[del_cap,del_cap_norm] = weightlockin(Data,rate_window,sampling_rate,ss_caps,total);
[del_cap,del_cap_norm] = weightexp(Data,rate_window,sampling_rate,ss_caps,total,expconst);
%[del_cap,del_cap_norm] = weightsine(Data,rate_window,sampling_rate,ss_caps,total);      % Recommended for SNR
%[del_cap,del_cap_norm] = weightcosine(Data,rate_window,sampling_rate,ss_caps,total);    % Recommended for resolution


%% TODO: Re-arrange all data from smallest to largest temperature here



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
for jj = 1:length(rate_window)
    f = ezfit(Temps, del_cap(jj,:), 'ngauss');
    g = str2sym(f.eq);
    fitvars = symvar(g);
    h = subs(g,fitvars(1:length(f.m)),f.m);
    fit_y(jj,:) = subs(h,fitvars(length(fitvars)),Temps);
    dh = diff(h);
    fit_temps(jj) = solve(dh);
end



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

%% Plot Arrhenius plot
figure
hold on;
set(gca,'FontSize',11)
gYLabel = ylabel('ln(T^2/e)','fontsize',13       );
gXLabel = xlabel('1000/T (K^{-1})','fontsize',13           );
arr_temps = 1000 ./ fit_temps;
arr_emits = log(fit_temps.^2 ./ rate_window);
scatter(arr_temps,arr_emits);
g = ezfit('a*x+b');
box on
showfit(g);
hold off;


figure
plot(sort(Temps),sortBlikeA(Temps,ss_caps));
set(gca,'FontSize',11);
jYLabel = ylabel('Diode Capacitance at Bias (pF)','fontsize',14       );
jXLabel = xlabel('Temp (K)','fontsize',14           );


%% Plot normalized CDLTS Spectra
figure
set(gca,'FontSize',11);
kYLabel = ylabel('|2*N_D*\DeltaC_0/C| (cm^{-3})','fontsize',14       );
%kYLabel = ylabel('|\DeltaC_0/C|','fontsize',14       );
kXLabel = xlabel('Temp (K)','fontsize',14           );
%ylim([10^9 10^15]);
xlim([0 400]);
hold on;
for jj = 1:length(rate_window)
    %scatter(Temps,del_cap_norm(jj,:),5,'filled');
    plot(sort(Temps),2*4e16*abs(sortBlikeA(Temps,del_cap_norm(jj,:))),'LineWidth',2);
    %plot(sort(Temps),abs(sortBlikeA(Temps,del_cap_norm(jj,:))),'LineWidth',2);
    %plot (Temps,fit_y(jj,:));
end
set(gca,'yscale','log');

% legend stuff %
lgd2 = legend(num2str(rate_window(:)));
title(lgd2,'Rate Constant (1/s)')
lgd2.FontSize = 11
box on
% end legend stuff %

hold off;
%%%%%%%% End Main %%%%%%%%


%% Double boxcar weighting routine starts %%
function [DC,DC_norm] = weightboxcar(DATA,RW,SR,SSCAP,TOT)
% Find t1 and t2 for each rate window
t_1 = log(2.5) ./ (RW * 1.5)
sample_1 = int16(t_1 * SR)
t_2 = 2.5 * t_1
sample_2 = int16(t_2 * SR)

% Set boxcar gate width dynamically per rate window
gate_width = 0.125;  % Fraction of period TODO: find proper value, it's in Itratov paper
buffer = int16(0.5*gate_width*sample_2);
%buffer = [20,20,20,20,20,20]
gain = 3;

% Calculate Spectra from Transient data
for jj = 1:length(RW)
    for ii = 1:TOT
        cap_1 = mean(DATA{1,ii}(sample_1(jj)-buffer(jj):sample_1(jj)+buffer(jj)));
        cap_2 = mean(DATA{1,ii}(sample_2(jj)-buffer(jj):sample_2(jj)+buffer(jj)));
        
        DC(jj,ii) = 1000*gain*(cap_2 - cap_1); % convert to fF
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Lock-in Amplifier weighting routine starts %%
function [DC,DC_norm] = weightlockin(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see ftp://gateway.ifpan.edu.pl/pub/Laplace/Common/DLTS_simulation_Boxcar_vs_lock-in.pdf
t_c = 2.083 ./ RW;
sample_c = int16(t_c * SR);

gain = 7.04;  % gain calculated from the filter t_c&t_d, see above pdf

lockfun_data = [];

% integrate S(smpl) * W(smpl - smpl_1) d_smpl from 0 to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear lockfun_data;
        lockfun_data = zeros(sample_c(jj),1);
        for kk = 1:sample_c(jj)
            lockfun_data(kk) = lockinfun(kk,RW(jj),SR);
        end
        DC(jj,ii) = 1000*gain*trapz(DATA{1,ii}(1:sample_c(jj)).*lockfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Exponential correlator weighting routine starts %%
function [DC,DC_norm] = weightexp(DATA,RW,SR,SSCAP,TOT,ECONST)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
t_d = 0.082 ./ (0.444 .* RW);  % seconds
t_c = 1 ./ (0.444 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 19.2;  % gain calculated from the filter t_c&t_d by George via numerical integration

expfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear expfun_data;
        expfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            expfun_data(kk+1) = expfun(kk+sample_d(jj),sample_d(jj),sample_c(jj),ECONST);
        end
        DC(jj,ii) = -1000*gain*trapz(DATA{1,ii}(sample_d(jj):(sample_d(jj)+sample_c(jj))).*expfun_data) / double(sample_c(jj));
        
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Sine weighting routine starts %%
function [DC,DC_norm] = weightsine(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
t_d = 0; % seconds
t_c = 1 ./ (0.424 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 7.92;  % gain calculated from the filter t_c&t_d by George via numerical integration

sinfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear sinfun_data;
        sinfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            sinfun_data(kk+1) = sinefun(kk,sample_c(jj));
        end
        DC(jj,ii) = -1000*gain*trapz(DATA{1,ii}(1:(sample_c(jj)+1)).*sinfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Cosine weighting routine starts %%
function [DC,DC_norm] = weightcosine(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
t_d = 0.032 ./ (0.185 .* RW);  % seconds
t_c = 1 ./ (0.185 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 15.2;  % gain calculated from the filter t_c&t_d by George via numerical integration

cosfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear cosfun_data;
        cosfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            cosfun_data(kk+1) = cosinefun(kk+sample_d(jj),sample_d(jj),sample_c(jj));
        end
        DC(jj,ii) = -1000*15.2*trapz(DATA{1,ii}(sample_d(jj):(sample_d(jj)+sample_c(jj))).*cosfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Actual Weighting Functions %%
function w = lockinfun(sample,RW,SR)
% Find t1,t2,t3,t4 for each rate window (RW*total_samples = 2.08)
t4 = 2.083 / RW;
sample4 = int16(t4 * SR);
t3 = 0.6 * t4;
sample3 = int16(t3 * SR);
t2 = 0.5 * t4;
sample2 = int16(t2 * SR);
%t1 = 0.1 * t4;
sample1 = sample2 - (sample4 - sample3); % gate width the same, no rounding error TODO: Define gate width using sample 1&2 or 3&4?

if (sample < sample1)
    w = 0;
elseif (sample < sample2)
    w = -1;
elseif (sample < sample3)
    w = 0;
elseif (sample < sample4)
    w = 1;
elseif (sample == sample4)
    w = 0;
else
    w = 'thats a bad'
end
end

function w = expfun(sample,sd,sc,econst)
% Weighting function w = exp(-2*t_norm) + [exp(-2) - 1]/2  (there's a sign mistake in Istratov paper)
%t_norm = (t - td)/tc;

if (sample < sd)
    w = 'thats a bad'
elseif (sample <= (sd+sc))    
    w = exp(-2*((double(sample) - double(sd))/double(sc))) + econst;
elseif (sample > (sd+sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end

function w = sinefun(sample,sc)
% Weighting function w = sin(2pi*t_norm)
%t_norm = (t - td)/tc;

if (sample < 0)
    w = 'thats a bad'
elseif (sample <= (sc))    
    w = sin(2*pi()*(double(sample)/double(sc)));
elseif (sample > (sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end

function w = cosinefun(sample,sd,sc)
% Weighting function w = w = sin(2pi*t_norm)
%t_norm = (t - td)/tc;

if (sample < sd)
    w = 'thats a bad'
elseif (sample <= (sd+sc))    
    w = cos(2*pi()*((double(sample) - double(sd))/double(sc)));
elseif (sample > (sd+sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end

function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end
