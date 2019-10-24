%%%% MFIA CDLTS %%%%  Author:  George Nelson 2019

%% Init %%
% Set sample info
sample_name = '19R107 G3R1b1';
sample_comment = '-3.3. to +0.5 60s 1.0MHz 100mV 4rej';
save_folder = strcat('.\data\',sample_name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens
cv_doping = 1e15;       % 1/cm^3, TODO

% Set MFIA Parameters
time_constant = 2.4e-6; % us, lock in time constant, GN suggests 2.4e-6
ac_freq = 1.0e6;        % Hz, lock in AC frequency, GN suggests 1MHz
ac_ampl = 0.10;         % V, lock in AC amplitude, GN suggests ~100 mV for good SNR
sample_rate = 107143;   % Hz, sampling rate Hz, for CDLTS use 53571 or 107143 (MFIA half and full data rate, full is better but maybe not reliable)
sample_time = 15;       % sec, length to sample each temp point, determines speed of scan and SNR
ss_bias = -1.2;         % V, steady-state bias
p_height = 1.0;		    % V, bias applied by pulse generator, absolute bias during pulse is ss_bias+pulse_bias

% Set DLTS experiment parameters
sample_period = 0.160;  % s, length of single experiment in time
pulse_width = 0.01;     % s, length of pulse in time
temp_init = 200;        % K, Initial DLTS temperature
temp_step = 0.5;        % K, Capture transient each temp step
temp_final = 50;        % K, DLTS ending temperature
temp_idle = 300;        % K, Temp to set after experiment is over
temp_stability = 0.1;   % K, Sets how close to the setpoint the temperature must be before collecting data (set point +- stability)
time_stability = 10;    % s, How long must temperature be within temp_stability before collecting data, tests if PID settings overshoot set point, also useful if actual sample temp lags sensor temp

% Setup PATH
addpath(genpath('.\lakeshore'))					 % point to lakeshore driver
addpath(genpath('.\LabOneMatlab'))               % point to LabOneMatlab drivers
ziAddPath % ZI instrument driver load

%% MAIN %%
% Check for and initialize lakeshore 331
%if LAKESHORE_INIT()==0
%    return;
%end
% Check for and initialize MFIA
device = MFIA_INITtemp(sample_rate,time_constant,ss_bias,p_height,ac_freq,ac_ampl);


current_temp = temp_init;
current_num = 0;
steps = ceil(abs(temp_init - temp_final)/temp_step);
while current_num <= steps
    cprintf('blue', 'Waiting for set point (%3.2f)...\n',current_temp);
    %SET_TEMP(current_temp,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
    
    cprintf('blue', 'Capturing transient...\n');
    temp_before = sampleSpaceTemperature;
    [timestamp, sampleCap] = MFIA_CAPACITANCE_ACQ_DAQtemp(device,sample_time,sample_period-pulse_width);
    temp_after = sampleSpaceTemperature;
    cprintf('green', 'Finished transient for this temperature.\n');
    avg_temp = (temp_before + temp_after) / 2;
    
    avg_trnst = MFIA_TRANSIENT_AVERAGERtemp(sampleCap,sample_rate,sample_period-pulse_width);
    
    cprintf('blue', 'Saving transient...\n');
    TRANSIENT_FILE(save_folder,strcat(sample_name,'_',num2str(current_num),'_',num2str(current_temp),'.iso'),avg_trnst,sample_rate,avg_temp,sample_comment);

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
