%% Author: George Nelson, Copyright 2019 %%

clear

%%% Constants %%%
k_B = 8.617e-5; % eV/K, Boltzmann

N_d = 2e16; % cm^-3, doping concentration

%C_0 = [35.63 35.69 35.72 35.75 35.78 35.80]; % pF, background capacitance
C_0 = ones(1,81)*38;
N_t = [2e14 1.0e14 0.8e14 3e14]; % cm^-3, trap density, in cm^-3
E_t = [0.1 0.28 0.33 0.6]; % eV, trap energy
sigma = [0.3e-16 5e-16 30e-16 600e-16]; % cm^-2, capture cross section

gamma = 6e21; % material constants, body factor

peak_height = 0.2; % pF, measured peak height


%%% Variables %%%
t = linspace(0.000001,0.14705,10000);  % sec, time
%T = [142 146.3 149.8 153.1 156 159.2];  % K, temperature
T = linspace (120,200,81);

sample_rate = length(t) / t(length(t));



%%%%%   Main   %%%%%

for j=1:length(T)
    MinusFactor = zeros(length(T),length(t));
    for i=1:length(N_t)
        tau(i) = exp(E_t(i)/(k_B*T(j))) / (gamma*sigma(i)*T(j)^2);
        MinusFactor = MinusFactor + ((N_t(i)/(2*N_d))*(exp(-t/tau(i))));
    end
    C(j,:) = C_0(j) * (1 - MinusFactor(j,:));
end
%C = C_0 * (1 - ((N_t/(2*N_d))*(exp(-t/tau))));

figure
%xlim([0 1.6])
%ylim([C_0(length(C_0))-3*peak_height C_0(length(C_0))]);
hold on;
plot(t,C)
hold off;

% Write File %
for i=1:length(T)
    file_string = strcat('transient_',num2str(round(T(i))),'K.iso');
    TransientFile(file_string,C(i,:),sample_rate,length(t),T(i));
end



function TransientFile(filename,transient,rate,samples,temperature)
fid = fopen(filename,'w');
fprintf(fid, 'software=Laplace DLTS version 3.3.38\n');
fprintf(fid, 'hardware=george\n');
fprintf(fid, 'serial number=078 [321862211]\n');
fprintf(fid, 'user=George\n');
fprintf(fid, 'type=LapDLTS\n');
fprintf(fid, 'source=Laplace DLTS experiment\n');
fprintf(fid, 'date=04-05-2018  15:11\n');  %% TODO: Put in date
fprintf(fid, 'data base=C:\\Laplace Transient Processor\\GeoData\\George.mdb\n');
fprintf(fid, 'data name=transient1\n');
fprintf(fid, 'comment=simulated\n');
fprintf(fid, '[sample]\n');
fprintf(fid, 'Material=In0.5GaAs\n');
fprintf(fid, 'Identifier=17R511-1 C1S47\n');
fprintf(fid, 'area= .25\n');
fprintf(fid, 'effective mass= .041\n');
fprintf(fid, 'dielectric constant= 13.9\n');
fprintf(fid, 'No Bias Capacitance= 130\n');
fprintf(fid, 'Bias Capacitance= 68.12258\n');
fprintf(fid, '[capacitance meter]\n');
fprintf(fid, 'range= 300\n');
fprintf(fid, '[generator]\n');
fprintf(fid, 'bias=-.8\n');
fprintf(fid, '1st Pulse Bias=-.3\n');
fprintf(fid, '2nd Pulse Bias=-.8\n');
fprintf(fid, 'Injection Pulse Bias=0\n');
fprintf(fid, '1st Pulse Width= .01\n');
fprintf(fid, '2nd Pulse Width= .01\n');
fprintf(fid, 'Injection Pulse Width= .001\n');
fprintf(fid, '2nd pulse=off\n');
fprintf(fid, '2nd pulse interlacing= 10\n');
fprintf(fid, 'Injection pulse=off\n');
fprintf(fid, 'Like Pulse1=on\n');
fprintf(fid, 'Extra delay added=off\n');
fprintf(fid, 'Extra Delay Value= .001\n');
fprintf(fid, '[acquisition]\n');
fprintf(fid, 'first sample= 0\n');
fprintf(fid, 'last sample= %d\n', samples-1);
fprintf(fid, 'Sampling Rate= %d\n', rate);
fprintf(fid, 'No samples= %d\n', samples);
fprintf(fid, 'No scans= 150\n');
fprintf(fid, 'gain= 1\n');
fprintf(fid, '[parameters]\n');
fprintf(fid, 'Sampling Rate= %d\n', rate);
fprintf(fid, 'capacitance meter range= 300\n');
fprintf(fid, 'bias=-.8\n');
fprintf(fid, '1st Pulse Bias=-.3\n');
fprintf(fid, '2nd Pulse Bias=-.8\n');
fprintf(fid, 'Injection Pulse Bias=0\n');
fprintf(fid, '1st Pulse Width= .01\n');
fprintf(fid, '2nd Pulse Width= 0\n');
fprintf(fid, 'Injection Pulse Width= 0\n');
fprintf(fid, 'Extra Delay Value= .001\n');
fprintf(fid, 'No samples= %d\n', samples);
fprintf(fid, 'No scans= 150\n');
fprintf(fid, 'gain= 1\n');
fprintf(fid, 'Bias Capacitance= 68.12258\n');
fprintf(fid, 'CurrentTransient=off\n');
fprintf(fid, 'temperature= %f\n', temperature);
fprintf(fid, 'temperatureSet= %d\n', round(temperature));
fprintf(fid, 'magnetic field= 0\n');
fprintf(fid, 'pressure= 0\n');
fprintf(fid, 'illumination= 0\n');
fprintf(fid, '[noise]\n');
fprintf(fid, 'level= 2.049163E-02\n');
fprintf(fid, '\n');
fprintf(fid, '[data]\n');
for i=1:length(transient)
    fprintf(fid, ' %f \n', transient(i)');
end
fclose(fid);
end
