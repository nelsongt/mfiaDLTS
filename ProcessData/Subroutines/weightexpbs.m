%% Exponential correlator weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightexpbs(DATA,RW,SR,SSCAP,TOT)
% Set the transient length for weight function per rate window, see Istratov 1998 10.1088/0957-0233/9/3/023 
ECONST = (exp(-2)-1)/2;
bsfactor = 2; % don't tell anyone about this
t_d = 0.082 ./ (0.444 .* RW);  % seconds
t_c = 1 ./ (0.444 .* RW);  % seconds
sample_d = double(t_d .* SR);
sample_c = double(t_c .* SR);
total_samples = bsfactor*floor(t_c .* SR)+1;
real_spacing = linspace(1,size(DATA{1,1},1),size(DATA{1,1},1));

gain = 19.2/bsfactor;  % gain calculated from the filter t_c&t_d by George via numerical integration

% integrate S(smpl) * W(smpl - smpl_d) d_smpl from smpl_d to smpl_c
for jj = 1:length(RW)
    for ii = 1:TOT
        expfun_data = [];
        interp_spacing = [];
        expfun_data = zeros(total_samples(jj),1);
        interp_spacing = linspace(sample_d(jj),sample_d(jj)+sample_c(jj),total_samples(jj));
        for kk = 1:total_samples(jj)
            expfun_data(kk) = expfun(interp_spacing(kk),sample_d(jj),sample_c(jj),ECONST);
        end
        interp_data = interp1(real_spacing,DATA{1,ii},interp_spacing,'spline').';
        DC(jj,ii) = -1000*gain*trapz(interp_data.*expfun_data) / sample_c(jj);
        
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