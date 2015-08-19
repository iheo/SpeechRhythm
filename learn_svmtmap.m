clear all;
% Create the mapping table first by running 

load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz

load SvdClassTmN
%       SvdClass(ClassDef, FromGroup, RefGroup)
%                                               .U (SVD vectors)
%       Class(ClassDef, Group)

% A1) M -> M;  1 -> 1
% A2) F -> M;  2 -> 1
% B1) M -> F;  1 -> 2
% B2) F -> F;  2 -> 1
% more details about class definitions are found in classify_svd.m

%% SVM Parameters
% opts.options = statset('Display', 'iter', 'MaxIter', 30000);
opts.options = statset('Display', 'iter');
opts.KernelKind = 'rbf';
opts.rbfSigma = 100;

%% Create concatenated vector
% AV(iClassDef, FromGroup, RefGroup)
AV = accdata_read(Class, accnames,'Train');
BV = accdata_read(Class, accnames, 'Test');

%% Training
[NClassDef, NGroup] = size(Class);
for iClassDef = 1:NClassDef
    for RefGroup = 1 : NGroup            
        V1 = AV(iClassDef, 1, RefGroup).Vecs;
        V2 = AV(iClassDef, 2, RefGroup).Vecs;
        TrData = [V1, V2]';
        TrLab = [ones(1, size(V1, 2)), 2*ones(1, size(V2, 2))]';
        SvmStruct(iClassDef, RefGroup).Train = svmtrain(TrData, TrLab, 'kernel_function', opts.KernelKind, 'rbf_sigma', opts.rbfSigma, 'options', opts.options);                
    end
end

%% Testing
for iClassDef = 1:NClassDef
    for RefGroup = 1 : NGroup
        V1 = BV(iClassDef, 1, RefGroup).Vecs;
        V2 = BV(iClassDef, 2, RefGroup).Vecs;
        TsData = [V1, V2]';
        TsLab = [ones(1, size(V1, 2)), 2*ones(1, size(V2, 2))]';        
        Group = svmclassify(SvmStruct(iClassDef, RefGroup).Train, TsData);
        SvmStruct(iClassDef, RefGroup).PC = 1 - sum(abs(Group - TsLab))/length(Group);
        SvmStruct(iClassDef, RefGroup).PC
    end
end
plot([Group, TsLab])