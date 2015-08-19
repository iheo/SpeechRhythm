function isSilence = SilenceDetector(varargin)
% returns the same length vector of the input, indicating 1 silence 0 no silence

vec = varargin{1};
LenVec = length(vec);
Fs = varargin{2};

threshold = .2;
direction = 'ascend';
if nargin==3
    threshold = varargin{2};
end
if nargin==4
    direction = varargin{3};   % 'ascend', 'descend'
end

Nw = 15e-3*Fs; % winsize
Ns = 5e-3*Fs;  % hop size

[frames, indexes] = vec2frames(vec, Nw, Ns, 'cols', @hanning, true);

[Ndim, Nframe] = size(frames);
NPickFrames = round(Nframe*threshold);
isFrameSilence = zeros(1, Nframe);

% Sort Featgram energy
% Energy.raw = sum(frames.^2);    % Only energy

fftframes = fft(frames);
[nfft, nframes] = size(fftframes);
fftframes = fftframes(2:nfft/2*1/2, :); % Band pass filtered (not consider highfrequency energy)
mag = abs(fftframes);
Energy.raw = sum(mag.^2, 1);
[Energy.sorted Energy.sortedIdx] = sort(Energy.raw, direction);

isFrameSilence(Energy.sortedIdx(1:NPickFrames)) = 1;

% isSilence = medfilt1(isSilence, 5);
frameidxSilence = find(isFrameSilence);

SilenceSumIdx = zeros(indexes(end, end), 1);

for k = 1:length(frameidxSilence)
    interval = indexes(1, frameidxSilence(k)):indexes(Ndim, frameidxSilence(k));
    SilenceSumIdx(interval) = SilenceSumIdx(interval) + 1;
end

isSilence = (SilenceSumIdx==3);
isSilence = isSilence(1:LenVec);

