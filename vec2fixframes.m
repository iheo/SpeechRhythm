function Z = vec2fixframes(audiodata, win, Ns)
% function Z = vec2fixframes(audiodata, win, Ns)
    Nw = length(win);
    p1 = 1; i = 1;
    while(1)
        p2 = p1 + Nw - 1;
        if p2 > length(audiodata)
            break;
        end
        Z(i).awin = win;
        Z(i).p1 = p1;
        Z(i).p2 = p2;
        Z(i).frame = win.*audiodata(p1:p2);
        
        p1 = p1 + Ns;        
        i = i + 1;
end