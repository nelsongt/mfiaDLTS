function [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_DAQ(deviceId,mfia)
%deviceId='dev3327';
%sampleTime=10;
%transientLength=0.15;

%% George Nelson Oct 2019, based on ZI example script

if ~exist('deviceId', 'var')
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
sample_rate = ziDAQ('getDouble', ['/' deviceId '/imps/0/demod/rate']);
trigger_count = ceil(0.9*mfia.sample_time/mfia.trns_length);
sample_count = sample_rate*mfia.trns_length;
ziDAQ('set', h, 'dataAcquisitionModule/device', deviceId)
ziDAQ('set', h, 'dataAcquisitionModule/count', trigger_count);
ziDAQ('set', h, 'dataAcquisitionModule/endless', 0);
ziDAQ('set', h, 'dataAcquisitionModule/grid/mode', 4);
ziDAQ('set', h, 'dataAcquisitionModule/type', 6);
ziDAQ('set', h, 'dataAcquisitionModule/triggernode', ['/' deviceId '/demods/0/sample.trigin1']);
%   edge:
%     POS_EDGE = 1
%     NEG_EDGE = 2
%     BOTH_EDGE = 3
ziDAQ('set', h, 'dataAcquisitionModule/edge', 2)
ziDAQ('set', h, 'dataAcquisitionModule/grid/cols', sample_count);
ziDAQ('set', h, 'dataAcquisitionModule/grid/rows', 1);
ziDAQ('set', h, 'dataAcquisitionModule/holdoff/time', 0.0);
ziDAQ('set', h, 'dataAcquisitionModule/delay', 0.0);

%% Subscribe to the demodulators
% Subscribe to the 0th IA module
ziDAQ('subscribe', h, ['/' deviceId '/imps/0/sample.param1']);


%% Start recording
% now start the thread -> ready to be triggered
ziDAQ('execute', h);

timeout = 1.3*mfia.sample_time; % [s]
total_triggers = 0;
sampleCap = [];
t0 = tic;
tRead = tic;
dt_read = 2.1;
transferNotFinished = ~ziDAQ('finished', h);
while transferNotFinished && toc(t0) < timeout
    pause(0.05);
    % Perform an intermediate readout of the data. the data between reads is
    % not acculmulated in the module - it is cleared, so that the next time
    % you do a read you (should) only get the triggers that came inbetween the
    % two reads.
    if toc(tRead) > dt_read 
        data = ziDAQ('read', h);
        if ziCheckPathInData(data, ['/' deviceId '/imps/0/sample_param1'])
            loop_triggers = length(data.(deviceId).imps(1).sample_param1);
            total_triggers = total_triggers + loop_triggers;
            % save data, using some idea of mine that might save CPU time
            capData = [];
            for i = 1:loop_triggers
                capData = [capData; data.(deviceId).imps(1).sample_param1{1,i}.value];
                timeStamp = []; %TODO
            end
            sampleCap = [sampleCap; capData];
        end
        cprintf('blue','Acquired %d of total %d transients: %.1f%% (elapsed time %.3f s)\n', total_triggers, trigger_count, 100*ziDAQ('progress', h),toc(t0));
        tRead = tic;
        transferNotFinished = ~ziDAQ('finished', h);
    end
end
% Timeout check
if toc(t0) > timeout
   % If for some reason we're not obtaining triggers quickly enough, the
   % following command will force the end of the recording.
   if total_triggers == 0
      ziDAQ('finish', h);
      ziDAQ('clear', h);
      error('Trigger failure before timeout (%d seconds). Missing feedback cable between sigout 2 and trigin 1?', timeout);
   else
      cprintf('systemcommands','Warning: Only acquired %d transients. Operation timed out (%.2f s) before acquiring %d transients.\n', total_triggers, timeout, trigger_count);
   end
else
    cprintf('green','Done.\n');
end

ziDAQ('unsubscribe', h, ['/' deviceId '/imps/0/sample'])
ziDAQ('clear', h);

end