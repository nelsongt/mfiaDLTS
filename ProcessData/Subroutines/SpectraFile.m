%% Copyright George Nelson 2020 %%
function SpectraFile(SampleName,FolderName,Rates,Temps,Caps,DelCaps);
%TransientFile Saves transient data to LDLTS compatible iso file

fileName = strcat(SampleName,'.dat');
fileDate = datestr(now,'dd-mm-yyyy  HH:MM');

fid = fopen(fullfile(strcat('../Data/',FolderName,'\'),fileName),'wt');
fprintf(fid, '[general]\n');
fprintf(fid, 'software=mfiaDLTS v1.1\n');
fprintf(fid, 'date=%s\n', fileDate);  
fprintf(fid, '[sample]\n');
fprintf(fid, 'Identifier=%s\n', SampleName);
fprintf(fid, '[data]\n');
% Build column header and data format strings
hdr_str='Temp(K)\tCapacitance(pF)';  
for j=1:length(Rates)
    hdr_str=[hdr_str '\t' int2str(Rates(j)) 'Hz(fF)'];    
end
hdr_str=[hdr_str '\n'];
fprintf(fid, hdr_str);

%Write Data
for i=1:length(Temps)
    data_str=sprintf('%0.3f\t%.15f', Temps(i),Caps(i));
    for n=1:length(Rates)
        data_str=[data_str sprintf('\t%.15f', DelCaps(n,i))];
    end
    data_str=[data_str '\n'];
    fprintf(fid, data_str);
end
fclose(fid);
end
