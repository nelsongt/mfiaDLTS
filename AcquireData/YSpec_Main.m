%%% MFIA Admittance Spectroscopy %%%  Author: George Nelson 2019

% Set sample info
sample.user = 'George';
sample.material = 'In0.53Ga0.47As';
sample.name = 'FGA015-RAD';
sample.area = '0.0177';  % mm^2
sample.comment = '-0.2V';
sample.save_folder = strcat('.\data\',sample.name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens

% Set YSpec experiment parameters
mfia.sample_time = 10;     % sec, length to sample each temp point, determines speed of scan and SNR
mfia.ss_bias = -0.2;       % V, steady-state bias
ac_freq_start = 300;     % Hz, start lock in AC frequency, GN suggests ~100Hz
ac_freq_final = 5e6;     % Hz, final frequency, GN suggests 5MHz (MFIA limit)
ac_freq_steps = 150;     % Frequency step size on the log-scale

% Set temperature parameters
temp_init = 300;         % K, Initial temperature
temp_step = 10;         % K, Temperature step size
temp_final = 50;       % K, Ending temperature
temp_idle = 200;        % K, Temp to set after experiment is over
temp_stability = 0.2;  % K, Sets how stable the temperature point must be (set point +- stability)
time_stability = 20;    % s, How long must temperature be stable before collecting data, useful if sample lags temperature or if PID settings are overshooting beyond the stability criteria above

% Set MFIA Parameters
mfia.time_constant = 2.4e-3;  % us, lock in time constant, GN suggests 2.4e-3
mfia.pulse_height = 0.0;      % V, has to be zero for YSpec, don't change this
mfia.ac_ampl = 0.1;           % V, lock in AC amplitude, GN suggests ~100 mV for good SNR
mfia.sample_rate = 53571;     % Hz, sampling rate Hz, for Y_Spec use 53571 or 107143
mfia.ac_freq = ac_freq_start; % Hz, not used for YSpec
mfia.full_period = 0.150;     % s, not used for YSpec
mfia.trns_length = 0.150;     % s, not used for YSpec
mfia.pulse_width = 0.000;     % s, not used for YSpec


% Setup PATH
addpath(genpath('.\lakeshore'))		% point to lakeshore driver
addpath(genpath('.\LabOneMatlab'))  % point to LabOneMatlab drivers
ziAddPath % ZI instrument driver load


%% MAIN %%
% Check for and initialize lakeshore 331
if LAKESHORE_INIT()==0
    return;
end
% Check for and initialize MFIA
device = MFIA_INIT(mfia);


freqs = logspace(log10(ac_freq_start),log10(ac_freq_final),ac_freq_steps);
current_temp = temp_init;
current_num = 0;
steps = ceil(abs(temp_init - temp_final)/temp_step);
while current_num <= steps
    cprintf('blue', 'Waiting for set point (%3.2f)...\n',current_temp);
    SET_TEMP(current_temp,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
    for i=1:length(freqs)
        mfia.ac_freq = freqs(i);
        [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_POLL(device,mfia);
        avg_G(i) = 1 / mean(sampleRes);
        avg_C(i) = mean(sampleCap);
        omegas(i) = 2*pi()*freqs(i);
        cprintf('blue', 'Current frequency: %d \n',freqs(i));
    end
    
    cprintf('blue', 'Saving data...\n');
    YSPEC_FILE(sample,mfia,current_temp,freqs,omegas,avg_C,avg_G);
    
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
