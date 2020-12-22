%%%% MFIA CDLTS %%%%  Author:  George Nelson 2019

%%% Init %%%
% Set sample info
sample.user = 'George';
sample.material = 'In0.53Ga0.47As';
sample.name = 'AnnealStage4-270-PostIV';
sample.area = '0.196';  % mm^2
sample.comment = 'Stage 4 90s 0.4V 270K postIV anneal 1.0MHz 125mV 4rej';
sample.save_folder = strcat('.\data\',sample.name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens

%cv_doping = 1e15;       % 1/cm^3, TODO

% Set DLTS experiment parameters
mfia.sample_time = 90;     % sec, length to sample each temp point, determines speed of scan and SNR
mfia.ss_bias = 2.0;       % V, steady-state bias
mfia.pulse_height = -1.8;   % V, bias applied by pulse generator, absolute bias during pulse is ss_bias+pulse_bias
mfia.full_period = 2.315;  % s, length of single experiment in time (must be longer than trns_length+pulse_width)
mfia.trns_length = 2.300;  % s, amount of transient sampled and saved
mfia.pulse_width = 0.010;   % s, length of pulse in time

% Set temperature parameters
temp_test = 150;            % K, Temp to do FDLTS
temp_anneal = 270;          % K, Anneal temperature
time_anneal = 90;           % m, anneal time, or time between DLTS tests
test_temp_stability = 0.05;      % K, Sets how close to the setpoint the temperature must be before collecting data (set point +- stability)
test_time_stability = 30;        % s, How long must temperature be within temp_stability before collecting data, tests if PID settings overshoot set point, also useful if actual sample temp lags sensor temp
anneal_temp_stability = 4;
anneal_time_stability = 1;

% Set MFIA Parameters
mfia.time_constant = 2.4e-6; % us, lock in time constant, GN suggests 2.4e-6
mfia.ac_freq = 1.0e6;        % Hz, lock in AC frequency, GN suggests 1MHz
mfia.ac_ampl = 0.125;         % V, lock in AC amplitude, GN suggests ~100 mV for good SNR
mfia.sample_rate = 107143;   % Hz, sampling rate Hz, for CDLTS use 53571 or 107143 or 214286

% Setup PATH
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
current_temp = temp_test;
current_num = 0;
while true
    cprintf('blue', 'Waiting for test set point (%3.2f) at time %s\n',temp_test,datetime('now'));
    if current_num == 0
        SET_TEMP(130,0.2,20); % Wait for lakeshore to reach set temp;
    end
    SET_TEMP(temp_test,test_temp_stability,test_time_stability); % Wait for lakeshore to reach set temp;
    
    cprintf('blue', 'Capturing transient at time %s.\n',datetime('now'));
    temp_before = sampleSpaceTemperature;
    [timestamp, sampleCap] = MFIA_CAPACITANCE_DAQ(device,mfia);
    temp_after = sampleSpaceTemperature;
    cprintf('green', 'Finished transient for this temperature.\n');
    avg_temp = (temp_before + temp_after) / 2;
    
    % Find the amount of data loss, if more than a few percent lower duty cycle or lower sampling rate
    dataloss = sum(sum(isnan(sampleCap)))/(size(sampleCap,1)*size(sampleCap,2));
    if dataloss
        cprintf('systemcommands', 'Warning: %1.1f%% data loss detected.\n',100*dataloss);
    end
    
    avg_trnst = MFIA_TRANSIENT_AVERAGER_DAQ(sampleCap,mfia);
    
    cprintf('blue', 'Saving transient...\n');
    TRANSIENT_FILE(sample,mfia,current_num,temp_test,avg_temp,avg_trnst);
    %% 
    
    cprintf('blue', 'Going to anneal temperature (%3.2f) at time %s.\n',temp_anneal,datetime('now'));
    SET_TEMP(temp_anneal,anneal_temp_stability,anneal_time_stability); % Wait for lakeshore to reach set temp;
    cprintf('green', 'Temperature ramp done at time %s.\n',datetime('now'));

    %ziDAQ('setInt', ['/' device '/sigouts/0/add'], 0);
    %ziDAQ('setDouble', ['/' device '/sigouts/0/offset'], -0.4);
    %ziDAQ('setDouble', ['/' device '/imps/0/current/range'], 0.001);
    time_iter = 60*time_anneal;
    if current_num == 0
        time_iter = 60*30;
    elseif current_num == 1
        time_iter = 60*60;
    end
    while time_iter > 0
        cprintf('blue', 'Annealing. Time left: %d s.\n',time_iter);
        pause(15);
        time_iter = time_iter - 15;
    end
    %ziDAQ('setDouble', ['/' device '/imps/0/current/range'], 0.0001);
    %ziDAQ('setDouble', ['/' device '/sigouts/0/offset'], mfia.ss_bias);
    %ziDAQ('setInt', ['/' device '/sigouts/0/add'], 1);
    

    current_num = current_num + 1;
end

cprintf('blue', 'Finished data collection, returning to idle temp.\n');
SET_TEMP(temp_idle,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
cprintf('green', 'All done.\n');


%%% END MAIN %%%
