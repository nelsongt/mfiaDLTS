function [averagedTransient] = MFIA_TRANSIENT_AVERAGER_DAQ(capArray,mfia)
%capArray = sampleCap;
%SR = sample_rate;
%TrnsLength = sample_period-pulse_width;
%   By George Nelson, Oct 2019

SR = mfia.sample_rate;
capArray_pF = capArray*1e12;
transients = size(capArray_pF,1);
numSamples = size(capArray_pF,2);  %length of transient in data points
calcRejectSamples = floor(16*mfia.time_constant*SR); %calculation of hardware recovery, derived from the MFIA user manual sect. 6.4.2 for 99% recovery using 8th order filter
extraRejectSamples = 1; %if empirically it is seen that more data points should be rejected beyond the above calculation, add the extra # of points here
rejectSamples = calcRejectSamples + extraRejectSamples;  %length of hardware recovery in data points
realNumSamp = numSamples - rejectSamples;
time = linspace(1/SR,(1/SR)*realNumSamp,realNumSamp);



% Transient averaging & plotting
close all
figure('Position',[200,500,500,375]);
hold on;
color = summer(transients);
sum = zeros(realNumSamp,transients-1);
int_i = 1+rejectSamples;
int_f = numSamples;
for z = 1:transients-1   % TODO first transient is always lead by NaN?
    transient = capArray_pF(z+1,int_i:int_f);
    plot(time,transient,'Color',color(z,:))
    hold on
    sum(:,z) = transient;
end


xlabel('Time (s)','fontsize',20);
ylabel('Capacitance (pF)','fontsize',20);
title('Average transient','fontsize',28);

% Overlap the averaged tranisent 
averagedTransient = nanmean(sum.');
plot(time,averagedTransient,'r');
hold off;

% Semilog plot
figure('Position',[700,500,500,375]);
hold on;
semilogx(averagedTransient);
set(gca, 'XScale', 'log','xlim',[1 realNumSamp]);
ax1 = gca;
ax1_pos = ax1.Position;
ax1.XLabel.String = 'Samples';
ax1.YLabel.String = 'Capacitance (pF)';
pos=get(gca,'position');  % retrieve the current values
pos(4)=0.95*pos(4);       % try reducing height 5%
set(gca,'position',pos);  % write the new values
ax2 = axes('Position',ax1.Position,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'xlim',[1/SR (1/SR)*realNumSamp],...
    'XScale','log',...
    'Color','none',...
    'ytick',[]);
ax2.XLabel.String = 'Time (s)';
hold off;
end
