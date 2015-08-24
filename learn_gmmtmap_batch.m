clear all;
% Create the mapping table first by running 

load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz
trainfilelist;
    %   see create_gmm for what to be loaded by FileWav16kHz
% iTask = 0; Task = 'Native';    IdxSet = 1:5;   % My Computer(0) test
% iTask = 1;  Task = 'Native';    IdxSet = 6:130; % My computer (1)
% iTask = 2;  Task = 'Native';    IdxSet = 131:230;   % My computer (2)
% iTask = 3;  Task = 'Native';    IdxSet = 231:330;   % My computer (3)
% iTask = 4;  Task = 'Native';    IdxSet = 331:430;   % My computer (4)
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
if strcmp(Task, 'Native')
    SaveName = sprintf('SvdNativeTm');
    filepairs = FilePairs.Native; Flag{1} = 'IsNative';  Flag{2} = 'IsNonNative';
elseif strcmp(Task, 'Gender')
    SaveName = sprintf('SvdGenderTm');
    filepairs = FilePairs.Gender; Flag{1} = 'IsMale';   Flag{2} = 'IsFemale';
end
maproot = '.\MappingTable\GT100\N3W180R0S0EdN1';


%% GMM parameters
Nmix = 2;
D = 50;    % Reduced dimension
SaveName = sprintf('GmmBatchN%dD%di%d', Nmix, D, iTask);
mkdir('GmmClass');

for k = IdxSet
    tic;
    savename = sprintf('%s%d', Task, k);
    
    %% Class definition
    for j = 1 : 2
        Class(j).path = fullfile(maproot, filepairs{k, j});
        Class(j).IsTrain = remove_samepath(IsTrain.(Flag{j}), Class(j).path, accnames);
        Class(j).IsTest = remove_samepath(IsTest.(Flag{j}), Class(j).path, accnames);
    end

    %% Create Concatenated vector 
    AVTrain = accdata_read_batch(Class, accnames, 'Train');
    AVTest = accdata_read_batch(Class, accnames, 'Test');

    %% Training GMM
    for FromGroup = 1:2
        for RefGroup = 1 : 2
            x = AVTrain(FromGroup, RefGroup).Vecs;
            X = resample(x, D, length(x), 0);
            [Label, Gmm, llh] = emgm(X, Nmix);
            GmmClass(FromGroup, RefGroup).Gmm = Gmm;            
            GmmClass(FromGroup, RefGroup).Label = Label;            
            GmmClass(FromGroup, RefGroup).llh = llh;            
        end
    end
    
    %% Classify GMM    
    
    for FromGroup = 1:2
        for RefGroup = 1 : 2
            x = AVTest(FromGroup, RefGroup).Vecs;
            X = resample(x, D, length(x), 0);
            Nsamples = size(x, 2);
            
            P1 = zeros(1, Nsamples);
            P2 = zeros(1, Nsamples);
            
            for ii = 1:Nsamples
                P1(ii) = gmmpdf(X(:, ii), GmmClass(1, RefGroup).Gmm, 'log');
                P2(ii) = gmmpdf(X(:, ii), GmmClass(2, RefGroup).Gmm, 'log');
            end
            
            if FromGroup==1
                pc = sum((P1 > P2))/Nsamples;
            else
                pc = sum((P2 > P1))/Nsamples;
            end
            PC(FromGroup, RefGroup) = pc;
        end               
    end
    APC(k, :) = mean(PC);
    save(fullfile('GmmClass', savename), 'PC', 'Class');
    fprintf('Task %s(%d) [%d/%d] Done. - %.2f seconds\n', Task, iTask, k, IdxSet(end), toc);
end

save(fullfile('BatchPC', SaveName), 'Task', 'IdxSet', 'APC');

