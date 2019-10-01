function YSPEC_FILE(saveFolder,filename,freqs,caps,conds,rate,time,temperature,comment,sampleName)
%TransientFile Saves transient data to LDLTS compatible iso file
%   Detailed explanation goes here

status = mkdir(strcat(pwd,'\',saveFolder));
fid = fopen(fullfile(strcat(pwd,'\',saveFolder),filename),'wt');
fprintf(fid, '[general]\n');
fprintf(fid, 'software=ZurYSpec version 11.30.18\n');
fprintf(fid, 'user=George\n');
fprintf(fid, 'source=Laplace DLTS experiment\n');
fprintf(fid, 'date=%s\n', datetime);
fprintf(fid, 'comment=%s\n', comment);
fprintf(fid, '[sample]\n');
fprintf(fid, 'Material=In0.5GaAs\n');
fprintf(fid, 'Identifier=%s\n', sampleName);
fprintf(fid, 'area= .25\n');
fprintf(fid, '[acquisition]\n');
fprintf(fid, 'sampling rate= %d\n', rate);
fprintf(fid, 'sampling time= %d\n', time);
fprintf(fid, 'temperature= %f\n', temperature);
fprintf(fid, '[data]\n');
fprintf(fid, 'ang_freq(Hz)\tcap(F)\tcond(S)\n');
for i=1:length(freqs)
    fprintf(fid, '%e\t%e\t%e\n', freqs(i),caps(i),conds(i)');
end
fclose(fid);
end

