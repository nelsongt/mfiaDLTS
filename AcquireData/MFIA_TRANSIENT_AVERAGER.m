function [averagedTransient] = MFIA_TRANSIENT_AVERAGER(capArray,SR,TrnsLength)

%TrnsLength = 8;
%SR = 837.1;
%capArray = sampleCap;
%**************************************************************************
%   DLTS_TRANSIENT_PREPARATION
%   Author: Antonio Braga, Zurich Instruments
%   May 19, 2015
%   Updated by George Nelson, May 2018
%
%   This script takes one single recorded waveform with multiple transients 
%   and average them to obtain a single averaged transient. The series of 
%   transient is saved using DLTS_TRANSIENT_SAVE function. Each series 
%   represents the measurement at one temperature. It is possible to take
%   several transient waveforms recorded at the same temperature and
%   average them. (See below example)
%
%   Transients_***K: the sampleY variable from the DLTS_TRANSIENT_SAVE
%   function. Transient waveforms at different temperature meassurement must 
%   be assigned to different names.
%
%   SR: Transient waveform sample rate. SR should be the same as the Fs 
%   variable used in DLTS_TRANSIENT_SAVE function
%**************************************************************************

numSamples = SR*TrnsLength;  %length of transient in data points
rejectSamples = 4;  %length of hardware recovery in data points, generally first 80-100 usec of data if using George's suggested MFIA settings
realNumSamp = floor(numSamples - rejectSamples);
time = linspace(1/SR,(1/SR)*realNumSamp,realNumSamp);

% Average Transients_***K_A, Transients_***K_B, Transients_***K_C, etc.
% from the same temperature measurement 
% You may want to record transients at the same temperature in different 
% variables for more data points.

% example with two set of transients at 240K
% catenate two transients
Set_of_transients = capArray*1e12; %horzcat(Transients_240K_A, Transients_240K_B); 

% Count the number of pulses in the Set_of_transients
dummy_Set_of_transients = Set_of_transients;

% Find edges of pulse code:
% vth will define the value where each transient starts in order to overalap all
% transients for averaging later
% Automated edge code:
[counts,edges] = histcounts(Set_of_transients);
[peaks,locations] = findpeaks(counts,edges(1:end-1));
sorted_locs = sortBlikeA(peaks,locations);
vth = mean(sorted_locs(1:2))
%vth = 5.975; % manual value chosen by user in between pulse cap and ss cap

% all points below vth are discarded
dummy_Set_of_transients(1:length(Set_of_transients))=sign(Set_of_transients(1:length(Set_of_transients))-vth);
% number of peaks will indicate the number of transients obtained
[~,find_number_of_pulses] = findpeaks(diff(-1*dummy_Set_of_transients));   % TODO: Automate change sign for forward bias pulsing
Number_of_pulses=find_number_of_pulses;
for i=2:length(find_number_of_pulses)
    if find_number_of_pulses(i)-find_number_of_pulses(i-1)>(numSamples+5);  % TODO: Add pulse width here...
        Number_of_pulses(i)=find_number_of_pulses(i-1);
    else Number_of_pulses(i)=0;
    end
end
Number_of_pulses(Number_of_pulses==0) = [];  %this removes pulses that are not longer than the expected numSamples

% Returns all the transients measured
for ii = 1:length(Number_of_pulses)-1
    zint_i=int32(Number_of_pulses(ii)+rejectSamples);  %gets rid of junk at beginning
    zint_f=int32(numSamples+Number_of_pulses(ii));
    eval(['Trns' num2str(ii) '= Set_of_transients(zint_i:zint_f);']);    
end

% Transient averaging & plotting
close all
figure;
hold on;
color = summer(length(Number_of_pulses)-1);
sum =zeros(int32(realNumSamp),length(Number_of_pulses)-1);
for z = 1:length(Number_of_pulses)-1
    eval(['y = Trns' num2str(z) ';']);
    int_i = 1;
    int_f = int32(realNumSamp);
    eval(['Trns' num2str(z) '= Trns' num2str(z) '(int_i:int_f);']);
    str = eval(['Trns' num2str(z) ';']);
    plot(time,str,'Color',color(z,:))
    hold on
    sum(:,z) = str;
end


xlabel('Time (s)','fontsize',20);
ylabel('Capacitance (pF)','fontsize',20);
title('Average transient','fontsize',28);

% Overlap the averaged tranisent 
averagedTransient = nanmean(sum.');%sum / (length(Number_of_pulses)-1);
plot(time,averagedTransient,'r');
hold off;

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