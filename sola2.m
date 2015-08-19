function [stZ] = sola2(varargin);
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
    stY.i1 = 115;   stY.i2 = 300;   stY.vec = 0.5*sin( (stY.i1 : stY.i2)/5 + 5);
    varargin{1} = stX;  varargin{2} = stY;    
end

stX = varargin{1};
stY = varargin{2};

% Maximum admittable samples to search
maxoffset = 15;
if nargin == 3
    maxoffset = varargin{3};
end

p1 = stX.i1;    % p2 = stX.i2;
q1 = stY.i1;    % q2 = stY.i2;

Ndiff = abs(q1-p1);
maxoffset = min(maxoffset, Ndiff);
x = stX.vec(:);
y = [zeros(Ndiff, 1); stY.vec(:)];

[acor, lag] = xcorr(x, y, maxoffset);  % x : previous, y : current to be appended to x
[~, I] = max((acor));
offset = lag(I);

if offset < 0    
    ynew = y(-offset+1:end);
    inew = Ndiff + stX.i1 + (-offset+1:length(y)) - 1;
else    
    ynew = [zeros(offset, 1); y];
    inew = (stY.i1:stY.i2) - offset;
end

% Crossfade
Idx.x.alone = 1:Ndiff+offset;
Idx.x.fadeout = Ndiff+offset+1:length(x);
Idx.ynew.fadein = Ndiff+offset+1:length(x);
Idx.ynew.alone = length(x)+1 : length(ynew);

Idx.x.alone;
Lfade = length(Idx.x.fadeout);
fadeinfun = (1:Lfade)'/Lfade;


try
    z(Idx.x.alone) = x(Idx.x.alone);
    z(Idx.x.fadeout) = (1-fadeinfun).*x(Idx.x.fadeout) + fadeinfun.*ynew(Idx.ynew.fadein);
catch
    disp('dfd');
end
z(Idx.ynew.alone) = ynew(Idx.ynew.alone);


stZ.i1 = stX.i1;
stZ.i2 = stX.i1 + length(z) - 1;
stZ.vec = z(:)';