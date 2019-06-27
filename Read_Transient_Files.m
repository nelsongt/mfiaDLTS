function [ transient_array ] = Read_Transient_Files(Folder_Name)
% constants


% file read code
F_dir = strcat(Folder_Name, '\*_*.iso');
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat(Folder_Name,'\',F(ii).name));

    Intro = textscan(fileID,'%s',67,'Delimiter','\n');
%    Header = textscan(fileID,'%s %s',6,'Delimiter','\t');
    Labels = textscan(fileID,'%s %s %s',1,'Delimiter','\t');
    Data = textscan(fileID,'%f64 %f64',81,'Delimiter','\t');

    V_data(:,ii) = Data{1};
    I_data = Data{2};

    if (RealCellID(end) == '1')
        J_data(:,ii) = I_data/area_250;
        V_data_250(:,ii) = Data{1};
        J_data_250(:,ii) = I_data/area_250;
        
        R_Sh_cm2_250(:,ii) = V_data(39,ii) / J_data(39,ii);
    elseif (RealCellID(end) == '2')
        J_data(:,ii) = I_data/area_200;
        V_data_200(:,ii) = Data{1};
        J_data_200(:,ii) = I_data/area_200;
        
        R_Sh_cm2_200(:,ii) = V_data(39,ii) / J_data(39,ii);
    elseif (RealCellID(end) == '3')
        J_data(:,ii) = I_data/area_150;
        V_data_150(:,ii) = Data{1};
        J_data_150(:,ii) = I_data/area_150;
        
        R_Sh_cm2_150(:,ii) = V_data(39,ii) / J_data(39,ii);
    elseif (RealCellID(end) == '4')
        J_data(:,ii) = I_data/area_100;
        V_data_100(:,ii) = Data{1};
        J_data_100(:,ii) = I_data/area_100;
        
        R_Sh_cm2_100(:,ii) = V_data(39,ii) / J_data(39,ii);
    else
        string = 'error parsing file'
    end

    R_Shunt(:,ii) = V_data(39,ii) / I_data(39);
    R_Sh_cm2(:,ii) = V_data(39,ii) / J_data(39,ii);
    
    
    counter = ii
    fclose(fileID);     
end

V_data_250( :, all(~V_data_250,1) ) = [];
V_data_200( :, all(~V_data_200,1) ) = [];
V_data_150( :, all(~V_data_150,1) ) = [];
V_data_100( :, all(~V_data_100,1) ) = [];

J_data_250( :, all(~J_data_250,1) ) = [];
J_data_200( :, all(~J_data_200,1) ) = [];
J_data_150( :, all(~J_data_150,1) ) = [];
J_data_100( :, all(~J_data_100,1) ) = [];

R_Sh_cm2_250( :, all(~R_Sh_cm2_250,1) ) = [];
R_Sh_cm2_200( :, all(~R_Sh_cm2_200,1) ) = [];
R_Sh_cm2_150( :, all(~R_Sh_cm2_150,1) ) = [];
R_Sh_cm2_100( :, all(~R_Sh_cm2_100,1) ) = [];

end

