%SWITCHLAKESHORECURVE - switch between coldhead and he-reservoir
%
% switchLakeshoreCurve('he-reservoir') chooses the input curve for the
% he-reservoir.
%
% switchLakeshoreCurve('coldhead') chooses the coldhead input curve.
%
%
% Todd Karin
% 02/14/2013

function switchLakeshoreCurve(curveName)

curveName = lower(curveName);


% Initialize communication to temperature controller.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 12);
% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 0, 12);
else
    fclose(obj1);
    obj1 = obj1(1);
end

if ~isLakeshoreInstalled()
    error('Cannot communicate to lakeshore')
end

fopen(obj1);



switch curveName
    case 'he-reservoir'
        
        fprintf(obj1,'INCRV A,21');
        fprintf(obj1,'INNAME A,HE-RESERVOIR');

    case 'coldhead'

        fprintf(obj1,'INTYPE A,1,0,0')
        fprintf(obj1,'INCRV A,30');
        fprintf(obj1,'INNAME A,COLDHEAD');
    otherwise
        error('curve name must be either ''he-reservoir'' or ''coldhead'' ')
end


fclose(obj1)


% Snip out certain characters
function x =sn(x)
x(x==10)=[];
x(x==13)=[];