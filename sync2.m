function SyncOut = sync2(dat, FeatureParam, WinParam, opts)
% The best way to run this code as a batch (one time use)
%
% clear all;
if ~exist('dat', 'var'); % Batch mode, one time use
    opts.Fs = 16000;    
    opts.savename = 'N3W180R0S0E_TEST1d2';

    opts.doSilenceRemoval = 0;
    opts.ReleaseTimeStretchingRatio = 0;
    opts.Nwins = 3;       
    opts.NwFix = round(.3*opts.Fs); % For time stretching
    opts.NsFix = round(.002*opts.Fs);   % For time stretching

    % Feature for unvoiced detection
    FeatureParam.Nw = opts.Fs*.03; % Window length
    FeatureParam.Ns = opts.Fs*.01; % Hop length
    FeatureParam.nfft = 512;
    FeatureParam.nffthalf = FeatureParam.nfft/2 + 1;
    FeatureParam.nFilterBk = 40;   % Number of Filter Bank.    
    FeatureParam.nFdim = 13;   % Feature Dimension
    
    % Feature for general processing
    FeatureParam.winKind = @hanning;
    FeatureParam.featKind = 'mag_winkind';  % either 'mag', 'mfcc', 'mag_winkind'

    WinParam.NwMinHalf = 90;                    
    WinParam.NwMin = WinParam.NwMinHalf*2;    % The minimum length of asymmetric window                    
%     WinParam.ShortWinAt = 'Ndsilence_unvoice';    % StrShortWins = {'EndSilence', 'LargeEnergy', 'Unvoice', 'endsilence_unvoice'};
    WinParam.ShortWinAt = 'EndSilence';    % StrShortWins = {'EndSilence', 'LargeEnergy', 'Unvoice', 'Ndsilence_unvoice'};
    WinParam.Nwins = opts.Nwins;
    
    root = 'C:\Users\iheo\Box Sync\GMUDATA\';
    dat(1).description = 'Reference Signal';
    dat(1).file.folder = [root, 'audiofiles\english\'];
    dat(1).file.name = 'english_ usa_ female_ davenport_10';
    dat(1).file.fullpath = sprintf('%s%s.wav', dat(1).file.folder, dat(1).file.name);

    % 'C:\Users\iheo\Box Sync\GMUDATA\audiofiles\korean\'
    dat(2).description = 'Test Signal (To be aligned)';
    dat(2).file.folder = [root, 'audiofiles\english\'];
    dat(2).file.name = 'english_ usa_ male_ louisville_19';
%     dat(2).file.name = 'english_ usa_ male_ hazlehurst_451';
    % dat(2).file.name = 'english_ usa_ male_ oceanside_168';
    dat(2).file.fullpath = sprintf('%s%s.wav', dat(2).file.folder, dat(2).file.name);
    
end

%% Construct Data Structure
WinParam.WIN = calc_wins(FeatureParam.winKind, WinParam.NwMin, WinParam.Nwins);     % Window Assignment
for k = 1:length(dat)
    dat(k).file.fullpath = fullfile(dat(k).file.folder, [dat(k).file.name, '.wav']);
    [vec FsRead] = audioread(dat(k).file.fullpath);
    vec = resample(vec, opts.Fs, FsRead);
    
    try
        stDat(k) = calc_datstruct(vec, FeatureParam, WinParam, opts);    % 'Unvoice', 'EndSilence'            
    catch exception
        rethrow(exception)
    end
    %    stDat(k).vec
    %               .len
    %               .SpectrogramKind      {'Variable' or 'Fixed'}
    %               .OnsetIndex
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
try
    [mappingTable SampIdx, IdxMappingTable, Cost] = dat2warp(stDat(1), stDat(2));
catch exception
    rethrow(exception)
end

%% Silence Alignment
if opts.doSilenceRemoval
    % Silence Detection
    try
        stDat(1).isSilence = SilenceDetector(stDat(1));
        stDat(2).isSilence = SilenceDetector(stDat(2));
    catch exception
        rethrow(exception)
    end
    
    % Onset Detection
    stDat(1).onset = find(diff(stDat(1).isSilence) == -1);  
    stDat(2).onset = find(diff(stDat(2).isSilence) == -1);  
    
    % Check if well
%     figure(1);  plot(stDat(1).vec); vline(stDat(1).onset);
%     figure(2);  plot(stDat(2).vec); vline(stDat(2).onset);

    % Time stretching only for silence
    [X.out IndexLog] = tsheosilence(stDat(1), stDat(2), mappingTable, opts.NwFix, opts.NsFix);

    % redo featgram
    try
        stDatTest = calc_datstruct(X.out, FeatureParam, WinParam);    
    catch exception
        rethrow(exception)
    end

    % redo timewarp
    try
        [mappingTable SampIdx, IdxmappingTable, Cost] = dat2warp(stDat(1), stDatTest);
    catch exception
        rethrow(exception)        
    end
else
    stDatTest = stDat(2);
end

%% Release Time Stretching Ratio
if opts.ReleaseTimeStretchingRatio
    try
        mappingTable = tsrelease(mappingTable);
    catch exception
        rethrow(exception)        
    end
end

%% Index Reversal Problem Solved & Time Stretching
% 1. Limit the number of overlapped windows are 2 at maximum
% 2. There is only one time stretching ratio at given sample
%     -- the overlapped region of the test must match to the overlapped region in reference

wav.ref = [stDat(1).vec];
wav.in = [stDatTest.vec; zeros(.5*opts.Fs, 1)];
wav.Fs = opts.Fs;
IndexLog = [];
if opts.doTimeStretching
    if opts.isTesting
        [wav.out IndexLog] = tsheo_20140914(wav.ref(1:end), wav.in(1:end), mappingTable, opts.NwFix, opts.NsFix);    
    else
        try
            [wav.out IndexLog] = tsheo_20140914(wav.ref, wav.in, mappingTable, opts.NwFix, opts.NsFix);
        catch exception
            rethrow(exception)    
        end
    end
else
    fprintf('No time stretching done\n');
%     clear wav stDat stDatTest
%     save([opts.savename, 'X']);
%     return
end
% Xout1 = tsheo1(Ref, Xin, mappingTable, 5000, 30);
% Xout2 = tsheo2(Ref, Xin, mappingTable);
% Xout3 = tsheo3(Ref, Xin, mappingTable);

%% Save parameters
Params.FeatureParam = FeatureParam;
Params.WinParam = WinParam;
Params.opts = opts;
Log.TimeStretching = IndexLog;
Log.MappingTable = mappingTable;
Log.IdxMappingTable = IdxMappingTable;
wav.in = dat(2).file.name;  % Reduce data file size
wav.ref = dat(1).file.name;

SyncOut.Params = Params;
SyncOut.wav = wav;
SyncOut.Log = Log;
SyncOut.dat = dat;
SyncOut.opts = opts;
SyncOut.Cost = Cost;