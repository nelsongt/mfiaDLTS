%%%%% Copyright George Nelson 2020 %%%%%

clear
format long
% Setup PATH
addpath(genpath('.\Subroutines'))

%%%%%%% Begin Main %%%%%%
Folder_Name = 'GAP500-IV-Post400K-YSpec'

[Sample_Name,Data,Temps,ss_caps,sampling_rate] = FolderRead(Folder_Name,'dat');
total = length(Data);

Data = sortBlikeA(Temps,Data);
Temps = sort(Temps);

%% Plotting
color = jet(length(Data));

% Capacitance plot
figure
for i = 1:length(Data)
    semilogx(Data{1,i}(:,1),Data{1,i}(:,3)*1e12,'Color',color(i,:));
    hold on;
end
colormap(color);
h = colorbar;
caxis([Temps(1) Temps(length(Temps))]);
ylabel(h, 'Temperature (K)');
xlabel('Frequency (Hz)','fontsize',14);
ylabel('Capacitance (pF)','fontsize',14);
hold off;

% Conductance plot
figure
for i = 1:length(Data)
    semilogx(Data{1,i}(:,2),Data{1,i}(:,4)./Data{1,i}(:,2),'Color',color(i,:));
    hold on;
end
colormap(color);
h = colorbar;
caxis([Temps(1) Temps(length(Temps))]);
ylabel(h, 'Temperature (K)');
xlabel('Angular Frequency (Rad/s)','fontsize',14);
ylabel('Conductance/Frequency (C/V)','fontsize',14);
hold off;



function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end