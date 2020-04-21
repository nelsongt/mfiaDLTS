%% Double boxcar weighting routine, copyright George Nelson 2020 %%
function [DC,DC_norm] = weightboxcar(DATA,RW,SR,SSCAP,TOT)
% Find t1 and t2 for each rate window
t_1 = log(2.5) ./ (RW * 1.5)
sample_1 = int16(t_1 * SR)
t_2 = 2.5 * t_1
sample_2 = int16(t_2 * SR)

% Set boxcar gate width dynamically per rate window
gate_width = 0.125;  % Fraction of period TODO: find proper value, it's in Itratov paper
buffer = int16(0.5*gate_width*sample_2);
%buffer = [20,20,20,20,20,20]
gain = 3;

% Calculate Spectra from Transient data
for jj = 1:length(RW)
    for ii = 1:TOT
        cap_1 = mean(DATA{1,ii}(sample_1(jj)-buffer(jj):sample_1(jj)+buffer(jj)));
        cap_2 = mean(DATA{1,ii}(sample_2(jj)-buffer(jj):sample_2(jj)+buffer(jj)));
        
        DC(jj,ii) = 1000*gain*(cap_2 - cap_1); % convert to fF
    end
    DC_norm(jj,:) = DC(jj,:) ./ (1000.*SSCAP);
end
end