function GTnew = GTfit(GT, idx)
% GTnew = GTfit(GT, idx)
% GT : N-by-2 matrix, where the mapping is 1st col -> 2nd col


Y = GT(idx, 1); % y = ax + b
% Sam1 = GT(idx(1), 2);   

C0 = Y(1);
D = GT(idx(end-1), 2);


VecNaiveFit = (Y - C0)/(Y(end)-C0)*(D-C0)+C0;
                
[P, S] = polyfit(idx, VecNaiveFit, 1);
GTnew = VecNaiveFit - polyval(P, idx);


% plot(Y); hold on; plot(GT(idx, 2), 'g'); plot(VecNaiveFit, 'r');  plot(GTnew, 'k'); hold off;
% legend({'Original', 'Target', 'NaiveFit', 'Residual'});