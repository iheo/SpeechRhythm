function iiXNew = idxmapperv2(varargin)
% iiXNew = idxmapperv2(iiX, iiY);
% iiXNew = idxmapperv2(iiX, iiY, 'center');
% iiXNew = idxmapperv2(iiX, iiY, 'left');
% iiXNew = idxmapperv2(iiX, iiY, 'right');

iiX = varargin{1};
iiY = varargin{2};
PickKind = 'center';
if nargin == 3
    PickKind = varargin{3};
end

N = max(iiY);
iiXNew = zeros(N, 1);

% figure
% figure(2);
% plot(iiX, iiY); hold on;
for n = 1:N
    idxs = find(iiY == n);
    if isempty(idxs)
        disp('empty idxs ?');
    end
    iiXNew(n) = floor(median(iiX(idxs)));
%     plot(iiXNew(n), n, 'r.');
end
% hold off;