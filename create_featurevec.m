clear all;
% (1) create_featurevec.m
% (2) create_gmm.m
% (3) classify_gmm.m

% warning off
warning('off', 'MATLAB:audiovideo:wavread:functionToBeRemoved');

load FileWav16kHz

% Feature name
FeatureKind = 'Mfcc';
% FeatureKind = 'Lpc';
% FeatureKind = 'RastaPlp';

%% Feature Parameters
Fs = 16000;
p.Nw = Fs*.03;
p.Ns = Fs*.01;
p.nfft = 512;
p.nffthalf = 257;
p.nFilterBk = 22;
p.Fs = Fs;
p.nFdim = 13;
p.Normalize = 1;
p.preemph = [1, .63];

outputpath = ['.\Learn\', FeatureKind, num2str(p.nFdim)];
if p.Normalize
    outputpath = [outputpath, 'N'];
end
mkdir(outputpath);

%% Feature Extraction
for i = 1:length(accnames)
    [x, Fs] = wavread(fullfile(audiopath, [accnames{i}, '.wav']));
    switch FeatureKind
        case 'Mfcc'
            [Fvecs, FBE, frames] = getmfcc(x, p);            
        case 'Lpc'
            x = filter(1, p.preemph, x);
            X = vec2frames(x, p.Nw, p.Ns, 'cols', @hamming, false);
            Fvecs = lpc(X, p.nFdim+1)';
            Fvecs = Fvecs(2:end, :);
        case 'RastaPlp'
            Fvecs = rastaplp(x, Fs, 1, p.nFdim);    % Also uses hamming window        
    end
    
    % NaN removal
    nancolumn = isnan(sum(Fvecs));
    Fvecs(:, nancolumn) = [];
            
    if p.Normalize
        Fvecs = normalize(Fvecs); % Zero mean, Unit Variance
    end
    
    savename = fullfile(outputpath, [accnames{i}, '.mat']);
    save(savename, 'Fvecs', 'p')
end