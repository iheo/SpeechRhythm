clear all;
% Create the mapping table first by running 

load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz

% load SvdClassTmN
%       SvdClass(ClassDef, FromGroup, RefGroup)
%                                               .U (SVD vectors)
%       Class(ClassDef, Group)

% A1) M -> M;  1 -> 1
% A2) F -> M;  2 -> 1
% B1) M -> F;  1 -> 2
% B2) F -> F;  2 -> 1
% more details about class definitions are found in classify_svd.m
%% Model construction
%% Construct SVM model
Model(1).name = 'Male';
Model(1).IsTrain = IsTrain.IsMale;
Model(1).IsTest = IsTest.IsMale;

Model(2).name = 'Female';
Model(2).IsTrain = IsTrain.IsFemale;
Model(2).IsTest = IsTest.IsFemale;

Model(3).name = 'Native';
Model(3).IsTrain = IsTrain.IsNative;
Model(3).IsTest = IsTest.IsNative;

Model(4).name = 'NonNative';
Model(4).IsTrain = IsTrain.IsNonNative;
Model(4).IsTest = IsTest.IsNonNative;

%% SVM Parameters
opts.options = statset('Display', 'iter', 'MaxIter', 50000);
% opts.options = statset('Display', 'iter');
opts.KernelKind = 'rbf';
opts.kktviolationlevel = 0.2;
opts.rbfSigma = .1;
opts.kktviolationlevel = .2;
opts.tolkkt = .2;
%% SVM training
Cidx{1} = [1, 2];
Cidx{2} = [3, 4];

FeatRoot = 'Mfcc13N';
FeatRoot = 'RastaPlp13N';

for iClassDef = 1:length(Cidx)
    FeatVecs = [];
    for kk = 1:length(Cidx{iClassDef})
        i = Cidx{iClassDef}(kk);
        IDX = find(Model(i).IsTrain);
        N = length(IDX);
        j = 1;
        fprintf('Feature Reading for Class %s ...\n', Model(i).name);
        clear CC
        for j = 1:N        
            load(fullfile(FeatRoot, [accnames{IDX(j)}, '.mat']));
            CC{j} = Fvecs;
        end
        fprintf('has been finished\n');
        FeatVecs{kk} = cell2mat(CC);        
    end
    
    TrainData = [FeatVecs{1}, FeatVecs{2}]';
    TrainLabel = ones(size(TrainData(:, 1)));
    TrainLabel(length(FeatVecs{1})+1:end) = 2;
    ridx = randsample(length(TrainLabel), 30000);
    TrainData = TrainData(ridx, :);
    TrainLabel = TrainLabel(ridx);
    
    SvmStruct(iClassDef).Train = svmtrain(TrainData, TrainLabel,...
        'kernel_function', opts.KernelKind, 'rbf_sigma', opts.rbfSigma,...
        'options', opts.options, 'kktviolationlevel', opts.kktviolationlevel,...
        'tolkkt', opts.tolkkt);
    RandIdx{iClassDef} = ridx;
end
%% SVM test

for iClassDef =1:length(Cidx)
    FeatVecs = [];
    for kk = 1:length(Cidx{iClassDef})
        i = Cidx{iClassDef}(kk);
        IDX = find(Model(i).IsTest);
        N = length(IDX);
        j = 1;
        fprintf('Feature Reading for Class %s ...\n', Model(i).name);
        clear CC
        for j = 1:N
            load(fullfile(FeatRoot, [accnames{IDX(j)}, '.mat']));
            CC{j} = Fvecs;
        end
        fprintf('has been finished\n');
        FeatVecs{kk} = cell2mat(CC);
    end
    
    TsData = [FeatVecs{1}, FeatVecs{2}]';
    TsLabel = ones(size(TsData(:, 1)));
    TsLabel(length(FeatVecs{1})+1:end) = 2;
    ridx = randsample(length(TsLabel), 10000);
    TsData = TsData(ridx, :);
    TsLabel = TsLabel(ridx);
    
    Group = svmclassify(SvmStruct(iClassDef).Train, TsData);
    i1 = find(TsLabel==1);
    i2 = find(TsLabel==2);
    pc1 = 1 - sum(abs(Group(i1) - TsLabel(i1)))/length(i1);
    pc2 = sum(abs(Group(i2) - TsLabel(i2)))/length(i2);
    PC = 1 - sum(abs(Group - TsLabel))/length(Group);
    [pc1, pc2, PC]
    SvmStruct(iClassDef).PC = PC;
end