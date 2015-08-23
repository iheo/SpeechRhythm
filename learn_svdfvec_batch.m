clear all;
% cd D:\Corpus\GMU\audiodata
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

mkdir('SvdClass');
    
if strcmp(Task, 'Native')
    SaveName = sprintf('SvdNativeTm');
    filepairs = FilePairs.Native; Flag{1} = 'IsNative';  Flag{2} = 'IsNonNative';
elseif strcmp(Task, 'Gender')
    SaveName = sprintf('SvdGenderTm');
    filepairs = FilePairs.Gender; Flag{1} = 'IsMale';   Flag{2} = 'IsFemale';
end
doNormalize = 1;
if doNormalize
    SaveName = [SaveName, 'N', num2str(iTask)];
end
maproot = '.\MappingTable\GT100\N3W180R0S0EdN1';

NSvd = 60;

% for k = 1:size(filepairs, 1)
for k = IdxSet
    tic; 
    % Classes Definition
    for j = 1:2
        Class(j).path = fullfile(maproot, filepairs{k, j});
        Class(j).IsTrain = remove_samepath(IsTrain.(Flag{j}), Class(j).path, accnames);
        Class(j).IsTest = remove_samepath(IsTest.(Flag{j}), Class(j).path, accnames);
    end
    
    % SVD Training
    AV = accdata_read_batch(Class, accnames, 'Train');    
    
    for FromGroup = 1:2
        for RefGroup = 1 : 2
%             X = AV(iClassDef, FromGroup, RefGroup).Vecs;
%             X = AV(FromGroup, RefGroup).VecsPoly1;
            X = AV(FromGroup, RefGroup).Vecs;
%             plot(X);
%             pause;
            [U, S, V] = svds(X, 100);
%             [iClassDef, FromGroup, RefGroup]
            SvdClass(FromGroup, RefGroup).U = U;   % Too large to save
%         SvdClass(iClassDef, FromGroup, RefGroup).U = U;   % Too large to save
%         SvdClass(iClassDef, FromGroup, RefGroup).S = S;    % Commenting due to too large file size
%         SvdClass(iClassDef, FromGroup, RefGroup).V = V;
        end
    end
    
    % SVD Testing
    
    clear Err;
    for TestGroup = 1 : 2
        Fidx = find(Class(TestGroup).IsTest);
        for RefGroup = 1 : 2            
            for FromGroup = 1 : 2     
                idx = AV(FromGroup, RefGroup).idx(:, 1);
                U = SvdClass(FromGroup, RefGroup).U(:, 1:NSvd);
                U_ = inv(U'*U)*U';
                for i = 1:length(Fidx)                    
                    fname = fullfile(Class(RefGroup).path, [accnames{Fidx(i)}, '.mat']);
                    load(fname);    % load 'GTpoly1'
                    Vec = GTfit(GT, idx);
                    Coef = U_*Vec;
                    VecHat = U*Coef;
                    Err(TestGroup, FromGroup, RefGroup, i).n2...
                        = norm(VecHat - Vec, 2)/sqrt(length(idx));            % Same for any other distance :  Err(TestGroup, FromGroup, RefGroup, j).n2 = simmx2(VecHat, GTpoly1, 'corrcoef');
                end
%                 fprintf('[Task : %s(%d)] Group%d : %d -> %d\n', Task, iTask, TestGroup, FromGroup, RefGroup);
            end
        end
    end    
    for TestGroup = 1 : 2
        A1 = [Err(TestGroup, 1, 1, :).n2];
        A2 = [Err(TestGroup, 2, 1, :).n2];
        B1 = [Err(TestGroup, 1, 2, :).n2];
        B2 = [Err(TestGroup, 2, 2, :).n2];
        [MinVal, MinIdx] = min([A1; A2; B1; B2]);
        % Report the percent correct if MinIdx is either A1 or A2, i.e., 1 or 3
        if TestGroup == 1
            PC(TestGroup) = (sum(MinIdx==1) + sum(MinIdx==3))/length(MinIdx);
        elseif TestGroup == 2
            PC(TestGroup) = (sum(MinIdx==2) + sum(MinIdx==4))/length(MinIdx);
        end
    end
    APC(k, :) = PC;
    savefullpath = fullfile('SvdClass', [Task, num2str(k)]);    
    save([savefullpath, '.mat'], 'Class', 'SvdClass', 'PC');
    fprintf('Task %s(%d) [%d/%d] Done. - %.2f seconds\n', Task, iTask, k, IdxSet(end), toc);
end
% savename = fullfile('BatchPC', sprintf('SVD_iTask%d.mat', iTask));
save(fullfile('BatchPC', SaveName), 'Task', 'IdxSet', 'APC');