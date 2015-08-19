function varargout = tsheo_20140914(varargin)
% Xout = tsheo(Xin, Ref, mappingtable)

Xin = varargin{2};  
XinLen = length(Xin);
Ref = varargin{1};  XoutLen = length(Ref);
mappingTable = varargin{3};
A = mappingTable(:, 1);
B = mappingTable(:, 2);

NwFix = round( max(diff(A))*1.1);   % 5000
NsFix = round( min(diff(A))/4); % 30

if nargin > 3
    NwFix = varargin{4};
    NsFix = varargin{5};
end

% Free Variable Indicating the starting hop index
p1 = A(1);
q1 = B(1);

% Initialize
k = 1;  tsratio = 1;

Xout = zeros(XoutLen, 1);       % Pre-allocate the output 
Wout = [zeros(size(Xout)); zeros(size(Xout))];
M = length(A);
fprintf('Progress :  ');
while(1)
    m = max(find( p1 - A + 1 > 0));
    
    p2 = p1 + NwFix - 1;
    if p2 > XinLen
        fprintf('  --- p2 > XinLen');
        break;
    end
    
    try
        a1 = A(m);   a2 = A(m+1);
        b1 = B(m);   b2 = B(m+1);
    catch
        fprintf('Index Limit Successfully Approached');
        break;
    end
    
    if k==1
        q1Prev = q1;    q2Prev = q1 + NwFix - 1;
    else
        tsratio = (b2 - b1) / (a2 - a1);
        
        q1 = (p1 - a1)*tsratio + b1;    % solve for q1 :   (q1 - b1) / (b2 - b1) == (p1 - a1) / (a2 - a1)       
        q1 = round(q1);
        q2 = q1 + NwFix - 1;
        
        if q2 > XoutLen 
            q2 = XoutLen;
        end
        
        Uprev.i1 = q1Prev;  Uprev.i2 = q2Prev;
        Uprev.vec = Xout(q1Prev:q2Prev);
        
        U.i1 = q1;  U.i2 = q2;
        U.vec = Xin(p1:p2);
        
%         stZ = sola(Uprev, U);
        stZ = sola2(Uprev, U);
        Xout(stZ.i1 : stZ.i2) = stZ.vec;
        Wout(stZ.i1 : stZ.i2) = Wout(stZ.i1 : stZ.i2) +  ones(size(stZ.vec))';
        
        q1Prev = q1;    q2Prev = q2;
    end
    datlog(k, :) = [tsratio, a1, p1, a2, b1, q1, b2];
    
    p1Prev = p1;    p2Prev = p1 + NwFix - 1;
    p1 = p1 + NsFix;
    
    k = k + 1;
    if mod(k, 500) == 0
        fprintf('%.0f ', m/M*100);
    end
end
fprintf('\n');
% NZ = Xout==0;
% Xout(NZ) = [];  Wout(NZ) = [];
varargout{1} = Xout;
% varargout{1} = Xout./Wout(1:length(Xout));
varargout{2} = datlog;