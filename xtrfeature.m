% The input/output routine is modified from timit version, timit_uvfeatcreate.m
% Feature for the purpose of voiced / unvoiced classification, with the use of SVM classifier.

function F = xtrfeature(varargin)
% F = xtrfeature(audiodata, P)
% P is the parameter structure
% P includes P.nfft, P.Ns, P.Nw
% Typical values P.nfft = 512, P.Nw = 480 (30ms), P.Ns = 160 (10ms)
%
% Return Values
%   feature vectors in structure form, F.zc, F.sf, F.kurt, F.mfcc
%   F.zc
%   F.sf
%   F.kurt
%   F.mfcc
%     and the label F.label be either 0 (unvoiced) or 1 (voiced)
%     deteremined by pre-trained SVM_RBF
%
%    open svmstruct.mat to see more detail about support vector machine trained parameters.

global nfft Ns Nw

audiodata = varargin{1};
P = varargin{2};
isNormalize = 0;
if nargin==3
    if strcmp(varargin{3}, 'normalize')
        isNormalize = 1;
    end
end

nfft = P.nfft;
Ns = P.Ns;
Nw = P.Nw;

features = {'zc', 'sf', 'kurt', 'mfcc'};
F = struct;

for ii = 1:length(features)
    feat = getfeature(audiodata, features{ii}, P);        
    if isNormalize        
        feat = normalize(feat);        
    end        
    F = setfield(F, features{ii}, feat);
end
F = setfield(F, 'frameidx', getfeature(audiodata, 'frameidx', P));
end

function st_feat = getfeature(audiodata, featname, P)    
    global Ns Nw
    x.vec = audiodata;
    x.frames = vec2frames(x.vec, Nw, Ns, 'cols', @hamming);
    switch featname
        case 'zc'
            st_feat = zerocrossing(x.frames);
        case 'sf'
            st_feat = spectralflatness(x.frames);
        case 'melsf'
            st_feat = spectralflatnessmel(x.frames);
        case 'ne'
            st_feat = normedfenergy(x.frames);
        case 'kurt'
            st_feat = kurtosis(x.frames);
        case 'acf'  % Removed
            st_feat = acf(x.frames, 10);     
        case 'mfcc'
            st_feat = mfcc(x.frames, 13);
        case 'lsf'
            st_feat = getlsf(x.frames, 13);
        case 'sc'
            st_feat = spectralcentroid(x.frames);
        case 'er'
            st_feat = energyratio(x.frames);
        case 'frameidx'
            st_feat = vec2frames(1:length(x.vec), Nw, Ns, 'cols');
    end
end

function feat = energyratio(frames)
    global nfft
    L = 2:nfft/2;
    X = fft(frames, nfft);
    mag = abs(X);   mag = mag(L, :);
    L1 = zeros(size(L));   L1(2:20) = 1;   % up to 20th bin is 625 Hz
    feat = L1*mag./sum(mag);
end

function feat = spectralcentroid(frames);
    global nfft
    L = 2:nfft/2;
    X = fft(frames, nfft);
    mag = abs(X);       mag = mag(L, :);
    feat = L*mag./sum(mag);
end

function feat = mfcc(frames, featdim)
    global nfft
    X = fft(frames, nfft);
    mag = abs(X);   mag = mag(1:nfft/2, :);    
    hz2mel = @( hz )( 1127*log(1+hz/700) );     % Hertz to mel warping function
    mel2hz = @( mel )( 700*exp(mel/1127)-700 ); % mel to Hertz warping function
    dctm = @( N, M )( sqrt(2.0/M) * cos( repmat([0:N-1].',1,M) ...
                                       .* repmat(pi*([1:M]-0.5)/M,N,1) ) );

    H = trifbank(40, nfft/2, [100 4000], 16000, hz2mel, mel2hz ); % size of H is M x K     
    DCT = dctm( featdim, 40 );
    
    FE = H*mag;
    feat =  DCT * log( FE );
end

function feat = getlsf(frames, featdim)
    global nfft
    X = fft(frames, nfft);
    mag = abs(X);   mag = mag(1:nfft/2, :);
    lpcs = transpose(lpc(mag, featdim));
    feat = zeros(featdim, size(frames, 2));
    for k = 1:size(lpcs, 2)
        feat(:, k) = poly2lsf(lpcs(:, k));
    end
end
function feat = acf(frames, dim)
    [Nw nframes] = size(frames);
    feat = zeros(dim, nframes);
    for m = 1:nframes
        X = xcorr(frames(:, m), dim);
        feat(:, m) = X(dim+2:end)/X(dim+1);
    end    
end

function Z = zerocrossing(frames);
    frames1 = frames(2:end, :);
    frames2 = frames(1:end-1, :);
    Z = sum(frames1.*frames2 < 0);
end

function F = spectralflatnessmel(frames)
% Approaching 1 for white noise
% Approaching 0 for pure tone    
    global nfft
    X = fft(frames, nfft);
    mag = abs(X);   mag = mag(1:nfft/2, :);    
    hz2mel = @( hz )( 1127*log(1+hz/700) );     % Hertz to mel warping function
    mel2hz = @( mel )( 700*exp(mel/1127)-700 ); % mel to Hertz warping function
    
    H = trifbank(40, nfft/2, [100 4000], 16000, hz2mel, mel2hz ); % size of H is M x K 
    FE = H*mag;
    F = geomean(FE, 1)./mean(FE, 1);    
end

function F = spectralflatness(frames)
% Approaching 1 for white noise
% Approaching 0 for pure tone    
    global nfft
    X = fft(frames, nfft);
    mag = abs(X);   mag = mag(1:nfft/2, :);    
    Gmean = geomean(mag, 1);
    Amean = mean(mag, 1);
    F = Gmean./Amean;    
end

function Ex = normedfenergy(frames)
    % Normed Frame Energy    
    alpha = .96;
    E = sum(frames.^2, 1);
    Emin = min(E)*.99;
    alpha = .96;
    E_ = alpha*(mean(E)) + (1-alpha)*E(1);
    for m = 2:size(frames, 2)
        E_(m) = alpha*E_(m-1)+(1-alpha)*E(m);
    end
    Ex = ( log(E) - log(Emin))./(log(E_) - log(Emin));    
end

function mag = frames2mag(frames)
    global nfft
    X = fft(frames, nfft);
    X = X(2:nfft/2, :); % No dc
    mag = abs(X);
end

function Y = normalize(X, direction);
% Y = ccnorm(X, direction);
% Y = ( X - E[X]) / std[X]
% 
% direction (averaged over) 1-column, 2 - rows
% Default is 2, where X is D-by-N, 
%       where D is the dimension of feature, N is number of observations
% 
% same as if mean(rand(3, 4), 1) will have size 1-by-4
%               mean(rand(3, 4), 2) will have size 3-by-1
% mean subtraction
% variance normalization
%

if ~exist('direction')
    direction = 2;
end

mX = mean(X, direction);
sX = std(X, [], direction);

switch direction
    case 1
        mX = repmat(mX, size(X, 1), 1);
        sX = repmat(sX, size(X, 1), 1);
    case 2
        mX = repmat(mX, 1, size(X, 2));
        sX = repmat(sX, 1, size(X, 2));
end
Y = (X - mX)./sX;
end