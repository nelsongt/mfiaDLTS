function [temp] = LAKESHORE_INIT(temp)
% SUMMARY: Check if a Lakeshore is connected, can be communicated with, and then setup the user-provided Lakeshore parameters
% Returns true if successful in all Lakeshore communications, otherwise returns false

% Check for Lakeshore 331 or 335
success = true;
temp.model = isLakeshoreInstalled();
if temp.model==0
    cprintf('red','Supported Lakeshore Model Not Found. Connect and restart. Exiting...\n');
    success = false;
else
end
    
% Setup Lakeshore

if temp.model == 331
    config_string = strcat(temp.control,',1,0,2');        % Control sensor A or B, in Kelvin (1), default heater off (0), heater units power (2)
    response = lakeshoreQuery('CSET?');
    if ~strcmp(response,config_string)
        lakeshoreQuery(strcat('CSET 1,',config_string));   % Control loop 1, then see config string above
    end
elseif temp.model == 335
    if temp.control == A
        config_string = strcat('2,1,0');                  % Control by zone (1), sensor A(1) or B(2), default heater off (0)
    elif temp.control == B
        config_string = strcat('2,2,0');
    end
    response = lakeshoreQuery('OUTMODE? 1');
    if ~strcmp(response,config_string)
        lakeshoreSet(strcat('OUTMODE 1,',config_string));   % Control loop 1, then see config string above
    end
else
    cprintf('red','Error, Unsupported Lakeshore Model Detected'); % This shouldn't happen...
    success = false;
end


range_string = int2str(temp.heatpower);
if temp.model == 331
    response = lakeshoreQuery('RANGE?');
elseif temp.model == 335
    response = lakeshoreQuery('RANGE? 1');
end

if ~strcmp(response,range_string)
    if temp.model == 331
        lakeshoreQuery(strcat('RANGE ',range_string));          % Set heater to high (3), medium (2), low (1)
    elseif temp.model == 335
        lakeshoreSet(strcat('RANGE 1,',range_string));
    end
end
if strcmp(response,'-1')
    cprintf('red','Error configuring Lakeshore. Exiting...\n');
    success = false;
end
cprintf('green','Lakeshore configure OK.\n');
end

