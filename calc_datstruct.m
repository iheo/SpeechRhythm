function stDat = calc_datstruct(vec, FeatureParam, WinParam, opts)

stDat.vec = vec;
stDat.len = length(vec);
OnsetType = WinParam.ShortWinAt;

% if the sound wave contains 0 ---> needs to change to small number
% otherwise, the feature extraction stage will calculate NaN
idx0 = find(vec==0);
vec(idx0) = 0.01*randn(size(idx0));

if WinParam.Nwins > 1  % U/V detect, assign variable length windows
    stDat.SpectrogramKind = 'Variable';

    % Feature Extraction
    if FeatureParam.normalize         
        FEAT = xtrfeature(vec, FeatureParam, 'normalize');    % will be normalized automatically (zero mean and unit variance)
    else
        FEAT = xtrfeature(vec, FeatureParam);
    end

    if strcmpi(OnsetType, 'Unvoice') | strcmpi(OnsetType, 'Ndsilence_unvoice');
        % load SVM parameter for Voiced / Unvoiced classification
        load svmstruct;
        IsVoiced = svmclassify(SVMstruct_rbf, [FEAT.zc; FEAT.sf; FEAT.kurt; FEAT.mfcc]');   % 1 : voiced, 0 : unvoiced
        IsVoiced = medfilt1(IsVoiced, 11);  % post-filtering

        % Determine each frame whether it is unvoiced
        % if m th frame is purely unvoiced then Indicator.Voice --> 0
        % otherwise, Indicator.Voice --> 1 or 2 or 3 (overlapped)
        Indicator.Index = FEAT.frameidx;
        Indicator.Voice = zeros(1, Indicator.Index(end, end));

        for ii = 1:size(Indicator.Index, 2)
            Indicator.Voice(Indicator.Index(:, ii)) = Indicator.Voice(Indicator.Index(:, ii)) + IsVoiced(ii);  % multiple zeros will indicate unvoiced section (continuous overlapped unvoice region)
        end        
        % Unvoiced Onset
        UnvoiceIndicator = (Indicator.Voice == 0);
        UnvoiceOnOffset = -diff([0, UnvoiceIndicator]);    % Onset and offset
        UnvoiceOnsetIndicator = (UnvoiceOnOffset>0);    % Only Onset (offset was < 0)
        stDat.OnsetIndex =find( UnvoiceOnsetIndicator > 0);   % Indexes for onsets

        if strcmpi(OnsetType, 'Ndsilence_unvoice')
            IsSilence = SilenceDetector(vec, opts.Fs);
            OnsetIndex = find(diff(IsSilence)==-1);
            stDat.OnsetIndex = sort([stDat.OnsetIndex, OnsetIndex']);
        end

    elseif strcmpi(OnsetType, 'EndSilence');    % Onset is the end of silence ( == beginning of any energy based event)
        IsSilence = SilenceDetector(vec, opts.Fs);
        stDat.OnsetIndex = find(diff(IsSilence)==-1);
    elseif strcmpi(OnsetType, 'LargeEnergy');
%         IsSilence = SilenceDetector(vec, 0.8, 'descend');
        IsSilence = SilenceDetector(vec, opts.Fs);
        stDat.OnsetIndex = find(diff(IsSilence)==1);    
    end

    % Vector to Variable Length Frames
    stDat.frameStructure = vec2varframes(vec, stDat.OnsetIndex, WinParam.WIN);
            % VLF(i).frame --> windowed frame
            % VLF(i).p1 --> the index(pointer) beginning
            % VLF(i).p2 --> the index ending
            % VLF(i).win  --> the asymmetric window that was applied
            % ex) plot(VLF.p1:VLF.p2, VLF.win) --> plotting the applied window

else % if Fixed Length Window
    stDat.SpectrogramKind = 'Fixed';

    [frames idxs] = vec2frames(vec, FeatureParam.Nw, FeatureParam.Ns, 'cols', FeatureParam.winKind);        
    [dim.D, dim.Nframe] = size(frames);

    % convert matrix to struct array
    for ii = 1:dim.Nframe
        st_tmp(ii).frame = frames(:, ii);
        st_tmp(ii).p1 = idxs(1, ii);
        st_tmp(ii).p2 = idxs(dim.D, ii);
        st_tmp(ii).win = window(FeatureParam.winKind, dim.D);
    end
    stDat.frameStructure = st_tmp;
end % end if
stDat.featgram = calc_featgram(stDat.frameStructure, FeatureParam);
