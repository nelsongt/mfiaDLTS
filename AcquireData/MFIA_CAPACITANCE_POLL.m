function [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_POLL(device,saveTime,acFreq)


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
  
  % Oscillator settings
  ziDAQ('setDouble', ['/' device '/imps/0/freq'], acFreq);  % Here for YSpec

  % Unsubscribe all streaming data
  ziDAQ('unsubscribe','*');
  % Clean queue
  ziDAQ('flush');
  % Subscribe to the 0th IA module
  ziDAQ('subscribe',['/' device '/imps/0/sample']);
  
  clock =  ziDAQ('getInt', ['/' device '/clockbase']);  % find MFIA clock
  %for timestamp

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

end

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