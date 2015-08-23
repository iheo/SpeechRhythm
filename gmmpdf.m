function Pr = gmmpdf(X, gmmmodel, stropt)
% Pr = gmmpdf(gmmmodel)
%   INPUT
%       X : the data for the probability to be evaluated
%           D-dimension Vector
% 
%       gmmmodel
%               .weight (1 X NMIX)
%               .mu  (D X NMIX)
%               .Sigma  (D X D X NMIX)
% 
%   OUTPUT
%       Probability evaluated for X
% 

X = X(:)';
Nmix = length(gmmmodel.weight);
Pr = zeros(1, Nmix);
for n = 1:Nmix
    W = gmmmodel.weight(n);
    Mu = gmmmodel.mu(:, n);
    Sigma = gmmmodel.Sigma(:, :, n);
    if strcmpi(stropt, 'log')
        Pr(n) = W*logmvnpdf(X, Mu', Sigma);
    else
        Pr(n) = W*mvnpdf(X, Mu', Sigma);
    end
end
Pr = sum(Pr);
end

function [logp] = logmvnpdf(x,mu,Sigma)
% outputs log likelihood array for observations x  where x_n ~ N(mu,Sigma)
% x is NxD, mu is 1xD, Sigma is DxD

[N,D] = size(x);
const = -0.5 * D * log(2*pi);

xc = bsxfun(@minus,x,mu);

term1 = -0.5 * sum((xc / Sigma) .* xc, 2); % N x 1
term2 = const - 0.5 * logdet(Sigma);    % scalar
logp = term1' + term2;

end

function y = logdet(A)

U = chol(A);
y = 2*sum(log(diag(U)));

end