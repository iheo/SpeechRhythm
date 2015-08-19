clear all;
% Create the mapping table first by running 
cd D:\Corpus\GMU\audiodata
load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz

doNormalize = 1;    % Already normalized
root = 'wav16kHzMlfDur';

files = dir(fullfile(root, '*.mat'));

%% Class definition
% Gender
Class(1, 1).name = 'Male';
Class(1, 1).IsTrain = IsTrain.IsMale;
Class(1, 1).IsTest = IsTest.IsMale;
Class(1, 2).name = 'Female';
Class(1, 2).IsTrain = IsTrain.IsFemale;
Class(1, 2).IsTest = IsTest.IsFemale;
 
% Native
Class(2, 1).name = 'Native';
Class(2, 1).IsTrain = IsTrain.IsNative;
Class(2, 1).IsTest = IsTest.IsNative;
Class(2, 2).name = 'NonNative';
Class(2, 2).IsTrain = IsTrain.IsNonNative;
Class(2, 2).IsTest = IsTest.IsNonNative;

%% Read feature vectors and SVD training
Nsvd = 60;
for i = 1:2
    for j = 1:2        
        clear PhVecs WdVecs PhVecsNosp WdVecsNosp
        idx = find(Class(i, j).IsTrain);
        for k = 1:length(idx)
            V = load(fullfile(root, files(idx(k)).name));
            PhVecs(:, k) = V.Phn.dur;
            WdVecs(:, k) = V.Wrd.dur;            
            
            PhVecsNosp(:, k) = V.PhnNosp.dur;
            WdVecsNosp(:, k) = V.WrdNosp.dur;
            
            % Normalize?
            PhVecs(:, k) = PhVecs(:, k)/sum(PhVecs(:, k));
            WdVecs(:, k) = WdVecs(:, k)/sum(WdVecs(:, k));            
            
            PhVecsNosp(:, k) = PhVecsNosp(:, k)/sum(PhVecsNosp(:, k));
            WdVecsNosp(:, k) = WdVecsNosp(:, k)/sum(WdVecsNosp(:, k));            
        end
        CellPhn{i, j} = PhVecs;
        CellWrd{i, j} = WdVecs;
        CellPhnNosp{i, j} = PhVecsNosp;
        CellWrdNosp{i, j} = WdVecsNosp;
        
        % SVD train
        [UP, SP, VP] = svd(CellPhn{i, j});
        [UW, SW, VW] = svd(CellWrd{i, j});
        [UPN, SP, VP] = svd(CellPhnNosp{i, j});
        [UWN, SW, VW] = svd(CellWrdNosp{i, j});
        
        SvdClass(i, j).UP = UP(:, 1:Nsvd);
        SvdClass(i, j).UW = UW(:, 1:Nsvd);
        SvdClass(i, j).UPN = UPN(:, 1:Nsvd);
        SvdClass(i, j).UWN = UWN(:, 1:Nsvd);
        
    end
end
%% Performance Evaluation SVD - Phone Representation
NsvdTest = 60;
for i = 1 : 2
    for j = 1 : 2
        Fidx = find(Class(i, j).IsTest);
        
        U1 = SvdClass(i, 1).UP(:, 1:NsvdTest);
        U1_ = inv(U1'*U1)*U1';
        
        U2 = SvdClass(i, 2).UP(:, 1:NsvdTest);
        U2_ = inv(U2'*U2)*U2';
        
        clear Err1 Err2
        for k = 1 : length(Fidx)
            Z = load(fullfile(root, files(Fidx(k)).name));
            
            Coef1 = U1_*Z.Phn.dur;
            VecHat1 = U1*Coef1;
            Err1(k).n2 = norm(VecHat1 - Z.Phn.dur);
            
            Coef2 = U2_*Z.Phn.dur;
            VecHat2 = U2*Coef2;
            Err2(k).n2 = norm(VecHat2 - Z.Phn.dur);
        end
        PC(i, j) = mean([Err1.n2] < [Err2.n2]);        
    end
    PC(i, j) = 1 - PC(i, j);
end
PC

%% Performance Evaluation SVD - Phone Representation - No space
NsvdTest = 60;
for i = 1 : 2
    for j = 1 : 2
        Fidx = find(Class(i, j).IsTest);
        
        U1 = SvdClass(i, 1).UPN(:, 1:NsvdTest);
        U1_ = inv(U1'*U1)*U1';
        
        U2 = SvdClass(i, 2).UPN(:, 1:NsvdTest);
        U2_ = inv(U2'*U2)*U2';
        
        clear Err1 Err2
        for k = 1 : length(Fidx)
            Z = load(fullfile(root, files(Fidx(k)).name));
            
            Coef1 = U1_*Z.PhnNosp.dur;
            VecHat1 = U1*Coef1;
            Err1(k).n2 = norm(VecHat1 - Z.PhnNosp.dur);
            
            Coef2 = U2_*Z.PhnNosp.dur;
            VecHat2 = U2*Coef2;
            Err2(k).n2 = norm(VecHat2 - Z.PhnNosp.dur);
        end
        PC(i, j) = mean([Err1.n2] < [Err2.n2]);        
    end
    PC(i, j) = 1 - PC(i, j);
end
PC

%% Performance Evaluation SVD - Word Representation
for i = 1 : 2
    for j = 1 : 2
        Fidx = find(Class(i, j).IsTest);
        
        U1 = SvdClass(i, 1).UW(:, 1:NsvdTest);
        U1_ = inv(U1'*U1)*U1';
        
        U2 = SvdClass(i, 2).UW(:, 1:NsvdTest);
        U2_ = inv(U2'*U2)*U2';
        
        clear Err1 Err2
        for k = 1 : length(Fidx)
            Z = load(fullfile(root, files(Fidx(k)).name));
            
            Coef1 = U1_*Z.Wrd.dur;
            VecHat1 = U1*Coef1;
            Err1(k).n2 = norm(VecHat1 - Z.Wrd.dur);
            
            Coef2 = U2_*Z.Wrd.dur;
            VecHat2 = U2*Coef2;
            Err2(k).n2 = norm(VecHat2 - Z.Wrd.dur);
        end
        PCW(i, j) = mean([Err1.n2] < [Err2.n2]);        
    end
    PCW(i, j) = 1 - PCW(i, j);
end
PCW

%% Performance Evaluation SVD - Word Representation - No space
for i = 1 : 2
    for j = 1 : 2
        Fidx = find(Class(i, j).IsTest);
        
        U1 = SvdClass(i, 1).UWN(:, 1:NsvdTest);
        U1_ = inv(U1'*U1)*U1';
        
        U2 = SvdClass(i, 2).UWN(:, 1:NsvdTest);
        U2_ = inv(U2'*U2)*U2';
        
        clear Err1 Err2
        for k = 1 : length(Fidx)
            Z = load(fullfile(root, files(Fidx(k)).name));
            
            Coef1 = U1_*Z.WrdNosp.dur;
            VecHat1 = U1*Coef1;
            Err1(k).n2 = norm(VecHat1 - Z.WrdNosp.dur);
            
            Coef2 = U2_*Z.WrdNosp.dur;
            VecHat2 = U2*Coef2;
            Err2(k).n2 = norm(VecHat2 - Z.WrdNosp.dur);
        end
        PCW(i, j) = mean([Err1.n2] < [Err2.n2]);        
    end
    PCW(i, j) = 1 - PCW(i, j);
end
PCW