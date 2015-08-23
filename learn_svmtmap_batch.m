clear all;
% Create the mapping table first by running 

load FileWav16kHz
trainfilelist;
    %   see create_gmm for what to be loaded by FileWav16kHz

% iTask = 0; Task = 'Native';    IdxSet = 1:5;   % My Computer(0) test
% iTask = 1;  Task = 'Native';    IdxSet = 6:130; % My computer (1)
% iTask = 2;  Task = 'Native';    IdxSet = 131:230;   % My computer (2)
% iTask = 3;  Task = 'Native';    IdxSet = 231:330;   % My computer (3)
iTask = 4;  Task = 'Native';    IdxSet = 331:430;   % My computer (4)
% iTask = 5;  Task = 'Gender';    IdxSet = 1:90;     % Chris (2)
% iTask = 6;  Task = 'Gender';    IdxSet = 91:180;   % Chris (3)
% iTask = 7;  Task = 'Gender';    IdxSet = 181:235;   % NUC (11)
% iTask = 8;  Task = 'Gender';    IdxSet = 236:290;   % NUC (12)
% iTask = 9;  Task = 'Gender';    IdxSet = 291:345;   % NUC (21)
% iTask = 10;  Task = 'Gender';    IdxSet = 346:400;   % NUC (22)
% iTask = 11;  Task = 'Gender';    IdxSet = 401:500;  % Main (1)
% iTask = 12;  Task = 'Gender';    IdxSet = 501:600;  % Main (2)
% iTask = 13;  Task = 'Gender';    IdxSet = 601:660;  % AC (1)
% iTask = 14;  Task = 'Gender';    IdxSet = 661:722;  % AC (2)

%% Common Parameters
maproot = '.\MappingTable\GT100\N3W180R0S0EdN1';
mkdir('SvmClass');
if strcmp(Task, 'Native')    
    filepairs = FilePairs.Native; Flag{1} = 'IsNative';  Flag{2} = 'IsNonNative';
elseif strcmp(Task, 'Gender')    
    filepairs = FilePairs.Gender; Flag{1} = 'IsMale';   Flag{2} = 'IsFemale';
end

%% SVM Parameters
% opts.options = statset('Display', 'iter', 'MaxIter', 30000);
opts.options = statset('Display', 'iter');
opts.KernelKind = 'rbf';
opts.rbfSigma = 100;

for k = IdxSet
    tic;
    savename = sprintf('%s%d', Task, k);
    
    %% Class definition
    for j = 1 : 2
        Class(j).path = fullfile(maproot, filepairs{k, j});
        Class(j).IsTrain = remove_samepath(IsTrain.(Flag{j}), Class(j).path, accnames);
        Class(j).IsTest = remove_samepath(IsTest.(Flag{j}), Class(j).path, accnames);
    end
    
    %% Create concatenated vector    
    AVTrain = accdata_read_batch(Class, accnames,'Train');
    AVTest = accdata_read_batch(Class, accnames, 'Test');

    %% Training
    for RefGroup = 1 : 2
        
        V1 = AVTrain(1, RefGroup).Vecs;
        V2 = AVTrain(2, RefGroup).Vecs;
        
        TrData = [V1, V2]';
        TrLab = [ones(1, size(V1, 2)), 2*ones(1, size(V2, 2))]';
        
        SvmStruct(RefGroup).Train = svmtrain(TrData, TrLab, 'kernel_function', opts.KernelKind, 'rbf_sigma', opts.rbfSigma, 'options', opts.options);
    end
    

    %% Testing    
    for RefGroup = 1 : 2
        
        V1 = AVTest(1, RefGroup).Vecs;
        V2 = AVTest(2, RefGroup).Vecs;
        
        TsData = [V1, V2]';
        TsLab = [ones(1, size(V1, 2)), 2*ones(1, size(V2, 2))]';
        Group = svmclassify(SvmStruct(RefGroup).Train, TsData);
        PC(RefGroup) = 1 - sum(abs(Group - TsLab))/length(Group);
%         SvmStruct(RefGroup).PC
    end
    APC(k, :) = PC;
    save(fullfile('SvmClass', savename), 'PC', 'Class');
    fprintf('Task %s(%d) [%d/%d] Done. - %.2f seconds\n', Task, iTask, k, IdxSet(end), toc);
end

save(fullfile('BatchPC', ['SvmBatch', num2str(iTask)]), 'Task', 'IdxSet', 'APC');