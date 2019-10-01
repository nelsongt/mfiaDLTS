%programLakeshoreCurve - program a given curve to the lakeshore
%
% Programs the lakeshore temperature controller for the Kai-Mei Fu lab.
% Curve 30 is for the cold head and curve 26 is for the helium reservoir.
%
% Todd Karin
% 02/14/2013

function programLakeshoreCurve()

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

% First load the data
load('lakeshoreCurve_11_05_2014.mat')


disp('Programming First Curve 40 ...')
curveNo = 40;
fprintf(obj1,['CRVHDR ' num2str(curveNo) ',crv26cpy,crv26cpy:sn,4,325,1'])
curveToWrite = lakeshore.curve26String;
for j=1:length(curveToWrite)
    fprintf(obj1,['CRVPT ' num2str(curveNo) ',' num2str(j) ',' curveToWrite(j,:) ])
end

disp('Programming Second Curve to 41 ...')
curveNo = 41;
fprintf(obj1,['CRVHDR ' num2str(curveNo) ',crv30cpy,crv30cpy:sn,4,325,1'])
curveToWrite = lakeshore.curve30String;
for j=1:length(curveToWrite)
    fprintf(obj1,['CRVPT ' num2str(curveNo) ',' num2str(j) ',' curveToWrite(j,:) ])
end


disp('Programming complete!')



% Close communication.
fclose(obj1)


% Snip out certain characters
function x =sn(x)
x(x==10)=[];
x(x==13)=[];