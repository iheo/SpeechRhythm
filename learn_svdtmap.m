clear all;
% Create the mapping table first by running 

load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz

doNormalize = 1;
SaveName = sprintf('SvdClassTm');
if doNormalize
    SaveName = [SaveName, 'N'];
end
SampleOffset = 120; % Discard some samples (at the end, most samples are impulsive)

% Load IsTrain and IsTest from another file
load SpkrSubset

%% Class definition
% Gender
Class(1, 1).name = 'Male';
Class(1, 1).path = '.\MappingTable\GT100\N3W180R0S0EdN1\english]english239.male.N_english.R_usa.Y18.A19';
Class(1, 1).IsTrain = remove_samepath(IsTrain.IsMale, Class(1, 1).path, accnames);
Class(1, 1).IsTest = remove_samepath(IsTest.IsMale, Class(1, 1).path, accnames);
Class(1, 2).name = 'Female';
Class(1, 2).path = '.\MappingTable\GT100\N3W180R0S0EdN1\english]english10.female.N_english.R_usa.Y35.A35';
Class(1, 2).IsTrain = remove_samepath(IsTrain.IsFemale, Class(1, 2).path, accnames);
Class(1, 2).IsTest = remove_samepath(IsTest.IsFemale, Class(1, 2).path, accnames);

% Native Male
Class(2, 1).name = 'NativeMaleRef';
Class(2, 1).path = '.\MappingTable\GT100\N3W180R0S0EdN1\english]english451.male.N_english.R_usa.Y44.A44';
Class(2, 1).IsTrain = remove_samepath(IsTrain.IsNative, Class(2, 1).path, accnames);
Class(2, 1).IsTest = remove_samepath(IsTest.IsNative, Class(2, 1).path, accnames);
Class(2, 2).name = 'NonNativeMaleRef';
Class(2, 2).path = '.\MappingTable\GT100\N3W180R0S0EdN1\japanese]japanese4.male.N_japanese.R_usa.Y1.A20';
Class(2, 2).IsTrain = remove_samepath(IsTrain.IsNonNative, Class(2, 2).path, accnames);
Class(2, 2).IsTest = remove_samepath(IsTest.IsNonNative, Class(2, 2).path, accnames);
% 
% % Native Female
Class(3, 1).name = 'NativeFemaleRef';
Class(3, 1).path = '.\MappingTable\GT100\N3W180R0S0EdN1\english]english165.female.N_english.R_usa.Y43.A43';
Class(3, 1).IsTrain = remove_samepath(IsTrain.IsNative, Class(3, 1).path, accnames);
Class(3, 1).IsTest = remove_samepath(IsTest.IsNative, Class(3, 1).path, accnames);
Class(3, 2).name = 'NonNativeFemaleRef';
Class(3, 2).path = '.\MappingTable\GT100\N3W180R0S0EdN1\japanese]japanese26.female.N_japanese.R_usa.Y6.A44';
Class(3, 2).path = '.\MappingTable\GT100\N3W180R0S0EdN1\japanese]japanese13.male.N_japanese.R_usa.Y0.A28';
Class(3, 2).IsTrain = remove_samepath(IsTrain.IsNonNative, Class(3, 2).path, accnames);
Class(3, 2).IsTest = remove_samepath(IsTest.IsNonNative, Class(3, 2).path, accnames);

%% Modified Class Definition
% Class(3, 1).IsTrain = Class(3, 1).IsTrain.*SpkrSubset(1, 3).bool;
% Class(3, 1).IsTest = Class(3, 1).IsTest.*SpkrSubset(1, 3).bool;
% Class(3, 2).IsTrain = Class(3, 2).IsTrain.*SpkrSubset(2, 3).bool;
% Class(3, 2).IsTest = Class(3, 2).IsTest.*SpkrSubset(2, 3).bool;
%% Create Concatenated vector 
% GTdiff2, GTpoly1, choose 1 !
% Polynomial MicrotimingDifference PhnDifference WrdDifference, Choose one
% of normalizing kind
AV = accdata_read(Class, accnames, 'Train', SampleOffset);
AVtest = accdata_read(Class, accnames, 'Test', SampleOffset);

%% Training SVD
[NClassDef, NGroup] = size(Class);
for iClassDef = 1:NClassDef
    for FromGroup = 1:NGroup
        for RefGroup = 1 : NGroup
            X1 = AV(iClassDef, FromGroup, RefGroup).VecsDurMicro;
            X2 = AV(iClassDef, FromGroup, RefGroup).VecsDurPhn;
            X3 = AV(iClassDef, FromGroup, RefGroup).VecsDurWrd;
            
            X4 = AV(iClassDef, FromGroup, RefGroup).VecsDurMicroNosp;
            X5 = AV(iClassDef, FromGroup, RefGroup).VecsDurPhnNosp;
            X6 = AV(iClassDef, FromGroup, RefGroup).VecsDurWrdNosp;
            
            [U1, S, V] = svds(X1, 100);
            [U2, S, V] = svds(X2, 100);
            [U3, S, V] = svds(X3, 100);
            [U4, S, V] = svds(X4, 100);
            [U5, S, V] = svds(X5, 100);
            [U6, S, V] = svds(X6, 100);
            SvdClass(iClassDef, FromGroup, RefGroup).U1 = U1;   % Too large to save
            SvdClass(iClassDef, FromGroup, RefGroup).U2 = U2;   % Too large to save
            SvdClass(iClassDef, FromGroup, RefGroup).U3 = U3;   % Too large to save
            SvdClass(iClassDef, FromGroup, RefGroup).U4 = U4;   % Too large to save
            SvdClass(iClassDef, FromGroup, RefGroup).U5 = U5;   % Too large to save
            SvdClass(iClassDef, FromGroup, RefGroup).U6 = U6;   % Too large to save
        end
    end
end
% norm(SvdClass(1, 1, 1).U - SvdClass(1, 2, 1).U)
% norm(SvdClass(1, 1, 2).U - SvdClass(1, 2, 2).U)
% norm(SvdClass(1, 1, 1).U - SvdClass(1, 2, 1).U)
% fprintf('SVD Computation completed and Saving the data\n');
% save(SaveName, 'SvdClass', 'Class', 'SampleOffset');

%% SVD Classification Rule
% For Gender, There are 4 different groups of features, 
% A1) M -> M;  1 -> 1
% A2) F -> M;  2 -> 1
% B1) M -> F;  1 -> 2
% B2) F -> F;  2 -> 1
% For Male Speaker, 
%      test Err(X | M -> M) < Err(X | F -> M)
%   +) test Err(X | M -> F) < Err(X | F -> F)
% For Female Speaker
%     test Err(X | M -> M) > Err(X | F -> M)
%   +) test Err(X | M -> F) > Err(X | F -> F)

% Generalize
%      test Err(X1 | A1 ) < Err(X1 | A2 )
%   +) test Err(X1 | B1 ) < Err(X1 | B2 )
% 
%      test Err(X2 | A1 ) > Err(X2 | A2 )
%   +) test Err(X2 | B1 ) > Err(X2 | B2 )
%

% load SvdClassTmN

NSvd =60;
[NClassDef, NGroup] = size(Class);
clear Err;
for iClassDef = 1 : NClassDef
    for TestGroup = 1 : NGroup        
        for RefGroup = 1 : NGroup
            for FromGroup = 1 : NGroup
                Fidx = find(Class(iClassDef, TestGroup).IsTest);
                
                U = SvdClass(iClassDef, FromGroup, RefGroup).U1(:, 1:NSvd);
%                 U = SvdClass(iClassDef, FromGroup, RefGroup).U2(:, 1:NSvd);
%                 U = SvdClass(iClassDef, FromGroup, RefGroup).U3(:, 1:NSvd);
%                 U = SvdClass(iClassDef, FromGroup, RefGroup).U4(:, 1:NSvd);
%                 U = SvdClass(iClassDef, FromGroup, RefGroup).U5(:, 1:NSvd);
%                 U = SvdClass(iClassDef, FromGroup, RefGroup).U6(:, 1:NSvd);
                
                U_ = inv(U'*U)*U';
                for i = 1:length(Fidx)
                    Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurMicro(:, i);
%                     Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurPhn(:, i);
%                     Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurWrd(:, i);
%                     Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurMicroNosp(:, i);
%                     Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurPhnNosp(:, i);
%                     Vec = AVtest(iClassDef, TestGroup, RefGroup).VecsDurWrdNosp(:, i);
%                     fname = fullfile(Class(iClassDef, RefGroup).path, [accnames{Fidx(i)}, '.mat']);
%                     load(fname);    % load 'GTpoly1'                    
%                     Coef = U_*GTpoly1(SampleOffset:end-SampleOffset);                    
                    Coef = U_*Vec;
                    
%                     if 0
%                         [a, b, c] = fileparts(Class(iClassDef, RefGroup).path);
%                         fnameRef = fullfile('wav16kHzMlfDur', [b, c, '.mat']);
%                         V = load(fnameRef);
% %                         GTnew = mt2gt(MT, V.t1*10e-8*16000);    % Phn
%                         GTnew = mt2gt(MT, V.wt1*10e-8*16000);   % Wrd
%                         Vec = GTnew(:, 1);                        
%                         Vec = Vec - Vec(2);
%                         Vec = Vec/Vec(end);                        
%                         Vec = diff(Vec);
%                         Coef = U_*Vec;
%                     else % Pure mapping
%                         Coef = U_*GTdiff2(SampleOffset:end-SampleOffset, 1);
%                     end
                    
                    
                    VecHat = U*Coef;
%                     Err(iClassDef, TestGroup, FromGroup, RefGroup, i).n2...
%                         = norm(VecHat - GTpoly1(SampleOffset:end-SampleOffset), 2)/sqrt(length(VecHat));            % Same for any other distance :  Err(TestGroup, FromGroup, RefGroup, j).n2 = simmx2(VecHat, GTpoly1, 'corrcoef');                
%                     Err(iClassDef, TestGroup, FromGroup, RefGroup, i).n2...
%                         = norm(VecHat - GTdiff2(SampleOffset:end-SampleOffset, 1), 2)/sqrt(length(VecHat));            % Same for any other distance :  Err(TestGroup, FromGroup, RefGroup, j).
                    Err(iClassDef, TestGroup, FromGroup, RefGroup, i).n2...
                        = norm(VecHat - Vec, 2)/sqrt(length(VecHat));            % Same for any other distance :  Err(TestGroup, FromGroup, RefGroup, j).
                end
            end
        end    
    end
end

for iClassDef = 1 : NClassDef
    for TestGroup = 1 : NGroup
        A1 = [Err(iClassDef, TestGroup, 1, 1, :).n2];
        A2 = [Err(iClassDef, TestGroup, 2, 1, :).n2];
        B1 = [Err(iClassDef, TestGroup, 1, 2, :).n2];
        B2 = [Err(iClassDef, TestGroup, 2, 2, :).n2];
        [MinVal, MinIdx] = min([A1; A2; B1; B2]);
        % Report the percent correct if MinIdx is either A1 or A2, i.e., 1 or 3
        if TestGroup == 1
            PC(iClassDef, TestGroup) = (sum(MinIdx==1) + sum(MinIdx==3))/length(MinIdx);
        elseif TestGroup == 2
            PC(iClassDef, TestGroup) = (sum(MinIdx==2) + sum(MinIdx==4))/length(MinIdx);
        end
    end
end
PC
K = mean(PC(2:3, :));
K*[1/4;3/4]
