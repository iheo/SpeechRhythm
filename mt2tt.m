clear variables;
% mt2tt
% Batch processing from Mapping Table to Transcribed table (Manual)
% See annotation_eng_davenport10Female.xls for detail

load FileWav16kHz % load audiopath, wavnames

isMapFromReference = 0;
isMapFromTextGrid = ~isMapFromReference;

mtpathroot = '.\MappingTable\MT\';
tgmatroot = '.\wav16kHzTextGridMat';

% gridwidth = 100; % Bin width
Methods = dir(mtpathroot);
Methods = Methods(3:end);

if isMapFromReference    
    
    % Load Manual Annotation (by hand)
    % [N T A] = xlsread('annotationsimple2.xlsx');
    % PHN = T(:, 1);  PHNCAT = T(:, 2); PHNTime = N(:, 1);  % Start time at each phone    
    
    % Forced Alignment
    fnameload = 'english]english10.female.N_english.R_usa.Y35.A35';
    fnameload = 'japanese]japanese26.female.N_japanese.R_usa.Y6.A44';
    % fnameload = 'korean]korean39.male.N_korean.R_usa.Y41.A55';
    % fnameload = 'mandarin]mandarin50.male.N_mandarin.R_usa.Y0.A25';

    load(fullfile(tgmatroot, [fnameload, '.mat']));
    PHN = PhnStr(:, 1); PHNCAT = PhnStr(:, 2);  PHNTime = PhnTime;
end

% Indices for groups
Group = {
    'Native', [find(IsTrain.IsNative), find(IsTest.IsNative)]    
    '< 1 year', [find(IsTrain.IsLearnLessAYear), find(IsTest.IsLearnLessAYear)]
    'Female', [find(IsTrain.IsFemale), find(IsTest.IsFemale)]
    'French', find(cstrfind(accnames, 'N_french'))
    'German', find(cstrfind(accnames, 'N_german'))
    'Japanese', find(cstrfind(accnames, 'N_japanese'))
    'Korean', find(cstrfind(accnames, 'N_korean'))
    'Mandarine', find(cstrfind(accnames, 'N_mandarin'))
%     'Portuguese', find(cstrfind(accnames, 'N_portuguese'))
};

for j = 1:length(Methods)
    Method = Methods(j).name;    
        
    if isMapFromReference
        refname = fnameload;
        pathfrom = fullfile(mtpathroot, Method, refname);
    else
        pathfrom = tgmatroot;
    end
    files = dir(fullfile(pathfrom, '*.mat'));  % Mapping Table files    
        
    for k = 1:length(accnames)
        fname = accnames{k};
        try
            V = load(fullfile(pathfrom, [fname, '.mat']));        
        catch
            myselfidx = k;
            continue;
        end
        
        if isMapFromReference
            ii = find(strcmp(fname(1:end-4), accnames));
            MT = SyncOut.Log.MappingTable;  % Column1 : Test --> Column 2 : Ref
    %         fprintf('%d', sum(diff(MT)==0));
            try
                GT = mt2gt(MT, PHNTime);
            catch
                fprintf('Error at %d\n', k);
            end
        else % From Textgrid
            GT = V.PhnTime;
            PHNCAT = V.PhnStr(:, 2);
        end
            
        NGT = GT/(GT(end, 1) - GT(2, 1));
        Duration = diff(NGT);
        
        % Phone category defining
        try
            Idx.vowel = find(strcmp(PHNCAT, 'vowel'));  % 97
            Idx.semivowel = find(strcmp(PHNCAT, 'semivowel'));
            Idx.fricative = find(strcmp(PHNCAT, 'fricative'));
            Idx.stop = find(strcmp(PHNCAT, 'stop'));
            Idx.aspirate = find(strcmp(PHNCAT, 'aspirate'));
            Idx.affricate = find(strcmp(PHNCAT, 'affricate'));
            Idx.liquid = find(strcmp(PHNCAT, 'liquid'));
            Idx.nasal = find(strcmp(PHNCAT, 'nasal'));
            Idx.SP = find(strcmp(PHNCAT, 'SP'));   Idx.SP = Idx.SP(1:end-1);

            Idx.Obstruent = unique([Idx.stop; Idx.affricate; Idx.fricative]);
            Idx.Sonorant = unique([Idx.nasal; Idx.liquid; Idx.vowel; Idx.semivowel; Idx.aspirate]);
            Idx.Vowel = unique([Idx.vowel; Idx.semivowel]);
            Idx.Consonant = unique([Idx.fricative; Idx.stop; Idx.aspirate; Idx.affricate; Idx.liquid; Idx.nasal]);

            AllPhNames = fieldnames(Idx);
        end        
        
        for m = 1:length(AllPhNames)
            PhDur{k, m} = Duration(Idx.(AllPhNames{m}), 1);
            PhDurSum.(AllPhNames{m})(k) = sum(PhDur{k, m});
        end
        
        waitbar(k/length(files));
    end
    
    if isMapFromReference
        for m = 1:length(AllPhNames)
            PhDurSum.(AllPhNames{m})(myselfidx) = NaN;
        end
    end
    
    %%   See the distribution        
    X = PhDurSum.Vowel; Y = PhDurSum.Consonant; strxlab = 'Normalized Sum Vowel'; strylab = 'Normalized Sum consonant';
%     X = PhDurSum.Obstruent; Y = PhDurSum.Sonorant; strxlab = 'Normalized Sum Obstruent'; strylab = 'Normalized Sum Sonorant';    
    
    for jj = 1:length(Group)
        strleg = Group{jj, 1};
        Idx1 = Group{jj, 2};
        figure(1);     
        plot(X, Y, '.');  hold on;
        plot(X(Idx1), Y(Idx1), 'r.');
        hold off;    
%         title(refname, 'Interpreter', 'None');
        xlabel(strxlab); ylabel(strylab);        
        legend('', strleg);
        pause(0.5);
        print -dmeta
    
        % Logistic Regression Fitting
        DAT = [PhDurSum.Vowel; PhDurSum.fricative; PhDurSum.stop; PhDurSum.liquid; PhDurSum.nasal; PhDurSum.SP]';
        DAT = [X; Y]';
        dum1 = ones(size(DAT, 1), 1);
        classflag = zeros(size(dum1));
        classflag(Idx1) = 1;
        [W, Dev, ST] = glmfit(DAT, [classflag, dum1], 'binomial', 'logit');    
        figure(2);
        stem(2:length(W), W(2:end));
        set(gca, 'XTick', 2:length(W));
        set(gca, 'XTickLabel', {'Vowel', 'Frica', 'Stop', 'Liquid', 'Nasal', 'Space'},...
            'XTickLabelRotation', 30);    
        xlim([1.5, length(W)+0.5]);
        strtitle = [strleg, ' ', sprintf(' /%.2f ', ST.p(2:end)), sprintf(' [D %.2f]', Dev)];
        title(strtitle);
        pause(0.5);
        print -dmeta        
        if jj == 5
            pause;
        end
    end
end