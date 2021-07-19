function device = MFIA_INIT(mfia)


%% MFIA Initialization, George Nelson Oct 2019
  
  clear ziDAQ;
  device = 0;
  
  %% Open connection to the ziServer (socket for sync interface)
  ziDAQ ('connect','127.0.0.1',8004,6);    % Use local data server for best performance
  %ziDAQ ('connect','169.254.40.222',8004,5);
  % Get device name automagically (e.g. 'dev234')
  device = autoDetect();
  % or specify manually
  %device = 'dev3327';

  
  % Enable IA module
  ziDAQ('setInt', ['/' device '/imps/0/enable'], 1);
  
  
  vrange = 10;
  irange = mfia.i_range;
  phase_offset = 0;
    
  % Setup IA module  
  ziDAQ('setInt', ['/' device '/imps/0/mode'], 1);
  ziDAQ('setInt', ['/' device '/system/impedance/filter'], 1);
  ziDAQ('setInt', ['/' device '/imps/0/model'], 0);
  ziDAQ('setInt', ['/' device '/imps/0/auto/output'], 0);
  ziDAQ('setInt', ['/' device '/system/impedance/precision'], 0);
  ziDAQ('setDouble', ['/' device '/imps/0/maxbandwidth'], 1000);
  ziDAQ('setDouble', ['/' device '/imps/0/omegasuppression'], 60);
  ziDAQ('setDouble', ['/' device '/imps/0/confidence/lowdut2t/ratio'], 1000);
 
  % Input settings, set to current and set range
  ziDAQ('setInt', ['/' device '/imps/0/auto/inputrange'], 0);
  ziDAQ('setDouble', ['/' device '/imps/0/current/range'], irange);
  %ziDAQ('setDouble', ['/' device '/imps/0/voltage/range'], vrange);
  
  % Lock in params & filtering
  ziDAQ('setInt', ['/' device '/imps/0/demod/sinc'], 1);
  ziDAQ('setInt', ['/' device '/imps/0/demod/order'], 8);
  ziDAQ('setInt', ['/' device '/imps/0/auto/bw'], 0);
  ziDAQ('setDouble', ['/' device '/demods/0/phaseshift'], phase_offset);
  ziDAQ('setDouble', ['/' device '/imps/0/demod/timeconstant'], mfia.time_constant);
  ziDAQ('setDouble', ['/' device '/imps/0/demod/harmonic'], 1);
    
  % Oscillator settings
  ziDAQ('setDouble', ['/' device '/imps/0/freq'], mfia.ac_freq);
  ziDAQ('setDouble', ['/' device '/imps/0/output/amplitude'], mfia.ac_ampl);
  
  % Output settings
  ziDAQ('setDouble', ['/' device '/imps/0/output/range'], vrange);
  ziDAQ('setInt', ['/' device '/imps/0/output/on'], 1);
  if mfia.pulse_height  % Check if a pulse bias is set, if so add to ss bias
    ziDAQ('setInt', ['/' device '/sigouts/0/add'], 1);
  else
    ziDAQ('setInt', ['/' device '/sigouts/0/add'], 0);
  end
  ziDAQ('setDouble', ['/' device '/sigouts/0/offset'], mfia.ss_bias);
  ziDAQ('setInt', ['/' device '/tu/thresholds/0/input'], 59);
  ziDAQ('setInt', ['/' device '/tu/thresholds/1/input'], 59);
  ziDAQ('setInt', ['/' device '/tu/thresholds/0/inputchannel'], 0);
  ziDAQ('setInt', ['/' device '/tu/thresholds/1/inputchannel'], 0);
  ziDAQ('setInt', ['/' device '/tu/logicunits/0/inputs/0/not'], 1);
  ziDAQ('setInt', ['/' device '/tu/logicunits/1/inputs/0/not'], 1);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/0/deactivationtime'], mfia.full_period-mfia.pulse_width);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/0/activationtime'], mfia.pulse_width);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/1/deactivationtime'], 0);
  ziDAQ('setDouble', ['/' device '/tu/thresholds/1/activationtime'], 0);
  ziDAQ('setInt', ['/' device '/auxouts/0/outputselect'], 13);
  ziDAQ('setInt', ['/' device '/auxouts/1/outputselect'], 13);
  ziDAQ('setInt', ['/' device '/auxouts/0/demodselect'], 0);
  ziDAQ('setInt', ['/' device '/auxouts/1/demodselect'], 1);
  ziDAQ('setDouble', ['/' device '/auxouts/0/scale'], mfia.pulse_height);
  ziDAQ('setDouble', ['/' device '/auxouts/0/offset'], 0);
  ziDAQ('setDouble', ['/' device '/auxouts/1/scale'], -5.0);
  ziDAQ('setDouble', ['/' device '/auxouts/1/offset'], 5.0);
  
  % Data stream settings
  ziDAQ('setDouble', ['/' device '/imps/0/demod/rate'], mfia.sample_rate);
  
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
