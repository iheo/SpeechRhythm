function plotawins(hfig, W)

Nwin = length(W);
figure(hfig); hold on;
for i = 1:Nwin
    plot(W(i).p1:W(i).p2, .1*W(i).awin);
end