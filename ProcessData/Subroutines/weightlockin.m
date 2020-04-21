%% Lock-in Amplifier weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightlockin(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see ftp://gateway.ifpan.edu.pl/pub/Laplace/Common/DLTS_simulation_Boxcar_vs_lock-in.pdf
t_c = 2.083 ./ RW;
sample_c = int16(t_c * SR);

gain = 7.04;  % gain calculated from the filter t_c&t_d, see above pdf

lockfun_data = [];

% integrate S(smpl) * W(smpl - smpl_1) d_smpl from 0 to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear lockfun_data;
        lockfun_data = zeros(sample_c(jj),1);
        for kk = 1:sample_c(jj)
            lockfun_data(kk) = lockinfun(kk,RW(jj),SR);
        end
        DC(jj,ii) = 1000*gain*trapz(DATA{1,ii}(1:sample_c(jj)).*lockfun_data) / double(sample_c(jj));
         
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end

%% Actual Weighting Function %%
function w = lockinfun(sample,RW,SR)
% Find t1,t2,t3,t4 for each rate window (RW*total_samples = 2.08)
t4 = 2.083 / RW;
sample4 = int16(t4 * SR);
t3 = 0.6 * t4;
sample3 = int16(t3 * SR);
t2 = 0.5 * t4;
sample2 = int16(t2 * SR);
%t1 = 0.1 * t4;
sample1 = sample2 - (sample4 - sample3); % gate width the same, no rounding error TODO: Define gate width using sample 1&2 or 3&4?

if (sample < sample1)
    w = 0;
elseif (sample < sample2)
    w = -1;
elseif (sample < sample3)
    w = 0;
elseif (sample < sample4)
    w = 1;
elseif (sample == sample4)
    w = 0;
else
    w = 'thats a bad'
end
end