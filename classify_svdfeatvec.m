clear all;

load FileWav16kHz

%% SVD Creation Begins ---
FeatureKind = {'Mfcc13N', 'Lpc13N', 'RastaPlp13N'};


%% GMM Classification Begins ---
FeatureKind = {'Mfcc13N', 'Lpc13N', 'RastaPlp13N', 'Tvec'};
FeatureKind = {'RastaPlp13N'};
CIdx{1} = [1, 2];
Model(1).idx = find(IsTest.IsMale);   % Pr( x | Male )
Model(2).idx = find(IsTest.IsFemale); % Pr( x | Female)

% Nativeness Parameter
CIdx{2} = [3, 4];
Model(3).idx = find(IsTest.IsNative);   % Pr( x | Native )
Model(4).idx = find(IsTest.IsNonNative); % Pr( x | NonNative )

for k = 1:length(FeatureKind)
    
    GmmLoadName = sprintf('Learn/GmmClass%d_%s.mat', Nmix(j), FeatureKind{k})
%                   .Gmm : gaussian mixture parameter
%                   .p : feature vector parameters
    load(GmmLoadName);
    % Gender Parameter
    
    for ii = 1:2
        IDX = CIdx{ii};
        % IDX = CIdx{1};  % Gender
    %     IDX = CIdx{2};  % Native
        for c = 1:2
            Fidx = Gmm(IDX(c)).idx;
            Nfiles = length(Fidx);       
            PrXIC = zeros(Nfiles, 2);     % Pr(X | Class=1)  % Pr(X | Class=2)

            hw = waitbar(0, sprintf('For class %d', c));
            for i = 1:Nfiles        
                % Load Feature Extraction
                load(fullfile(FeatureKind{k}, [accnames{Fidx(i)}, '.mat']));
%                     [x, Fs] = wavread(fullfile(audiopath, [accnames{Fidx(i)}, '.wav']));
%                     [CC, FBE, frames] = getmfcc(x, p);
%                     CC = normalize(CC);
                    P1 = 0; P2 = 0;
                for jj = 1:size(Fvecs, 2)
                    X = Fvecs(1:end, jj);

                    if sum(isnan(X)) > 0
                        continue;
                    end
                    % Compute the conditional probability for each observation vector
                    pp1 = gmmpdf(X, GmmClass(IDX(1)).Gmm) + eps;
                    pp2 = gmmpdf(X, GmmClass(IDX(2)).Gmm) + eps;
                    P1 = P1 + log(pp1);
                    P2 = P2 + log(pp2);                        
                end
                PrXIC(i, 1) = P1;
                PrXIC(i, 2) = P2;
                waitbar(i/Nfiles, hw);
            end
            close(hw);
            Acc(j, k, ii).Class(IDX(c)).PrXIC = PrXIC;
            PC = sum(PrXIC(:, 1) > PrXIC(:, 2))/Nfiles;
            Acc(j, k, ii).Class(IDX(c)).PC = PC;
            fprintf('[Nmix %d, G(1) N(2) %d, Class(%d)] Percent correct : %.2f\n', Nmix(j), ii, IDX(c), PC);
        end
        Acc(j, k, ii).Class(IDX(c)).PC = 1 - Acc(j, k, ii).Class(IDX(c)).PC;
%             Acc(j, k, ii).Gmm = Acc(j, k, ii).Class;
    end    
end