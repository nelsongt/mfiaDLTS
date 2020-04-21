%% Exponential correlator weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightexp(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
ECONST = (exp(-2)-1)/2;
t_d = 0.082 ./ (0.444 .* RW);  % seconds
t_c = 1 ./ (0.444 .* RW);  % seconds
sample_d = int16(t_d .* SR);
sample_c = int16(t_c .* SR);

gain = 19.2;  % gain calculated from the filter t_c&t_d by George via numerical integration

expfun_data = [];

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        clear expfun_data;
        expfun_data = zeros(sample_c(jj),1);
        for kk = 0:sample_c(jj)
            expfun_data(kk+1) = expfun(kk+sample_d(jj),sample_d(jj),sample_c(jj),ECONST);
        end
        DC(jj,ii) = -1000*gain*trapz(DATA{1,ii}(sample_d(jj):(sample_d(jj)+sample_c(jj))).*expfun_data) / double(sample_c(jj));
        
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end


%% Actual Weighting Function %%
function w = expfun(sample,sd,sc,econst)
% Weighting function w = exp(-2*t_norm) + [exp(-2) - 1]/2  (there's a sign mistake in Istratov paper)
%t_norm = (t - td)/tc;

if (sample < sd)
    w = 'thats a bad'
elseif (sample <= (sd+sc))    
    w = exp(-2*((double(sample) - double(sd))/double(sc))) + econst;
elseif (sample > (sd+sc))
    w = 'thats another bad'
else
    w = 'thats a worse'
end
end