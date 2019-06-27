%%  Author:  George Nelson, Copyright 2019 %%

clear
format long


%%%%%%% Begin Main %%%%%%
Folder_Name = 'C9S25'
%% File read code  % TODO: Clean up by moving to own function
F_dir = strcat(Folder_Name, '\*_*.dat');
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat(Folder_Name,'\',F(ii).name));

    Header = textscan(fileID,'%s',16,'Delimiter','\n');

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
    Data{:,ii} = cell2mat(textscan(fileID,'%f64 %f64 %f64'));

    total = ii;  % TODO; not needed, can use length(Data)
    fclose(fileID);
end

figure
for i = 1:length(Data)
    semilogx(Data{1,i}(:,1),Data{1,i}(:,2));
    hold on;
end
hold off;

figure
for i = 1:length(Data)
    semilogx(Data{1,i}(:,1),Data{1,i}(:,3)./Data{1,i}(:,1));
    hold on;
end
hold off;



function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end
