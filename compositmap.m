function MT = compositmap(X1X2, X2X3, X3)
% function compositmap(X1, X2, X3)
% returns a 2-column mapping table [test, ref]

X2_X3 = mt2gt(X2X3, X3);
X1X2X3 = mt2gt(X1X2, X2_X3(:, 1));
X1X2X3(:, 2) = X3;
MT = X1X2X3;