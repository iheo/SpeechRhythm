function AV = accdata_read(Class, accnames, IdxSet, SampleOffset)
% Read the feature data, append, and return that augmented vector

% SampleOffset = 120;
NGroup = 2;

if strcmpi(IdxSet, 'Train');
    IdxKind = 'IsTrain';
elseif strcmpi(IdxSet, 'Test');
    IdxKind = 'IsTest';
else
    fprintf('Idx Set is not specified, returning...');
    return;
end

    for RefGroup = 1:NGroup
        [a, b, c] = fileparts(Class(RefGroup).path);
        fnameRef = fullfile('wav16kHzMlfDur', [b, c, '.mat']);
        R = load(fnameRef);
        
        % Silence remove        
        Sam1 = R.Wrd.s1(2); 
        Sam2 = R.Wrd.s2(end-1);
    
        for FromGroup = 1 : NGroup
            
            Fidx = find(Class(FromGroup).(IdxKind));
            
            for i = 1:length(Fidx)
                fname = fullfile(Class(RefGroup).path, [accnames{Fidx(i)}, '.mat']);            
                load(fname);    % Load GTpoly1                
                
                % Except Silence
                idx = find(GT(:, 2) > Sam1 & GT(:, 2) < Sam2);
                
%                 Vec = GTpoly1(idx);
%                 Vec = GTpoly1;
%                 Vec = (Vec - mean(Vec))/std(Vec);
%                 VecPoly1 = Vec/Vec(end);
%                 plot(GT(idx, 1)); hold on; plot(Vec, 'r'); plot(GT(idx, 2), 'g'); hold off;
                
                % Polyfit again
                VecPoly1New = GTfit(GT, idx);
                

                
                % Naive Fitting                
%                 Vec = GT(idx, 1);
%                 C0 = Vec(1);
%                 VecNaiveFit = (Vec - C0)/(Vec(end)-C0)*(Sam2-C0)+C0;
                
%                 plot(Vec); hold on; plot(VecNaiveFit, 'r'); plot(GT(idx, 2), 'g'); hold off;
                
%                 % Difference by micro timing
%                 Vec0 = GT(idx, 1);                
%                 Vec0 = Vec0/Vec0(end);
%                 VecDurMicro = diff(Vec0);
%                 
%                 % Difference by phone boundaries
%                 GTnew = mt2gt(MT, R.Phn.s1);
%                 Vec = GTnew(:, 1);
%                 Vec = Vec - Vec(2); % Silence samples removved
%                 Vec = Vec/Vec(end);
%                 VecPhn = diff(Vec(2:end));
%                 
%                 % Difference by word boundaries
%                 GTnew = mt2gt(MT, R.Wrd.s1);
%                 Vec = GTnew(:, 1);
%                 Vec = Vec - Vec(2);
%                 Vec = Vec/Vec(end);
%                 VecWrd = diff(Vec(2:end));
%                 
%                 % No space version
%                 idxsp = find(~cstrfind(R.Wrd.str, 'sp'));   clear jj
%                 V = GT(idx, 2); V = V(1:end-1);
%                 for k = 1:length(idxsp)
%                     tmpidx = round(R.Wrd.s1(idxsp(k))):round(R.Wrd.s2(idxsp(k)))-1;
%                     jj(k).i = find(ismember(V, tmpidx))';
%                 end
%                 J = [jj.i];
%                 VecDurMicroNosp = VecDurMicro(J);                
%                 
%                 idxsp = find(~cstrfind(R.Phn.durStr, 'sp'));
%                 VecPhnNosp = VecPhn(idxsp);
%                 idxsp = find(~cstrfind(R.Wrd.durStr, 'sp'));
%                 VecWrdNosp = VecWrd(idxsp);
%                 
% %                 plot(VecDiffMicro);

                % Augment vectors
                AV(FromGroup, RefGroup).idx(:, i) = idx;
%                 AV(FromGroup, RefGroup).idxsp(:, i) = idxsp;
%                 AV(FromGroup, RefGroup).VecsPoly1(:, i) = VecPoly1;
                AV(FromGroup, RefGroup).Vecs(:, i) = VecPoly1New;
%                 AV(FromGroup, RefGroup).VecsDurMicro(:, i) = VecDurMicro;
%                 AV(FromGroup, RefGroup).VecsDurPhn(:, i) = VecPhn;
%                 AV(FromGroup, RefGroup).VecsDurWrd(:, i) = VecWrd;
%                 AV(FromGroup, RefGroup).VecsDurMicroNosp(:, i) = VecDurMicroNosp;
%                 AV(FromGroup, RefGroup).VecsDurPhnNosp(:, i) = VecPhnNosp;
%                 AV(FromGroup, RefGroup).VecsDurWrdNosp(:, i) = VecWrdNosp;
                
            end
        end
    end
fprintf('Augmented Vectors Created\n');