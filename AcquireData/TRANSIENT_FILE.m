function TRANSIENT_FILE(sample,mfia,currentNum,setTemperature,avgTemperature,transient)
%TransientFile Saves transient data to LDLTS compatible iso file
%   Detailed explanation goes here
fileName = strcat(sample.name,'_',num2str(currentNum),'_',num2str(setTemperature),'.iso');
fileDate = datestr(now,'dd-mm-yyyy  HH:MM');

status = mkdir(strcat(pwd,'\',sample.save_folder));
fid = fopen(fullfile(strcat(pwd,'\',sample.save_folder),fileName),'wt');
fprintf(fid, '[general]\n');
fprintf(fid, 'software=Laplace DLTS version 3.3.38\n');
fprintf(fid, 'hardware=mfiaDLTS\n');
fprintf(fid, 'serial number=000 [000000000]\n');
fprintf(fid, 'user=%s\n', sample.user);
fprintf(fid, 'type=LapDLTS\n');
fprintf(fid, 'source=Laplace DLTS experiment\n');
fprintf(fid, 'date=%s\n', fileDate);  
fprintf(fid, 'data base=C:\\Path\\To\\Database.mdb\n');
fprintf(fid, 'data name=%s\n', fileName);
fprintf(fid, 'comment=%s\n', sample.comment);
fprintf(fid, '[sample]\n');
fprintf(fid, 'Material=%s\n', sample.material);
fprintf(fid, 'Identifier=%s\n', sample.name);
fprintf(fid, 'area= %s\n', sample.area);
fprintf(fid, 'effective mass= .041\n');
fprintf(fid, 'dielectric constant= 13.9\n');
fprintf(fid, 'No Bias Capacitance= 130\n');
fprintf(fid, 'Bias Capacitance= 68.12258\n');
fprintf(fid, '[capacitance meter]\n');
fprintf(fid, 'range= 300\n');
fprintf(fid, '[generator]\n');
fprintf(fid, 'bias=%.3f\n', mfia.ss_bias);
fprintf(fid, '1st Pulse Bias=%.3f\n', mfia.ss_bias+mfia.pulse_height);
fprintf(fid, '2nd Pulse Bias=0\n');
fprintf(fid, 'Injection Pulse Bias=0\n');
fprintf(fid, '1st Pulse Width=%f\n', mfia.pulse_width);
fprintf(fid, '2nd Pulse Width=0.0\n');
fprintf(fid, 'Injection Pulse Width=0.0\n');
fprintf(fid, '2nd pulse=off\n');
fprintf(fid, '2nd pulse interlacing= 10\n');
fprintf(fid, 'Injection pulse=off\n');
fprintf(fid, 'Like Pulse1=on\n');
fprintf(fid, 'Extra delay added=off\n');
fprintf(fid, 'Extra Delay Value= .001\n');
fprintf(fid, '[acquisition]\n');
fprintf(fid, 'first sample= 0\n');
fprintf(fid, 'last sample= %d\n', length(transient)-1);
fprintf(fid, 'Sampling Rate= %d\n', mfia.sample_rate);
fprintf(fid, 'No samples= %d\n', length(transient));
fprintf(fid, 'No scans= 150\n');
fprintf(fid, 'gain= 1\n');
fprintf(fid, '[parameters]\n');
fprintf(fid, 'Sampling Rate= %d\n', mfia.sample_rate);
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
fprintf(fid, 'No scans= 150\n');  %TODO
fprintf(fid, 'gain= 1\n');
fprintf(fid, 'Bias Capacitance= 68.12258\n');
fprintf(fid, 'CurrentTransient=off\n');
fprintf(fid, 'temperature= %f\n', avgTemperature);
fprintf(fid, 'temperatureSet= %d\n', setTemperature);
fprintf(fid, 'magnetic field= 0\n');
fprintf(fid, 'pressure= 0\n');
fprintf(fid, 'illumination= 0\n');
fprintf(fid, '[noise]\n');
fprintf(fid, 'level= 2.049163E-02\n');  %TODO
fprintf(fid, '\n');
fprintf(fid, '[data]\n');
for i=1:length(transient)
    fprintf(fid, ' %f \n', transient(i)');
end
fclose(fid);
end
