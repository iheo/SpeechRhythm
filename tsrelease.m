function varargout = tsrelease(varargin)
% [NewMappingTable, NewR] = tsrelease(mappingindex)
% mapping index is two column index table (1st column analysis 2nd column synthesis)

p1 = varargin{1}(:, 1);
q1 = varargin{1}(:, 2);
Rthr = 2;
if nargin==3
    Rthr = varargin{3};
end
Lp = length(p1);
R = zeros(1, Lp);    
ii = 1; m = 2;  newp1(1) = p1(1);   newq1(1) = q1(1);
for k = 2:length(p1)
        p1diff = p1(k) - p1(k-1);
        q1diff = q1(k) - q1(k-1);
        R(k) = q1diff / p1diff;
        if R(k) > Rthr
%             dat(k-2:k+2, 2:end);
            ii = ii + 1;
        else
            newp1(m) = p1(k);    newq1(m) = q1(k);
            newR(m) = (newq1(m) - newq1(m-1))/(newp1(m) - newp1(m-1));
            m = m+1;
        end
end


NewMappingTable = [newp1(:), newq1(:)];
varargout{1} = NewMappingTable;
varargout{2} = newR;
end