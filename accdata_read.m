function AV = accdata_read(Class, accnames, IdxSet, SampleOffset)
% Read the feature data, append, and return that augmented vector

% SampleOffset = 120;

[NClassDef, NGroup] = size(Class);

if strcmpi(IdxSet, 'Train');
    IdxKind = 'IsTrain';
elseif strcmpi(IdxSet, 'Test');
    IdxKind = 'IsTest';
else
    fprintf('Idx Set is not specified, returning...');
    return;
end

for iClassDef = 1:NClassDef % Binary Classification
    for RefGroup = 1:NGroup
        [a, b, c] = fileparts(Class(iClassDef, RefGroup).path);
        fnameRef = fullfile('wav16kHzMlfDur', [b, c, '.mat']);
        R = load(fnameRef);
        
        % Silence remove        
        Sam1 = R.Wrd.s1(2); 
        Sam2 = R.Wrd.s2(end-1);
    
        for FromGroup = 1 : NGroup
            
            Fidx = find(Class(iClassDef, FromGroup).(IdxKind));
            
            for i = 1:length(Fidx)
                fname = fullfile(Class(iClassDef, RefGroup).path, [accnames{Fidx(i)}, '.mat']);            
                load(fname);    % Load GTpoly1                
                
                % Except Silence
                idx = find(GT(:, 2) > Sam1 & GT(:, 2) < Sam2);
                
                Vec = GTpoly1(idx);
%                 Vec = (Vec - mean(Vec))/std(Vec);
                VecPoly1 = Vec/Vec(end);
                
                % Difference by micro timing
                Vec0 = GT(idx, 1);                
                Vec0 = Vec0/Vec0(end);
                VecDurMicro = diff(Vec0);
                
                % Difference by phone boundaries
                GTnew = mt2gt(MT, R.Phn.s1);
                Vec = GTnew(:, 1);
                Vec = Vec - Vec(2); % Silence samples removved
                Vec = Vec/Vec(end);
                VecPhn = diff(Vec(2:end));
                
                % Difference by word boundaries
                GTnew = mt2gt(MT, R.Wrd.s1);
                Vec = GTnew(:, 1);
                Vec = Vec - Vec(2);
                Vec = Vec/Vec(end);
                VecWrd = diff(Vec(2:end));
                
                % No space version
                ii = find(~cstrfind(R.Wrd.str, 'sp'));   clear jj
                V = GT(idx, 2); V = V(1:end-1);
                for k = 1:length(ii)
                    tmpidx = round(R.Wrd.s1(ii(k))):round(R.Wrd.s2(ii(k)))-1;
                    jj(k).i = find(ismember(V, tmpidx))';
                end
                J = [jj.i];
                VecDurMicroNosp = VecDurMicro(J);                
                
                ii = find(~cstrfind(R.Phn.durStr, 'sp'));
                VecPhnNosp = VecPhn(ii);
                ii = find(~cstrfind(R.Wrd.durStr, 'sp'));
                VecWrdNosp = VecWrd(ii);
                
%                 plot(VecDiffMicro);

                % Augment vectors
                AV(iClassDef, FromGroup, RefGroup).VecsPoly1(:, i) = VecPoly1;
                AV(iClassDef, FromGroup, RefGroup).VecsDurMicro(:, i) = VecDurMicro;
                AV(iClassDef, FromGroup, RefGroup).VecsDurPhn(:, i) = VecPhn;
                AV(iClassDef, FromGroup, RefGroup).VecsDurWrd(:, i) = VecWrd;
                AV(iClassDef, FromGroup, RefGroup).VecsDurMicroNosp(:, i) = VecDurMicroNosp;
                AV(iClassDef, FromGroup, RefGroup).VecsDurPhnNosp(:, i) = VecPhnNosp;
                AV(iClassDef, FromGroup, RefGroup).VecsDurWrdNosp(:, i) = VecWrdNosp;
                
            end
        end
    end
end
fprintf('Augmented Vectors Created\n');