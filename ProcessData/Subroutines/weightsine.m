%% Sine weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightsine(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
t_d = 0; % seconds
t_c = 1 ./ (0.424 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 7.92;  % gain calculated from the filter t_c&t_d by George via numerical integration

sinfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear sinfun_data;
        sinfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            sinfun_data(kk+1) = sinefun(kk,sample_c(jj));
        end
        DC(jj,ii) = -1000*gain*trapz(DATA{1,ii}(1:(sample_c(jj)+1)).*sinfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Actual Weighting Function %%
function w = sinefun(sample,sc)
% Weighting function w = sin(2pi*t_norm)
%t_norm = (t - td)/tc;

if (sample < 0)
    w = 'thats a bad'
elseif (sample <= (sc))    
    w = sin(2*pi()*(double(sample)/double(sc)));
elseif (sample > (sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end