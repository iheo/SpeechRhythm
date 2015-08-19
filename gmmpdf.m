function Pr = gmmpdf(X, gmmmodel)
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
    Pr(n) = W*mvnpdf(X, Mu', Sigma);
end
Pr = sum(Pr);