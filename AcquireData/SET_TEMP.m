function [] = SET_TEMP(setPoint,tempStable,timeStable)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
lakeshoreQuery(strcat('SETP ',num2str(setPoint)));  % Set point to lakeshore
getCurrentTemp = sampleSpaceTemperature;
getCurrentWait = timeStable;
unstable = false;
while (abs(getCurrentTemp - setPoint) > tempStable) || (getCurrentWait >= 0)  % Continuously loop the time and temp stability until both are met
    while abs(getCurrentTemp - setPoint) > tempStable
        pause(2);  % Wait for temperature to reach set point
        getCurrentTemp = sampleSpaceTemperature;
        cprintf('blue','Current Temp: %3.2f.  Set point: %d.  Delta: %2.2f.\n',getCurrentTemp,setPoint,abs(getCurrentTemp - setPoint));
        % TODO: Check for errors here
    end
    unstable = false;
    while getCurrentWait >= 0 && unstable == false
        cprintf('blue','Wait for time stability: %d s left.\n',getCurrentWait);
        pause(1);                          % Wait 1 second
        getCurrentWait = getCurrentWait - 1;          % Subtract one from our counter
        getCurrentTemp = sampleSpaceTemperature;
        if abs(getCurrentTemp - setPoint) > tempStable  % check again for temp stability, if not stable then flag for restart
            unstable = true;
        end
    end
    if unstable == true  % check again for temp stability, if not stable then restart process
        getCurrentWait = timeStable;
        cprintf([0.9100 0.4100 0.1700],'Temperature not time stable (refine PID?), restarting stability process...\n');
    end
end
cprintf('green', 'Temperature has stabilized!\n');
end
