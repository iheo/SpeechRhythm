clear all;
% Create the mapping table first by running 

load FileWav16kHz
    %   see create_gmm for what to be loaded by FileWav16kHz

doNormalize = 1;
Nmix = 4;
SaveName = sprintf('Gmm%dClassTm', Nmix);
if doNormalize
    SaveName = [SaveName, 'N'];
end
SampleOffset = 120; % Discard some samples (at the end, most samples are impulsive)

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

% Native Female
Class(3, 1).name = 'NativeFemaleRef';
Class(3, 1).path = '.\MappingTable\GT100\N3W180R0S0EdN1\english]english165.female.N_english.R_usa.Y43.A43';
Class(3, 1).IsTrain = remove_samepath(IsTrain.IsNative, Class(3, 1).path, accnames);
Class(3, 1).IsTest = remove_samepath(IsTest.IsNative, Class(3, 1).path, accnames);
Class(3, 2).name = 'NonNativeFemaleRef';
Class(3, 2).path = '.\MappingTable\GT100\N3W180R0S0EdN1\japanese]japanese26.female.N_japanese.R_usa.Y6.A44';
Class(3, 2).IsTrain = remove_samepath(IsTrain.IsNonNative, Class(3, 2).path, accnames);
Class(3, 2).IsTest = remove_samepath(IsTest.IsNonNative, Class(3, 2).path, accnames);

%% Create Concatenated vector 
AV = accdata_read(Class, accnames, 'Train', 100);
AVTest = accdata_read(Class, accnames, 'Test', 100);

%% Training GMM
D = 100;
[NClassDef, NGroup] = size(Class);
for iClassDef = 1:NClassDef
    for FromGroup = 1:NGroup
        for RefGroup = 1 : NGroup
            x = AV(iClassDef, FromGroup, RefGroup).Vecs;
%             plot(X);
%             pause;
%             X = x;
            X = resample(x, D, length(x));
            [Label, Gmm, llh] = emgm(X, Nmix);
            GmmClass(iClassDef, FromGroup, RefGroup).Gmm = Gmm;            
            GmmClass(iClassDef, FromGroup, RefGroup).Label = Label;            
            GmmClass(iClassDef, FromGroup, RefGroup).llh = llh;            
        end
    end
end
% norm(SvdClass(1, 1, 1).U - SvdClass(1, 2, 1).U)
% norm(SvdClass(1, 1, 2).U - SvdClass(1, 2, 2).U)
% norm(SvdClass(1, 1, 1).U - SvdClass(1, 2, 1).U)
% fprintf('SVD Computation completed and Saving the data\n');
% save(SaveName, 'SvdClass', 'Class', 'SampleOffset');
%% Classify GMM
[NClassDef, NGroup] = size(Class);
PC = 0;
for iClassDef = 1:NClassDef
    for FromGroup = 1:NGroup
        for RefGroup = 1 : NGroup
            x = AVTest(iClassDef, FromGroup, RefGroup).Vecs;
            X = resample(x, D, length(x));
            Nsamples = size(x, 2);
            P1 = zeros(1, Nsamples);
            P2 = zeros(1, Nsamples);
            for k = 1:Nsamples
                P1(k) = gmmpdf(X(:, k), GmmClass(iClassDef, 1, RefGroup).Gmm);                
                P2(k) = gmmpdf(X(:, k), GmmClass(iClassDef, 2, RefGroup).Gmm);                
            end
            if FromGroup==1
                pc = sum((P1 > P2))/Nsamples;
            else
                pc = sum((P2 > P1))/Nsamples;
            end
%             PC(iClassDef, FromGroup, RefGroup) = pc;
            PC(FromGroup, RefGroup, iClassDef) = pc;
%             Gr(iClassDef).Cat(FromGroup).Pr(RefGroup, :) = Pr;
        end                
    end
%     max(Gr(iClassDef).Cat(RefGroup).P(:, 1) > max(Gr(iClassDef).Cat(RefGroup).P(:, 2)
end

mean(PC(:, :, 1))
mean([PC(:, :, 2); PC(:, :, 3 )])
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

[NClassDef, NGroup] = size(Class);
clear Err;
for iClassDef = 1 : NClassDef
    for TestGroup = 1 : NGroup
        Fidx = find(Class(iClassDef, TestGroup).IsTest);
        for RefGroup = 1 : NGroup            
            
            for i = 1:length(Fidx)
                fname = fullfile(Class(iClassDef, RefGroup).path, [accnames{Fidx(i)}, '.mat']);
                load(fname);    % load 'GTpoly1'

%                 Y = resample(GTpoly1, D, length(GTpoly1));
                Y = GTpoly1;
                pp1 = gmmpdf(Y, GmmClass(iClassDef, 1, RefGroup).Gmm);
                pp2 = gmmpdf(Y, GmmClass(iClassDef, 2, RefGroup).Gmm);

                PrXIC(i, 1) = pp1;
                PrXIC(i, 2) = pp2;
            end            
            disp('dfd');
            pause;
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
