%GETLAKESHORECURVE - Reads curves from the lakeshore
%
% lakeshore = getLakeshoreCurve() reads information from the Lakeshore and
% returns it as a sturcture. Specifically, it extracts curves 26 and 30 but
% this can be changed in the code.
%

% Todd Karin
% 02/14/2013

function lakeshore = getLakeshoreCurve()

% Initialize communication to temperature controller.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 12);
% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 1, 12);
else
    fclose(obj1);
    obj1 = obj1(1);
end

if ~isLakeshoreInstalled()
    error('Cannot communicate to lakeshore')
end

fopen(obj1);

% Set Intypes
%fprintf(obj1,'INTYPE A,1,0,1,0,1')
lakeshore.intypeA = sn(query(obj1,'INTYPE? A'));

%fprintf(obj1,'INTYPE B,3,1,5,0,1')
lakeshore.intypeB = sn(query(obj1,'INTYPE? B'));

% Set Curve settings.
%fprintf(obj1, 'CRVHDR 21, CX-1050-CU-1.4L,X75691    ,4,+325.000,1')
%fprintf(obj1, 'CRVHDR 22, CX-1050-CU-1.4L,X75691    ,4,+325.000,1')
lakeshore.curveHeader26 = sn(query(obj1,'CRVHDR? 26'));
lakeshore.curveHeader30 = sn(query(obj1,'CRVHDR? 30'));
%fprintf(obj1,'INNAME A,COLD HEAD')
%fprintf(obj1,'INNAME B,SAMPLE-SPACE')
lakeshore.sensorInputNameA = sn(query(obj1,'INNAME? A'));
lakeshore.sensorInputNameB = sn(query(obj1,'INNAME? B'));

% Set curves to use for A and B
%fprintf(obj1,'INCRV A,21')
lakeshore.inputCurveNumberA = sn(query(obj1,'INCRV? A'));
%fprintf(obj1,'INCRV B,22')
lakeshore.inputCurveNumberB = sn(query(obj1,'INCRV? B'));


lakeshore.inputReadingStatusA = sn(query(obj1,'RDGST? A'));
lakeshore.inputReadingStatusB = sn(query(obj1,'RDGST? B'));

lakeshore.temperatureA = sn(query(obj1,'KRDG? A'));
lakeshore.temperatureB = sn(query(obj1,'KRDG? B'));

% 
 disp('Reading Curve 26 ...')
for i=1:200
lakeshore.curve26String(i,:) = sn(query(obj1,['CRVPT? 26,' num2str(i)]));
lakeshore.curve26(i,:) = str2num(['[' lakeshore.curve26String(i,:) ']' ]);
end

disp('Reading Curve 30 ...')
for i=1:200
lakeshore.curve30String(i,:) = sn(query(obj1,['CRVPT? 30,' num2str(i)]));
lakeshore.curve30(i,:) = str2num(['[' lakeshore.curve30String(i,:) ']' ]);
end


% 
% % Make a new curve
% disp('Setting Curve 21 ...')
% fprintf(obj1,'CRVHDR 21,CX-1050-CU-1.4L,X75691,3,325.0,1')
% for i=1:200
%     fprintf(obj1,['CRVPT 21,' num2str(i) ',' lakeshore.curve21String(i,:)])
% end
% fprintf(obj1,'INCRV A,21')
% lakeshore.inputCurveNumberA = sn(query(obj1,'INCRV? A'));

%fprintf(obj1,'DFLT 99')

% Close communication.
fclose(obj1)


% Snip out certain characters
function x =sn(x)
x(x==10)=[];
x(x==13)=[];