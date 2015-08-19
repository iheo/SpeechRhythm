function plot_allwindows(stDat)

figure(1);
hold off;
plot(stDat.vec, 'k');
hold on;

STF = stDat.frameStructure;
Nwins = size(stDat.WinKind, 1);
for k = 1:length(stDat.frameStructure)        
    for ii = 1:Nwins
        if STF(k).p2 - STF(k).p1 + 1 == stDat.WinKind(ii).Nw
            break;
        end
    end
    switch ii
        case 1
            mycol = 'b';
        case 2
            mycol = 'y';
        case 3
            mycol = 'g';            
        case 4
            mycol = 'r';
    end    
    plot(STF(k).p1 : STF(k).p2, .1*STF(k).awin, mycol);
end
hold off;