%%% MFIA Admittance Spectroscopy %%%  Author: George Nelson 2019

% Set MFIA Parameters
time_constant = 2.4e-3; % us, lock in time constant, GN suggests 2.4e-6
ss_bias = -4.0;          % V, steady-state voltage bias
ac_freq_start = 300;   % Hz, start lock in AC frequency, GN suggests ~100Hz
ac_freq_final = 5e6;    % Hz, final frequency, GN suggests 5MHz (MFIA limit)
ac_freq_steps = 150;    % Frequency step size on the log-scale
ac_ampl = 0.1;         % V, lock in AC amplitude, GN suggests 50 mV
sample_rate = 53571;    % Hz, sampling rate Hz, for CDLTS use 53571 or 107143 (MFIA half and full data rate, full is better but maybe not reliable)
sample_time = 10;       % sec, length to sample each temp point, determines speed of scan

% Set YSpec experiment parameters
sample_name = '19R108 G3R1a1';
sample_comment = '-4.0V';
save_folder = strcat(sample_name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens
temp_init = 160;         % K, Initial temperature
temp_step = 10;         % K, Temperature step size
temp_final = 50;       % K, Ending temperature
temp_idle = 160;        % K, Temp to set after experiment is over
temp_stability = 0.1;  % K, Sets how stable the temperature point must be (set point +- stability)
time_stability = 10;    % s, How long must temperature be stable before collecting data, useful if sample lags temperature or if PID settings are overshooting beyond the stability criteria above

% Setup PATH
addpath(genpath('.\lakeshore'))
addpath(genpath('.\LabOneMatlab-18.05.53868'))
ziAddPath % ZI instrument driver

%% MAIN %%
if LAKESHORE_INIT()==0
    return;
end

freqs = logspace(log10(ac_freq_start),log10(ac_freq_final),ac_freq_steps);
current_temp = temp_init;
current_num = 0;
steps = ceil(abs(temp_init - temp_final)/temp_step);
while current_num <= steps
    cprintf('blue', 'Waiting for set point (%3.2f)...\n',current_temp);
    SET_TEMP(current_temp,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
    for i=1:length(freqs)
        [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_ACQ(sample_rate,time_constant,ss_bias,freqs(i),ac_ampl,sample_time);
        avg_G(i) = 1 / mean(sampleRes);
        avg_C(i) = mean(sampleCap);
        omega(i) = 2*pi()*freqs(i);
        cprintf('blue', 'Current frequency: %d \n',freqs(i));
    end
    
    cprintf('blue', 'Saving data...\n');
    YSPEC_FILE(save_folder,strcat(sample_name,'_',num2str(current_temp),'.dat'),omega,avg_C,avg_G,sample_rate,sample_time,current_temp,sample_comment,sample_name);

    if temp_init > temp_final
        current_temp = current_temp - temp_step;    % Changes +/- for up vs down scan
    elseif temp_init < temp_final
        current_temp = current_temp + temp_step;
    end
    current_num = current_num + 1;
end

cprintf('blue', 'Finished data collection, returning to idle temp.\n');
SET_TEMP(temp_idle,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
cprintf('green', 'All done.\n');

%% END MAIN %%
