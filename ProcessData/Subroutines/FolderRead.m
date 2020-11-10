%% Copyright George Nelson 2020 %%
function [SampleName,Data,Temps,Caps,SamplingRate] = FolderRead(FolderName,FileType)

F_dir = strcat('../Data/',FolderName,'\*_*.',FileType);
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat('../Data/',FolderName,'\',F(ii).name));

	if FileType == 'iso' % DLTS and YSpec have different data structures, TODO: make this more elegant
		Header = textscan(fileID,'%s',67,'Delimiter','\n');
	elseif FileType == 'dat'
		Header = textscan(fileID,'%s',15,'Delimiter','\n');
	else
		Header = 'unrecognized filetype';
	end


    for jj = 1:length(Header{1,1})  % Pull out the sample temp and sampling rate
        if contains(lower(Header{1,1}{jj,1}),'temperature=')
            temp_string = strsplit(Header{1,1}{jj,1},'=');
            temperature = str2double(temp_string{1,2});
        elseif contains(lower(Header{1,1}{jj,1}),'sampling rate=')
            rate_string = strsplit(Header{1,1}{jj,1},'=');
            SamplingRate = str2double(rate_string{1,2});
        elseif contains(lower(Header{1,1}{jj,1}),'identifier=')
            rate_string = strsplit(Header{1,1}{jj,1},'=');
            SampleName = rate_string{1,2};
        end
    end

    Temps(ii) = temperature;
	if FileType == 'iso' % DLTS and YSpec have different data structures, TODO: make this more elegant
		Data(ii) = textscan(fileID,'%f64');
	elseif FileType == 'dat'
		Data{:,ii} = cell2mat(textscan(fileID,'%f64 %f64 %f64 %f64'));
	else
		Data = 'unrecognized filetype';
	end
    Caps(ii) = mean(Data{1,ii}(end-50:end));

    fclose(fileID);
end

end