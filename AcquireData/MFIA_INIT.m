function success = MFIA_CAPACITANCE_ACQ(Fs, timeConstant, ssBias, pBias, acFreq, acAmplitude, saveTime)


%% MFIA Initialization, George Nelson Oct 2019


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
  ziDAQ('setInt', ['/' device '/sigouts/0/add'], 1);
  ziDAQ('setDouble', ['/' device '/sigouts/0/offset'], ssBias);
  ziDAQ('setInt', ['/' device '/tu/thresholds/0/input'], 59);
  ziDAQ('setInt', ['/' device '/tu/logicunits/0/inputs/0/not'], 1);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/0/deactivationtime'], 0.151);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/0/activationtime'], 0.01);
  ziDAQ('setInt', ['/' device '/auxouts/0/outputselect'], 13);
  ziDAQ('setDouble', ['/' device '/auxouts/0/scale'], pBias);
  
  clock =  ziDAQ('getInt', ['/' device '/clockbase']);  % find MFIA clock
  %for timestamp
  
  % Data stream settings
  ziDAQ('setDouble', ['/' device '/imps/0/demod/rate'], Fs);
  
  success = 1;
end
  
% end of main function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function device = autoDetect
  nodes = lower(ziDAQ('listNodes','/'));
  dutIndex = strmatch('dev', nodes);
  if length(dutIndex) > 1
    error('autoDetect does only support a single MFIA configuration.');
  elseif isempty(dutIndex)
    error('No DUT found. Make sure that the USB cable is connected to the host and the device is turned on.');
  end
% Found only one device -> selection valid.
  device = lower(nodes{dutIndex});
  fprintf('Initialized MFIA %s ...\n', device)
end
