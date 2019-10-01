function [timeStamp, sampleCap, sampleRes] = MFIA_CAPACITANCE_ACQ(Fs, timeConstant, ssBias, acFreq, acAmplitude, saveTime)


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


  clear ziDAQ;
  
  %% Open connection to the ziServer (socket for sync interface)
  %ziDAQ('connect', '192.168.51.254', 8004, 5);
  %ziDAQ ('connect','127.0.0.1',8004,6);
  ziDAQ ('connect','169.254.40.222',8004,5);
  % Get device name automagically (e.g. 'dev234')
  device = autoDetect();
  % or specify manually
  %device = 'dev3327';
  
  %% Configure the MFIA (assumes SigIn 0 connected to SigOut 0)
  %ziDAQ('set', h, 'deviceSettings/command', 'load_none');
  %ziDAQ('set', h, 'deviceSettings/command', 'load');
  %ziDAQ('set', h, 'deviceSettings/filename', 'dlts2');
  %ziDAQ('set', h, 'deviceSettings/throwonerror', 0);
  %ziDAQ('execute', h);
  
  % Enable IA module
  ziDAQ('setInt', ['/' device '/imps/0/enable'], 1);
  
  
  vrange = 10;
  irange = 0.0001;
  %irange = 0.001;
  phase_offset = 0;
  
  
  % Setup IA module  
  ziDAQ('setInt', ['/' device '/imps/0/mode'], 1);
  ziDAQ('setInt', ['/' device '/system/impedance/filter'], 1);
  ziDAQ('setInt', ['/' device '/imps/0/model'], 0);
  ziDAQ('setInt', ['/' device '/imps/0/auto/output'], 0);
  ziDAQ('setInt', ['/' device '/system/impedance/precision'], 0);
  ziDAQ('setDouble', ['/' device '/imps/0/maxbandwidth'], 1000);
  ziDAQ('setDouble', ['/' device '/imps/0/omegasuppression'], 60);
 
  % Input settings, set to current and set range
  ziDAQ('setInt', ['/' device '/imps/0/auto/inputrange'], 0);
  ziDAQ('setDouble', ['/' device '/imps/0/current/range'], irange);
  %ziDAQ('setDouble', ['/' device '/imps/0/voltage/range'], vrange);
  
  % Lock in params & filtering
  ziDAQ('setInt', ['/' device '/imps/0/demod/sinc'], 1);
  ziDAQ('setInt', ['/' device '/imps/0/demod/order'], 8);
  ziDAQ('setInt', ['/' device '/imps/0/auto/bw'], 0);
  ziDAQ('setDouble', ['/' device '/demods/0/phaseshift'], phase_offset);
  ziDAQ('setDouble', ['/' device '/imps/0/demod/timeconstant'], timeConstant);
  ziDAQ('setDouble', ['/' device '/imps/0/demod/harmonic'], 1);
    
  % Oscillator settings
  ziDAQ('setDouble', ['/' device '/imps/0/freq'], acFreq);
  ziDAQ('setDouble', ['/' device '/imps/0/output/amplitude'], acAmplitude);
  
  % Output settings
  ziDAQ('setDouble', ['/' device '/imps/0/output/range'], vrange);
  ziDAQ('setInt', ['/' device '/imps/0/output/on'], 1);
  %ziDAQ('setInt', ['/' device '/sigouts/0/add'], 0);
  ziDAQ('setDouble', ['/' device '/sigouts/0/offset'], ssBias);
  
  clock =  ziDAQ('getInt', ['/' device '/clockbase']);  % find MFIA clock
  %for timestamp
  
  % Data stream settings
  ziDAQ('setDouble', ['/' device '/imps/0/demod/rate'], Fs);
  
  
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