function W = getvwins(varargin);
% function getvwin(varframes, 'awin');
% function getvwin(varframes, 'frame');
varframes = varargin{1};
varkind = 'awin';
if nargin==2
    varkind = varargin{2};
end

for i = 1:length(varframes)
    W(varframes(i).p1:varframes(i).p2, i) = varframes(i).(varkind);
end