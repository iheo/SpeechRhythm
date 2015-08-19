clear all;

global WIN opts Fs

opts.doVariableWindow = 1;   % 1 for variable window, 0 for fixed window
opts.doSilenceRemoval = 0;
opts.ReleaseTimeStretchingRatio = 0;

root = 'D:\BoxSync\Box Sync\GMUDATA\';
root = 'C:\Users\iheo\Box Sync\GMUDATA\';

dat(1).description = 'Reference Signal';
dat(1).file.folder = [root, 'audiofiles\english\'];
dat(1).file.name = 'english_ usa_ female_ davenport_10';
dat(1).file.fullpath = sprintf('%s%s.wav', dat(1).file.folder, dat(1).file.name);

% 'C:\Users\iheo\Box Sync\GMUDATA\audiofiles\korean\'
dat(2).description = 'Test Signal (To be aligned)';
dat(2).file.folder = [root, 'audiofiles\english\'];
dat(2).file.name = 'english_ usa_ male_ louisville_19';
dat(2).file.name = 'english_ usa_ male_ hazlehurst_451';
% dat(2).file.name = 'english_ usa_ male_ oceanside_168';
dat(2).file.fullpath = sprintf('%s%s.wav', dat(2).file.folder, dat(2).file.name);

% 'korean_ south korea_ male_ inchon_38'
% 'english_ usa_ female_ coudersport_509';

Fs = 16000;  % will be resampled

%% Parameter for feature extraction for U/V classification
FeatureParam.Nw = Fs*.03; % Window length
FeatureParam.Ns = Fs*.01; % Hop length
FeatureParam.nfft = 512;
FeatureParam.nffthalf = FeatureParam.nfft/2 + 1;
FeatureParam.nFilterBk = 40;   % Number of Filter Bank.
FeatureParam.Fs = Fs;   % Sampling Frequency
FeatureParam.nFdim = 13;   % Feature Dimension
FeatureParam.winKind = @hanning;
FeatureParam.featKind = 'mag';  % either 'mag', 'mfcc'

%% Asymmetric window parameters
WinParam.NwMinHalf = 90;
WinParam.NwMin = WinParam.NwMinHalf*2;    % The minimum length of asymmetric window
WinParam.ShortWinAt = 'LargeEnergy';    % 'EndSilence', 'LargeEnergy', 'Unvoice'
if opts.doVariableWindow
    WinParam.Nwins = 3;  % the number of windows (if 4, 2 windows are used as transition windows)    
else
    WinParam.Nwins = 1;    
end
WIN = calc_asymwin(FeatureParam.winKind, WinParam.NwMin, WinParam.Nwins);    % Asymmetric window settings

%% Construct Data Structure
for k = 1:length(dat)
    dat(k).file.fullpath = sprintf('%s%s.wav', dat(k).file.folder, dat(k).file.name);
    [vec FsRead] = audioread(dat(k).file.fullpath);
    vec = resample(vec, Fs, FsRead);
    stDat(k) = constructdat(vec, FeatureParam, WinParam);    % 'Unvoice', 'EndSilence'        
    %    stDat(k).vec
    %               .len
    %               .SpectrogramKind      {'Variable' or 'Fixed'}
    %               .WinKind                  {Asymmetric AW  or Symmetric FW}
    %               .frameStructure
    %                                         .awin      window shape (asymmetric or symmetric)
    %                                         .p1, p2    pointer from the start(p1) to the end(p2)
    %                                         .frame     windowed frame
    %               .featgram              feature vectors
end

%% Check the overlapping (asymmetric) windows are pretty
% Plotting the overlapped windows
% Checking the overlapping windows sums to constant, well established
% Set isShowPlot to 1 in vec2varframes.m
% plot_allwindows(stDat(1));

%% Time warping for Variable Length Spectrogram
[mappingTable SampIdx] = dat2tw(stDat(1), stDat(2));

%% Silence Alignment
if opts.doSilenceRemoval
    % Silence Detection
    stDat(1).isSilence = SilenceDetector(stDat(1));
    stDat(2).isSilence = SilenceDetector(stDat(2));
    
    % Onset Detection
    stDat(1).onset = find(diff(stDat(1).isSilence) == -1);  
    stDat(2).onset = find(diff(stDat(2).isSilence) == -1);  
    
    % Onset based window asign
    
    
    % Check if well
%     figure(1);  plot(stDat(1).vec); vline(stDat(1).onset);
%     figure(2);  plot(stDat(2).vec); vline(stDat(2).onset);

    % Time stretching only for silence
%     [X.out IndexLog] = tsheosilence(stDat(1), stDat(2), mappingTable);

    % redo featgram
    stDatTest = constructdat(X.out, FeatureParam, WinParam);    

    % redo timewarp
    [mappingTable SampIdx] = dat2tw(stDat(1), stDatTest);
else
    stDatTest = stDat(2);
end

%% Release Time Stretching Ratio
if opts.ReleaseTimeStretchingRatio
    mappingTable = tsrelease(mappingTable);
end

%% Index Reversal Problem Solved & Time Stretching
% 1. Limit the number of overlapped windows are 2 at maximum
% 2. There is only one time stretching ratio at given sample
%     -- the overlapped region of the test must match to the overlapped region in reference

wav.ref = [stDat(1).vec];
wav.in = [stDatTest.vec; zeros(.5*Fs, 1)];
wav.Fs = Fs;

[wav.out IndexLog] = tsheo_20140914(wav.ref, wav.in, mappingTable, 5000, 30);
% Xout1 = tsheo1(Ref, Xin, mappingTable, 5000, 30);
% Xout2 = tsheo2(Ref, Xin, mappingTable);
% Xout3 = tsheo3(Ref, Xin, mappingTable);

%% Save parameters
Params.FeatureParam = FeatureParam;
Params.WinParam = WinParam;
Params.WinParam.WIN = WIN;
Params.opts = opts;
Log.TimeStretching = IndexLog;
Log.MappingTable = mappingTable;

[dum1 name1 dum2]= fileparts(dat(1).file.name);    [dum1 name2 dum2]= fileparts(dat(2).file.name);
indicfiles = [name1(1:2), name1(end-2:end), name2(1:2), name2(end-2:end)];
savename = sprintf('./output/N%dW%dR%dS%d%s%s.mat',...
    WinParam.Nwins, WIN(1).Nw, opts.ReleaseTimeStretchingRatio,...
    opts.doSilenceRemoval, WinParam.ShortWinAt(1), ...
    indicfiles);    % indicfiles : file indicator
save(savename, 'Params', 'wav', 'Log', 'dat', 'opts');