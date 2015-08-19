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
FeatRoot = 'Mfcc13N';    
% FeatRoot = 'Lpc13N';    
FeatRoot = 'RastaPlp13N';    
Nmix = 4;
SaveName = sprintf('GmmClass%d_%s.mat', Nmix, FeatRoot)

%% Construct GMM model
GmmClass(1).name = 'Male';
GmmClass(1).IsTrain = IsTrain.IsMale;
GmmClass(1).IsTest = IsTest.IsMale;

GmmClass(2).name = 'Female';
GmmClass(2).IsTrain = IsTrain.IsFemale;
GmmClass(2).IsTest = IsTest.IsFemale;

GmmClass(3).name = 'Native';
GmmClass(3).IsTrain = IsTrain.IsNative;
GmmClass(3).IsTest = IsTest.IsNative;

GmmClass(4).name = 'NonNative';
GmmClass(4).IsTrain = IsTrain.IsNonNative;
GmmClass(4).IsTest = IsTest.IsNonNative;

for i = 1:length(GmmClass)    
    IDX = find(GmmClass(i).IsTrain);
    N = length(IDX);
    j = 1;
    fprintf('Feature Reading for Class %s ...\n', GmmClass(i).name);
    for j = 1:N        
        load(fullfile(FeatRoot, [accnames{IDX(j)}, '.mat']));
        CC{j} = Fvecs;
    end
    fprintf('has been finished\n');
    FeatVecs = cell2mat(CC);
%     tmp = mean(FeatVecs);
%     FeatVecs(:, isnan(tmp)) = [];
    
    % Expectation Maximization for GMM
    [Label, Gmm, llh] = emgm(FeatVecs, Nmix);
    GmmClass(i).Gmm = Gmm;
end
save(SaveName, 'GmmClass', 'p')