function TRANSIENT_FILE(saveFolder,filename,transient,rate,temperature,comment)
%TransientFile Saves transient data to LDLTS compatible iso file
%   Detailed explanation goes here

status = mkdir(strcat(pwd,'\',saveFolder));
fid = fopen(fullfile(strcat(pwd,'\',saveFolder),filename),'wt');
fprintf(fid, '[general]\n');
fprintf(fid, 'software=Laplace DLTS version 3.3.38\n');
fprintf(fid, 'hardware=george\n');
fprintf(fid, 'serial number=078 [321862211]\n');
fprintf(fid, 'user=George\n');
fprintf(fid, 'type=LapDLTS\n');
fprintf(fid, 'source=Laplace DLTS experiment\n');
fprintf(fid, 'date=04-05-2018  15:11\n');  %% TODO: Put in date
fprintf(fid, 'data base=C:\\Laplace Transient Processor\\GeoData\\George.mdb\n');
fprintf(fid, 'data name=transient1\n');
fprintf(fid, 'comment=%s\n', comment);
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
fprintf(fid, 'last sample= %d\n', length(transient)-1);
fprintf(fid, 'Sampling Rate= %d\n', rate);
fprintf(fid, 'No samples= %d\n', length(transient));
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
fprintf(fid, 'No samples= %d\n', length(transient));
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

