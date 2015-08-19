clear all;

load FileWav16kHz

% Load SvdClass.mat
load SvdMfcc1to3
MfccPath = 'Mfcc13N';
NSvdPick = 10;
%   SvdMfcc(1, 2) : Male Speakers mapped to Female
%               .U
%               .S
%               .V
%   Class(1)
%           .name
%           .path
%           .IsTrain
%           .IsTest
%   CIdx{1} : [i, j], i : male j : female (Classes)
%% Classification Rule
% For Gender, There are 4 different groups of features, 
% 1) M -> M
% 2) F -> M
% 3) M -> F
% 4) F -> F
% For Male Speaker, 
%      test Err(X | M -> M) < Err(X | F -> M)
%   +) test Err(X | M -> F) < Err(X | F -> F)
% For Female Speaker
%     test Err(X | M -> M) > Err(X | F -> M)
%   +) test Err(X | M -> F) > Err(X | F -> F)

% Generalize
%      test Err(X1 | 1 -> 1) < Err(X1 | 2 -> 1)
%   +) test Err(X1 | 1 -> 2) < Err(X1 | 2 -> 2)
% 
%      test Err(X2 | 1 -> 1) > Err(X2 | 2 -> 1)
%   +) test Err(X2 | 1 -> 2) > Err(X2 | 2 -> 2)
% 
%  Err is 2-by-2-by-2-by-Nfiles
%       Err(X1 | 1 -> 1) : Err(1, 1, 1, :)
%       Err(X2 | 2 -> 1) : Err(2, 2, 1, :)
%%
% Number of SVD vectors
NSvd = 50;

% Binary Classification
IDX = CIdx{3};  clear Err
% for c2 = 1:length(IDX);

for c0 = 1:2
    Fidx = find(Class(IDX(c0)).IsTest);
    for c2 = 1:2
        j = 1;
        for i = 1:length(Fidx)
            % Read Mapping Table File
            fname = fullfile(Class(IDX(c2)).path, [accnames{Fidx(i)}, '.mat']);
            try
                load(fname); % GTpoly1
            catch
                fprintf('Ref and Test file name may be the same : \n %s\n', fname);                    
                continue;
            end
            
            % Load Mfccgram
            fname = fullfile(MfccPath, [accnames{Fidx(i)}, '.mat']);
            load(fname);

            % Pick some mfccs to match the dimension to time mapindex
            [Fdim Nf] = size(Mfcc);                
            D_ = length(GTpoly1);
%             Npick = floor(D_/Fdim);
%             ipick = sort(randsample(Nf, Npick));                
%             Vec2 = Mfcc(1, ipick);
            Vec2 = Mfcc;

            % Augment Vector
            Vec1 = (GTpoly1 - mean(GTpoly1))/std(GTpoly1);
            Vec = [Vec1; Vec2(:)];

            for c1 = 1:2
                U = SvdClass(IDX(c1), IDX(c2)).U(:, 1:NSvd);
                U_ = inv(U'*U)*U';
                Coef = U_*Vec;
                VecHat = U*Coef;
                Err(c0, c1, c2, j).n2 = norm(VecHat - Vec, 2);
% Same for any other distance :  Err(c0, c1, c2, j).n2 = simmx2(VecHat, GTpoly1, 'corrcoef');
            end
            j = j + 1;
        end
        NTest(c0, c2) = j - 1;
    end
end
%
clear AE
for i = 1 : 2
    for j = 1 : 2
        E1 = [Err(i, 1, j, :).n2];  E2 = [Err(i, 2, j, :).n2];
        AE(i, j).ErrXIC = ( E1 - E2 < 0)';
        AE(i, j).PC = sum(AE(i, j).ErrXIC)/NTest(i, j);
    end
end
mean([AE(1, :).PC])
1 - mean([AE(2, :).PC])

% Acc.Svd(IDX(1)).PC = mean(sum([AE(1, :).ErrXIC], 1));
% Acc.Svd(IDX(2)).PC = 1 - mean(sum([AE(2, :).ErrXIC], 1));

% mean(sum([AE(1, :).ErrXIC], 1))
% 1 - mean(sum([AE(2, :).ErrXIC], 1))