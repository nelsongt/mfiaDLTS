%%%% MFIA CDLTS %%%%  Author:  George Nelson 2020

%%% Init %%%
% Set sample info
sample.user = 'George';
sample.material = 'In0.53Ga0.47As';
sample.name = 'GAP500-IV-Post400K';
sample.area = '0.196';  % mm^2
sample.comment = '150ms 30s 1MHz 125mV 4rej';

% Set DLTS experiment parameters
mfia.ss_bias = 2.0;       % V, steady-state bias
mfia.pulse_height = -1.8;   % V, bias applied by pulse generator, absolute bias during pulse is ss_bias+pulse_bias
mfia.full_period = 0.161;  % s, length of single experiment in time (must be longer than trns_length+pulse_width)
mfia.trns_length = 0.150;  % s, amount of transient sampled and saved
mfia.pulse_width = 0.010;   % s, length of pulse in time
mfia.sample_time = 30;     % sec, length to sample each temp point, determines speed of scan and SNR

% Set temperature parameters
temp_init = 300;           % K, Initial DLTS temperature
temp_step = 0.5;           % K, Capture transient each temp5 step
temp_final = 50;           % K, DLTS ending temperature
temp_idle = 200;           % K, Temp to set after experiment is over
temp_stability = 0.10;      % K, Sets how close to the setpoint the temperature must be before collecting data (set point +- stability)
time_stability = 5;       % s, How long must temperature be within temp_stability before collecting data, tests if PID settings overshoot set point, also useful if actual sample temp lags sensor temp

% Set MFIA Parameters
mfia.time_constant = 2.4e-6; % us, lock in time constant, GN suggests 2.4e-6
mfia.ac_freq = 1.0e6;        % Hz, lock in AC frequency, GN suggests 1MHz
mfia.ac_ampl = 0.125;         % V, lock in AC amplitude, GN suggests ~100 mV for good SNR
mfia.sample_rate = 107143;   % Hz, sampling rate Hz, for CDLTS use 53571 or 107143 or 214286

% Setup PATH
sample.save_folder = strcat('..\Data\',sample.name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens
addpath(genpath('.\lakeshore'))		% point to lakeshore driver
addpath(genpath('.\LabOneMatlab'))  % point to LabOneMatlab drivers
ziAddPath % ZI instrument driver load

%%% END INIT %%%

%%% MAIN %%%
% Check for and initialize lakeshore 331
if LAKESHORE_INIT()==0
    return;
end
% Check for and initialize MFIA
device = MFIA_INIT(mfia);

% Main loop
current_temp = temp_init;
current_num = 0;
steps = ceil(abs(temp_init - temp_final)/temp_step);
while current_num <= steps
    cprintf('blue', 'Waiting for set point (%3.2f)...\n',current_temp);
    SET_TEMP(current_temp,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
    
    cprintf('blue', 'Capturing transient...\n');
    temp_before = sampleSpaceTemperature;
    %[timestamp, sampleCap] = MFIA_CAPACITANCE_POLL(device,mfia);
    [timestamp, sampleCap] = MFIA_CAPACITANCE_DAQ(device,mfia);
    temp_after = sampleSpaceTemperature;
    cprintf('green', 'Finished transient for this temperature.\n');
    avg_temp = (temp_before + temp_after) / 2;
    
    % Find the amount of data loss, if more than a few percent lower duty cycle or lower sampling rate
    dataloss = sum(sum(isnan(sampleCap)))/(size(sampleCap,1)*size(sampleCap,2));
    if dataloss
        cprintf('systemcommands', 'Warning: %1.1f%% data loss detected.\n',100*dataloss);
    end
    
    %avg_trnst = MFIA_TRANSIENT_AVERAGER_POLL(sampleCap,mfia);
    avg_trnst = MFIA_TRANSIENT_AVERAGER_DAQ(sampleCap,mfia);
    
    cprintf('blue', 'Saving transient...\n');
    TRANSIENT_FILE(sample,mfia,current_num,current_temp,avg_temp,avg_trnst);

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


%%% END MAIN %%%
