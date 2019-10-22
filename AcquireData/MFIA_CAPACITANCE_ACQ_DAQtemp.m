function [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_ACQ(deviceId)


%% J.Wei Zurich Instruments May 19, 2015
%% Updated for MFIA, George Nelson May 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% function DLTS_TRANSIENT_SAVE parameters                                %
% Fs : set output sampling rate of the demodulation                      %
% timeConstant: set digital filter time constant in seconds              %
% saveTime: total duration of demod data to be saved in seconds          %
%                                                                        %
% Example: [timestamp, DIOBitVal, sampleX, sampleY] = DLTS_TRANSIENT_SAVE(57600,3e-6,10)           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('device_id', 'var')
    error(['No value for device_id specified. The first argument to the ' ...
           'example should be the device ID on which to run the example, ' ...
           'e.g. ''dev3327'''])
end
  


% Unsubscribe from any streaming data
ziDAQ('unsubscribe', '*');
% Flush all the buffers.
ziDAQ('sync');

% Create a Data Acquisition Module instance, the return argument is a handle to the module.
h = ziDAQ('dataAcquisitionModule');

%% Configure the Data Acquisition Module
% Device on which trigger will be performed
ziDAQ('set', h, 'dataAcquisitionModule/device', device)
% The number of triggers to capture (if not running in endless mode).
ziDAQ('set', h, 'dataAcquisitionModule/count', trigger_count);
ziDAQ('set', h, 'dataAcquisitionModule/endless', 0);
% 'dataAcquisitionModule/grid/mode' - Specify the interpolation method of
%   the returned data samples.
%
% 1 = Nearest. If the interval between samples on the grid does not match
%     the interval between samples sent from the device exactly, the nearest
%     sample (in time) is taken.
%
% 2 = Linear interpolation. If the interval between samples on the grid does
%     not match the interval between samples sent from the device exactly,
%     linear interpolation is performed between the two neighbouring
%     samples.
%
% 4 = Exact. The subscribed signal with the highest sampling rate (as sent
%     from the device) defines the interval between samples on the DAQ
%     Module's grid. If multiple signals are subscribed, these are
%     interpolated onto the grid (defined by the signal with the highest
%     rate, "highest_rate"). In this mode, dataAcquisitionModule/duration is
%     read-only and is defined as num_cols/highest_rate.
%     demod samples.
grid_mode = 4;
ziDAQ('set', h, 'dataAcquisitionModule/grid/mode', grid_mode);
%   type:
%     NO_TRIGGER = 0
%     EDGE_TRIGGER = 1
%     DIGITAL_TRIGGER = 2
%     PULSE_TRIGGER = 3
%     TRACKING_TRIGGER = 4
%     HW_TRIGGER = 6
%     TRACKING_PULSE_TRIGGER = 7
%     EVENT_COUNT_TRIGGER = 8
ziDAQ('set', h, 'dataAcquisitionModule/type', 6);
%   triggernode, specify the triggernode to trigger on.
%     SAMPLE.X = Demodulator X value
%     SAMPLE.Y = Demodulator Y value
%     SAMPLE.R = Demodulator Magnitude
%     SAMPLE.THETA = Demodulator Phase
%     SAMPLE.AUXIN0 = Auxilliary input 1 value
%     SAMPLE.AUXIN1 = Auxilliary input 2 value
%     SAMPLE.DIO = Digital I/O valueimps.sample.param1
triggernode = ['/' device '/demods/0/sample.triginn'];
ziDAQ('set', h, 'dataAcquisitionModule/triggernode', triggernode);
%   edge:
%     POS_EDGE = 1
%     NEG_EDGE = 2
%     BOTH_EDGE = 3
ziDAQ('set', h, 'dataAcquisitionModule/edge', 1)
demod_rate = ziDAQ('getDouble', ['/' device '/demods/' config.demod_c(1) '/rate']);
if grid_mode == 4
    % Exact mode: To preserve our desired trigger duration, we have to set
    % the number of grid columns to exactly match.
    sample_count = demod_rate*config.trigger_duration;  % [s]
    ziDAQ('set', h, 'dataAcquisitionModule/grid/cols', sample_count);
else
    sample_count = 1024;
    ziDAQ('set', h, 'dataAcquisitionModule/grid/cols', sample_count);
    ziDAQ('set', h, 'dataAcquisitionModule/duration', config.trigger_duration);
end
% The length of each trigger to record (in seconds).
% ziDAQ('set', h, 'dataAcquisitionModule/duration', config.trigger_duration);
ziDAQ('set', h, 'dataAcquisitionModule/delay', config.trigger_delay);
% Do not return overlapped trigger events.
ziDAQ('set', h, 'dataAcquisitionModule/holdoff/time', config.trigger_duration);
ziDAQ('set', h, 'dataAcquisitionModule/holdoff/count', 0);
ziDAQ('set', h, 'dataAcquisitionModule/level', config.trigger_level)
% The hysterisis is effectively a second criteria (if non-zero) for triggering
% and makes triggering more robust in noisy signals. When the trigger `level`
% is violated, then the signal must return beneath (for positive trigger edge)
% the hysteresis value in order to trigger.
ziDAQ('set', h, 'dataAcquisitionModule/hysteresis', 0.1*config.trigger_level)


%% Subscribe to the demodulators
% fliplr: Subscribe in descending order so that we subscribe to the trigger
% demdulator last (demod 0). This way we will not start acquiring data on the
% trigger demod before we subscribe to other demodulators.
%for d=fliplr(config.demod_c)
%    ziDAQ('subscribe', h, ['/' device '/demods/' d '/sample.r']);
%end
% Subscribe to the 0th IA module
ziDAQ('subscribe',['/' device '/imps/0/sample']);

%% Start recording
% now start the thread -> ready to be triggered
ziDAQ('execute', h);

timeout = 20; % [s]
num_triggers = 0;
n = 0;
t0 = tic;
tRead = tic;
dt_read = 0.250;
while ~ziDAQ('finished', h)
    pause(0.05);
    % Perform an intermediate readout of the data. the data between reads is
    % not acculmulated in the module - it is cleared, so that the next time
    % you do a read you (should) only get the triggers that came inbetween the
    % two reads.
    if toc(tRead) > dt_read
        data = ziDAQ('read', h);
        fprintf('Performed an intermediate read() of acquired data (time since last read %.3f s).\n', toc(tRead));
        fprintf('Data Acquisition Module progress (acquired %d of total %d triggers): %.1f%%\n', num_triggers, trigger_count, 100*ziDAQ('progress', h));
        tRead = tic;
        if ziCheckPathInData(data, ['/' device '/demods/' config.demod_c(1) '/sample_r'])
            num_triggers = num_triggers + check_data(data, config);
            % Do some other processing and save data...
            % ...
        end
    end
    % Timeout check
    if toc(t0) > timeout
        % If for some reason we're not obtaining triggers quickly enough, the
        % following command will force the end of the recording.
        if num_triggers == 0
            ziDAQ('finish', h);
            ziDAQ('clear', h);
            error('Failed to acquire any triggers before timeout (%d seconds). Missing feedback cable between sigout 0 and sigin 0?', timeout);
        else
            fprintf('Acquired %d triggers. Loop timeout (%.2f s) before acquiring %d triggers\n');
            fprintf('Increase loop `timeout` to acquire more.\n', num_triggers, timeout, trigger_count);
        end
    end
end
End = toc(t0);

ziDAQ('unsubscribe', h, ['/' device '/demods/*/sample_r']);
ziDAQ('clear', h);

end

function num_triggers = check_data(data, config)
%CHECK_DATA check data for sampleloss and plot some triggers for feedback

device = config.device;
demod_idx = config.demod_idx;

% We use cell arrays to address the individual segments from each trigger
num_triggers = length(data.(device).demods(demod_idx(1)).sample_r);
if num_triggers == 0
    return
end
fprintf('Data contains %d data segments (triggers).\n', num_triggers);
sampleloss = check_segments_for_sampleloss(data, config);
if any(sampleloss)
    fprintf('Warning: Sampleloss detected in %d triggers.\n', sum(sampleloss));
    if sum(sampleloss) == num_triggers
        error('Error all triggers contained sampleloss.\n');
    end
else
    fprintf('No sampleloss detected.\n');
end

end

  % Unsubscribe all streaming data
  ziDAQ('unsubscribe','*');
  % Clean queue
  ziDAQ('flush');
  % Subscribe to the 0th IA module
  ziDAQ('subscribe',['/' device '/imps/0/sample']);

  % Poll command configuration
  pollDuration = 0.5; % [s]
  pollTimeout = 100; % [ms]
  pollFlag = 1; % set to 0: disable the dataloss indicator (or data imbetween
                % the polls will be filled with NaNs)
                % set to 1: Align data of several demodulators
                % set to 2: Throw if data loss is detected 

  %% Poll for data, it will return as much data as it can since the last
  % ziDAQ('flush',...)
  
cprintf('blue','Collecting data for %d s, elapsed time (s):\n',saveTime);
init_loop = 1;
tic
% continuously record transient data within the defined save time
while toc < saveTime
    data = ziDAQ('poll',pollDuration,pollTimeout,pollFlag);
    if init_loop
        timeStamp = data.(device).imps.sample.timestamp;
        %DIOBitVal = data.(device).demods.sample.bits;
        %sampleX = data.(device).demods.sample.x;
        sampleCap = data.(device).imps.sample.param1;
        sampleRes = data.(device).imps.sample.param0;
        %outData = data;
    else
        timeStamp = [timeStamp data.(device).imps.sample.timestamp];
        %DIOBitVal = [DIOBitVal data.(device).demods.sample.bits];
        %sampleX = [sampleX data.(device).demods.sample.x];
        sampleCap = [sampleCap data.(device).imps.sample.param1];
        sampleRes = [sampleRes data.(device).imps.sample.param0];
    end
    init_loop = 0;
    if mod(toc,5) < 0.515
        cprintf('blue','%d\n',floor(toc));
    end
    
    
end
timeStamp = double(timeStamp)/double(clock);
cprintf('green','Done\n')


% end of main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function device = autoDetect
  nodes = lower(ziDAQ('listNodes','/'));
  dutIndex = strmatch('dev', nodes);
  if length(dutIndex) > 1
    error('autoDetect does only support a single device configuration.');
  elseif isempty(dutIndex)
    error('No DUT found. Make sure that the USB cable is connected to the host and the device is turned on.');
  end
% Found only one device -> selection valid.
  device = lower(nodes{dutIndex});
  fprintf('Will perform measurement for device %s ...\n', device)
end