function [averagedTransient] = MFIA_TRANSIENT_AVERAGER(capArray,SR,TrnsLength)
%capArray = sampleCap;
%SR = sample_rate;
%TrnsLength = sample_period-pulse_width;
%   By George Nelson, Oct 2019

capArray_pF = capArray*1e12;
transients = size(capArray_pF,1);
numSamples = size(capArray_pF,2);  %length of transient in data points
rejectSamples = 5;  %length of hardware recovery in data points, generally first 80-100 usec of data if using George's suggested MFIA settings
realNumSamp = numSamples - rejectSamples;
time = linspace(1/SR,(1/SR)*realNumSamp,realNumSamp);



% Transient averaging & plotting
close all
figure;
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
figure;
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

function C = sortBlikeA(A,B)
    [~,Asort]=sort(A,'descend'); %Get the order of B
    C=B(Asort);
end