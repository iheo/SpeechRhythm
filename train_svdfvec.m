clear all;

% warning off
warning('off', 'MATLAB:audiovideo:wavread:functionToBeRemoved');

load FileWav16kHz
    %   created by gen_fileid.m
    %   accnames : wav files
    %   audiopath : wav files location
    %       .IsTrain.IsFemale
    %               .IsMale
    %               .IsNativeEnglish
    %               .IsAsian
    %               .IsLearnLessAYear
    %
    %       .IsTest.-------    
    %       ... To be continued
%% Feature to train
FeatRoots = {'Mfcc13N', 'Lpc13N', 'RastaPlp13N'};    

NSvdPickEach = 13;
NSvdPickTotal = 60;

%% Construct GMM model
SvdClass(1).name = 'Male';
SvdClass(1).IsTrain = IsTrain.IsMale;
SvdClass(1).IsTest = IsTest.IsMale;

SvdClass(2).name = 'Female';
SvdClass(2).IsTrain = IsTrain.IsFemale;
SvdClass(2).IsTest = IsTest.IsFemale;

SvdClass(3).name = 'Native';
SvdClass(3).IsTrain = IsTrain.IsNative;
SvdClass(3).IsTest = IsTest.IsNative;

SvdClass(4).name = 'NonNative';
SvdClass(4).IsTrain = IsTrain.IsNonNative;
SvdClass(4).IsTest = IsTest.IsNonNative;
for k = 1:length(FeatRoots)
    FeatRoot = FeatRoots{k};
    SaveName = sprintf('SvdClassE%dT%d_%s.mat', NSvdPickEach, NSvdPickTotal, FeatRoot);
    for i = 1:length(SvdClass)    
        IDX = find(SvdClass(i).IsTrain);
        N = length(IDX);
        j = 1;
        fprintf('Feature Reading for Class %s ...\n', SvdClass(i).name);
        for j = 1:N
            load(fullfile(FeatRoot, [accnames{IDX(j)}, '.mat']));
    %         CC{j} = Fvecs;

            % Do SVD for each file
            [u, s, v] = svd(Fvecs);
            CC{j} = u;
        end
        fprintf('has been finished\n');
        FeatVecs = cell2mat(CC);
    %     tmp = mean(FeatVecs);
    %     FeatVecs(:, isnan(tmp)) = [];

        % Expectation Maximization for GMM
%         [Label, Gmm, llh] = emgm(FeatVecs, Nmix);
%         SvdClass(i).Gmm = Gmm;
    end
    save(SaveName, 'SvdClass', 'FeatVecs', 'p')
end