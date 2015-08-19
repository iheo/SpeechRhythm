function M = simmx2(X, Y, distancetype)
% M = simmx(X, Y)
% M = simmx(X, Y, DistanceType)
% X : D-by-N
% Y : D-by-M
% M :  N-by-M similarity matrix
% DistanceType : 'cosine', 
%                     'mahal' : Mahalanobis distance

if ~exist('distancetype')
    distancetype = 'cosine';
end
distance = distancetype;

switch distance
    case 'cosine'
        M = cdist(X, Y);
    case 'tanimoto'
        M = tanimoto(X, Y);
    case 'euclidean'
        M = euclidean(X, Y);
    case 'mahal'
        M = mahal(X, Y);        
    case 'corrcoef'
        M = correlation(X, Y);
end
end

function M = correlation(X, Y)
    M = zeros(size(X, 2), size(Y, 2));
    mX = mean(X);   sX = std(X);
    mY = mean(Y);   sY = std(Y);
    for i = 1:size(X, 2)
        for j = 1:size(Y, 2)
            x = X(:, i);    y = Y(:, j);
            M(i, j) = mean((x - mX(i)).*(y-mY(j)))/ (sX(i)*sY(j));            
        end
    end
end

function M = euclidean(X, Y)
    M = zeros(size(X, 2), size(Y, 2));
    for i = 1:size(X, 2);
        for j = 1:size(Y, 2)
            x = X(:, i);    y = Y(:, j);
            M(i, j) = norm(x-y);
        end
    end
end

function M = mahal(X, Y)    % Not normalized t.t
    C = cov([X, Y]');
    invC = inv(C);
    M = zeros(size(X, 2), size(Y, 2));
    for i = 1:size(X, 2)
        for j  = 1:size(Y, 2)
            x = X(:, i);    y = Y(:, j);
            M(i, j) = sqrt( (x-y)'*invC*(x-y));
        end
    end
    
end

function M = tanimoto(X, Y) % more similar -> 1
    M = zeros(size(X, 2), size(Y, 2));
    for i = 1:size(X, 2)
        for j = 1:size(Y, 2)
            x = X(:, i);    y = Y(:, j);
            M(i, j) = dot(x, y)/(sum(x.^2) + sum(y.^2) - dot(x, y));
        end
    end    
end

function M = cdist(X, Y)    % more similar -> 1
    EX = sqrt(sum(X.^2));
    EY = sqrt(sum(Y.^2));
    M = (X'*Y)./(EX'*EY);
end


% count = 1;
% for i = 1:ncA
%  for j = 1:ncB
% %      [C D] = dwarp(A(:, i), B(:, j), 'diffdist');     
%     C = A(:, i);    D = B(:, j);
%     sC = sqrt(sum(C.^2));     sD = sqrt(sum(D.^2));
%    % normalized inner product i.e. cos(angle between vectors)
%    M(i,j) = (C'*D)/(sC*sD);
%    if i==j
%        M(i, j) = 0;
%    end   
%    waitbar(count/ ncA / ncB);
%    count = count + 1;
%  end
% end

% this is 10x faster
