%%%% MFIA CDLTS %%%%  Author:  George Nelson 2019

%%% Init %%%
% Set sample info
sample.user = 'George';
sample.material = 'In0.53Ga0.47As';
sample.name = 'FGA015-3-10VPre';
sample.area = '0.0177';  % mm^2
sample.comment = 'P0 30s 1.0MHz 125mV 4rej';

% Set DLTS experiment parameters
mfia.sample_time = 30;     % sec, length to sample each temp point, determines speed of scan and SNR
mfia.ss_bias = 9.8;       % V, steady-state bias
mfia.full_period = 0.161;  % s, length of single experiment in time (must be longer than trns_length+pulse_width)
mfia.trns_length = 0.150;  % s, amount of transient sampled and saved
mfia.pulse_width = 0.010;   % s, length of pulse in time
pulse_height_start = -0.1;      % V, start pulse height
pulse_height_final = -9.6;      % V, final pulse height
pulse_height_step = 0.1;      % V, Pulse height step size

% Set temperature parameters
temp_test = 240;                % K, Temp to do isoDLTS
temp_idle = 240;           % K, Temp to set after experiment is over
temp_stability = 0.05;      % K, Sets how close to the setpoint the temperature must be before collecting data (set point +- stability)
time_stability = 30;       % s, How long must temperature be within temp_stability before collecting data, tests if PID settings overshoot set point, also useful if actual sample temp lags sensor temp

% Configure Lakeshore Parameters
temp.control = 'B';         % Control sensor (closest to heater), A or B
temp.sample = 'B';          % Measure sensor (closest to sample), A or B
temp.heatpower = 3;         % Heater power range, sets heater to high (3), medium (2), low (1) 

% Set MFIA Parameters
mfia.i_range = 0.0001;       % A, Current input range, GN suggests 100uA or 1mA (will round up to nearest power of 10; eg. 0.8mA->1.0mA)
mfia.time_constant = 2.4e-6; % us, lock in time constant, GN suggests 2.4e-6
mfia.ac_freq = 1.0e6;        % Hz, lock in AC frequency, GN suggests 1MHz
mfia.ac_ampl = 0.125;         % V, lock in AC amplitude, GN suggests ~100 mV for good SNR
mfia.sample_rate = 107143;   % Hz, sampling rate Hz, for CDLTS use 53571 or 107143 or 214286
mfia.sample_reject = 1;      % Rejected data points due to meter recovery from pulse, calibrate this by testing, this is in addition to auto-rejected samples using formula: 16*mfia.time_constant*mfia.sample_rate

% Setup PATH
sample.save_folder = strcat('..\Data\',sample.name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens
addpath(genpath('.\lakeshore'))		% point to lakeshore driver
addpath(genpath('.\LabOneMatlab'))  % point to LabOneMatlab drivers
addpath(genpath('.\Subroutines'))
ziAddPath % ZI instrument driver load

%%% END INIT %%%

%%% MAIN %%%
% Check for and initialize lakeshore 331
if LAKESHORE_INIT(temp)==0
    return;
end
% Check for and initialize MFIA
mfia.pulse_height = pulse_height_start;
device = MFIA_INIT(mfia);

% Main loop
cprintf('blue', 'Waiting for test set point (%3.2f) at time %s\n',temp_test,datetime('now'));
SET_TEMP(temp_test,temp_stability,time_stability,temp); % Wait for lakeshore to reach set temp;
current_pulse = pulse_height_start;
current_num = 0;
steps = ceil(abs(pulse_height_start - pulse_height_final)/pulse_height_step);
while current_num <= steps
    mfia.pulse_height = current_pulse;
    device = MFIA_INIT(mfia);  %TODO: Replace full init of mfia with a mfia 'change setting' function
    pause(2.0);
    temp_before = sampleSpaceTemperature(temp);
    cprintf('blue', 'Capturing transient at time %s.\n',datetime('now'));
    [timestamp, sampleCap] = MFIA_CAPACITANCE_DAQ(device,mfia);
    temp_after = sampleSpaceTemperature(temp);
    cprintf('green', 'Finished transient for this pulse height.\n');
    avg_temp = (temp_before + temp_after) / 2;
    
    % Find the amount of data loss, if more than a few percent lower duty cycle or lower sampling rate
    dataloss = sum(sum(isnan(sampleCap)))/(size(sampleCap,1)*size(sampleCap,2));
    if dataloss
        cprintf('systemcommands', 'Warning: %1.1f%% data loss detected.\n',100*dataloss);
    end
    
    avg_trnst = MFIA_TRANSIENT_AVERAGER_DAQ(sampleCap,mfia);
    
    cprintf('blue', 'Saving transient...\n');
    TRANSIENT_FILE(sample,mfia,current_num,temp_test,avg_temp,avg_trnst);

    if pulse_height_start > pulse_height_final
        current_pulse = current_pulse - pulse_height_step;    % Changes +/- for up vs down scan
    elseif pulse_height_start > pulse_height_final
        current_pulse = current_pulse + pulse_height_step;
    end
    current_num = current_num + 1;
end

cprintf('blue', 'Finished data collection, returning to idle temp.\n');
SET_TEMP(temp_idle,temp_stability,time_stability,temp); % Wait for lakeshore to reach set temp;
cprintf('green', 'All done.\n');


%%% END MAIN %%%
