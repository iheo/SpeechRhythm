function stZ = sola(varargin);
% stZ = OVERLAPADD(stX, stY)
% stZ = overlapadd(stX, stY, maxoffset)
%
% stX : structure form
%   stX.vec = signal
%   stX.i1 = beginning index
%   stX.i2 = ending index
%
%   Example)
%           stX.i1 = 101;   stX.i2 = 180;   stX.vec = sin( (stX.i1:stX.i2)/5 );
%           stY.i1 = 130;   stY.i2 = 300;   stY.vec = 0.5*sin( (stY.i1 : stY.i2)/5 + 3);
%   
%       stZ = overlapadd(stX, stY);
%       stZ= overlapadd(stX, stY, maxoffset);
%
%       figure(1);
%           plot(stX.i1:stX.i2, stX.vec, 'b');   hold on;
%           plot(stY.i1:stY.i2, stY.vec, 'r');    hold on;
%           plot(stZ.i1:stZ.i2, stZ.vec, 'g');  hold off;

if nargin == 0
    stX.i1 = 101;   stX.i2 = 180;   stX.vec = sin( (stX.i1:stX.i2)/5 );
    stY.i1 = 130;   stY.i2 = 300;   stY.vec = 0.5*sin( (stY.i1 : stY.i2)/5 + 3);
    varargin{1} = stX;  varargin{2} = stY;
end

stX = varargin{1};
stY = varargin{2};

% Maximum admittable samples to search
% maxoffset = 3;
maxoffset = 15;
if nargin == 3
    maxoffset = varargin{3};
end

p1 = stX.i1;    p2 = stX.i2;
q1 = stY.i1;    % q2 = stY.i2;
x = stX.vec(:);    y = stY.vec(:);

Lx = length(x); Ly = length(y);
Km = -maxoffset : maxoffset;
Lk = length(Km);

% Pre-allocate to expedit the speed
xi1 = zeros(1, Lk); xi2 = xi1;
yi1 = xi1;  yi2 = xi1;
Lag = xi1;  Xcr = xi1 - 999;

for m = 1:Lk
    xi1(m) = Lx - (p2 - q1) + Km(m);    
    xi2(m) = Lx;
    
    yi1(m) = 1;
    yi2(m) = p2 - q1 + 1 - Km(m);    
    
    if xi1(m) >= Lx
        break;
    end
    try
        X = x(xi1(m):xi2(m)); Y = y(yi1(m):yi2(m));
    catch
        continue;
    end
    
    try
        [C, L] = xcorr(X, Y);
    catch
        if length(X)==1
            C = [0; 0; 0];
            L = [-1, 0, 1];
        end
    end
    Lag(m) = find(L==0);
    Xcr(m) = C(Lag(m));
    
%     figure(1);
%     plot(p1:p2, stX.vec, 'b'); hold on;
%     plot(p1 + (xi1(m) : xi1(m)+Ly-1), stY.vec, 'r'); hold on;    
%     hold off;   
%     title(Xcr(m));  legend('Input', 'Shifted Output');
%     pause;
end

% To see the variables
% [Km; xi1; xi2; yi1; yi2; xi2-xi1+1; yi2 - yi1 + 1;]'

% Find the lag with maximum correlation
[xcrmax, imax] = max(Xcr);
% maxLag = Lag(ixcrmax+1);

% process with the index
xi1 = xi1(imax); xi2 = xi2(imax);
yi1 = yi1(imax); yi2 = yi2(imax);

Lfade = length(xi1:xi2);
fadeinfun = (1:Lfade)'/Lfade;

% Applying crossfade
% xi1
z(1:xi1-1) = x(1:xi1-1);
xFaded = x(xi1:xi2).*(1-fadeinfun);
yFaded = y(yi1:yi2).*fadeinfun;
z(xi1 : xi2) = xFaded + yFaded;
z(Lx + 1 : xi1 + Ly-1) = y(yi2+1:Ly);

% Variable organization
stZ.vec = z;
stZ.i1 = p1;    stZ.i2 = p1 + length(z) - 1;

%% Plotting
% figure(2);
% lstr{1} = 'X';    plot(stX.i1:stX.i2, stX.vec, 'b');  hold on;
% lstr{2} = 'Y';    plot(stY.i1:stY.i2, stY.vec, 'r');
% lstr{3} = 'Adjusted Y'; plot( (stY.i1:stY.i2) + Km(imax), stY.vec, 'r:');
% lstr{4} = 'Overlapped'; plot(stZ.i1:stZ.i2, stZ.vec, 'g'); 
% hold off;
% legend(lstr);
% plot(z(1:xi1-1), 'b--');   hold on;
% plot(xi1:xi2, x(xi1:xi2), 'b');   hold on;
% plot(xi1:xi2, x(xi1:xi2).*(1-fadeinfun), 'b:');   hold on;
% plot(xi1:xi2, y(yi1:yi2), 'r');   hold on;
% plot(xi1:xi2, y(yi1:yi2).*(fadeinfun), 'r:');   hold on;
% plot(Lx+1 : xi1 + Ly, y(yi2:Ly), 'r--'); hold off;

% figure(3);
% plot(z);