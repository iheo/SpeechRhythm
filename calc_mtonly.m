% calc_mtonly
% calculate the mappint table only!
clear all;

datroot = 'E:\Corpus\GMU\audiodata';
% Align a file to a reference file
load(fullfile(datroot, 'fileid.mat'));

wherefrom = 'french'; refidx = 1;
mypath.output = fullfile('E:\Corpus\GMU\MappingTable\MTonly', wherefrom);
mkdir(mypath.output);

fnames = fname.(wherefrom);

Nwins = 3;
NwMinHalf = 90; % 150

%% Parameter Setting
opts.doTimeStretching = false;
opts.Fs = 16000;
opts.dir.audiodata = fullfile(datroot, wherefrom);
opts.NwFix = round(.3*opts.Fs);
opts.NsFix = round(.002*opts.Fs);
opts.doSilenceRemoval = 0;
opts.ReleaseTimeStretchingRatio = 0;

FeatureParam.Nw = opts.Fs*.03; % Window length
FeatureParam.Ns = opts.Fs*.01; % Hop length
FeatureParam.nfft = 512;
FeatureParam.nffthalf = FeatureParam.nfft/2 + 1;
FeatureParam.nFilterBk = 40;   % Number of Filter Bank.
FeatureParam.Fs = opts.Fs;   % Sampling Frequency
FeatureParam.nFdim = 13;   % Feature Dimension
FeatureParam.winKind = @hanning;
FeatureParam.featKind = 'mag_winkind';  % either 'mag', 'mfcc'

WinParam.NwMinHalf = NwMinHalf;
WinParam.NwMin = WinParam.NwMinHalf*2;    % The minimum length of asymmetric window
WinParam.ShortWinAt = 'EndSilence'; % {'EndSilence', 'Unvoice'};
WinParam.Nwins = Nwins;

%% Loop begins
% for fidx.ref = 1:length(fnames)
for refidx = 1
% for refidx = 244;
    
    [dum, refname dum] = fileparts(fnames{refidx});    
    mypath.work = fullfile(mypath.output, refname);
    if ~isdir(mypath.work)
        mkdir(mypath.work);
    end
    
    for testidx = 1:length(fnames)
        
        if refidx == testidx
            continue;
        end
        [dum, testname dum] = fileparts(fnames{testidx});
        
        indicfiles = [testname(1:2), testname(end-2:end)];
        
        opts.savename = sprintf('N%dW%dR%dS%d%s%s%s',...
            WinParam.Nwins, WinParam.NwMin, opts.ReleaseTimeStretchingRatio,...
            opts.doSilenceRemoval, WinParam.ShortWinAt(1), ...
            indicfiles, FeatureParam.featKind(end));    % indicfiles : file indicator
        
        dat(1).description = 'Reference Signal';                
        dat(1).file.folder = opts.dir.audiodata;
        dat(1).file.name = refname;        
        
        dat(2).description = 'Test Signal';        
        dat(2).file.folder = opts.dir.audiodata;
        dat(2).file.name = testname;
        
        SyncOut = sync2(dat, FeatureParam, WinParam, opts);
        save(fullfile(mypath.work, opts.savename));       
       
    end
end

