%% Cosine weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightcosine(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
t_d = 0.032 ./ (0.185 .* RW);  % seconds
t_c = 1 ./ (0.185 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 15.2;  % gain calculated from the filter t_c&t_d by George via numerical integration

cosfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear cosfun_data;
        cosfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            cosfun_data(kk+1) = cosinefun(kk+sample_d(jj),sample_d(jj),sample_c(jj));
        end
        DC(jj,ii) = -1000*15.2*trapz(DATA{1,ii}(sample_d(jj):(sample_d(jj)+sample_c(jj))).*cosfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Actual Weighting Function %%
function w = cosinefun(sample,sd,sc)
% Weighting function w = w = sin(2pi*t_norm)
%t_norm = (t - td)/tc;

if (sample < sd)
    w = 'thats a bad'
elseif (sample <= (sd+sc))    
    w = cos(2*pi()*((double(sample) - double(sd))/double(sc)));
elseif (sample > (sd+sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end