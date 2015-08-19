function AW = calc_wins(winhandle, NwMin, Nwins)    
% AW = calc_asymwin(winhandle, NwMin, Nwins)        
% First Column : Increasing windows
% Second Column : Decreasing windows
% If Nwins = 4, NwMin = 120;
% AW.Ns may be used by
%
%
% -------------TABLE-----------
%           Ascend(+)  | Descend(-)
%  win1     x                 --
%  win2     x                2x
%  win3    2x               4x
%  win4    4x               --
% ------------------------------
% where x is NwMinHalf
%
% window transition : 1  -> 2   ->  (-2)  ->  (-1)  -> 1
% hop size                     x         x           2x           x
%
% window transition : 1 -> 2 -> 3 -> (-3) -> (-2) -> (-1) ->1
% hop size                     x      x     2x         4x       2x        x
%
% window transition : 1 -> 2 -> 3 -> 4 -> -3 -> -2 -> -1 -> 1
% hop size                    x       x     2x    4x     4x      2x      x
%
%        win1              x     x
%                             |      |
%        win2              x    2x
%                             |      |
%        win3             2x   4x
%                             |   /
%        win4             4x          
%  --> Draw a line in the order of writing 'v'
% The hopping size is easily found by looking for values from the table
%    Ascend : arrow down        Descending windows : arrow toward up

if Nwins==1 % Fixed Length Window
    AW.win = window(winhandle, NwMin);
    AW.Nw = NwMin;
    AW.Ns = round(NwMin/2);
    return;
end
    NwMinHalf = NwMin/2;
    AW(1).win = window(winhandle, NwMin);    
    AW(1).Nw = NwMin;
    AW(1).Ns = NwMin/2;
    
    for k = 2:Nwins-1
        winLeft = win1(winhandle, NwMinHalf*2^(k-2), 'left');
        winRight = win1(winhandle, length(winLeft)*2, 'right');
        AW(k, 1).win = [winLeft; winRight];        
        AW(k, 1).Nw = length(AW(k, 1).win);
        AW(k, 1).Ns = NwMinHalf*2^(k-2);        
    end    
    AW(Nwins, 1).win = window(winhandle, NwMinHalf*2^(Nwins-2)*2);  % Double Side
    AW(Nwins, 1).Nw = length(AW(Nwins).win);
    AW(Nwins, 1).Ns = AW(Nwins-1, 1).Ns*2;
    
    % Decreasing windows
    AW(1, 2) = flipud(AW(1, 1));        AW(Nwins, 2) = flipud(AW(Nwins, 1));    % Symmetric windows are same
    
    for k = 2:Nwins - 1
        AW(k, 2).win = flipud(AW(k, 1).win);
        AW(k, 2).Nw = AW(k, 1).Nw;
        AW(k, 2).Ns = AW(k, 1).Ns*2;
    end
end

function win = win1(winhandle, n, direction, kaiseropt)
% win1(@hanning, 60, 'right')

if ~exist('direction', 'var')
    direction = 'left';
end

if ~exist('kaiseropt', 'var')
    kaiseropt = 6;
end

if ~strcmp(func2str(winhandle), 'kaiser')    
    w = window(winhandle, 2*n);
    if strcmp(direction, 'right')
        win = w(n+1:end);    
    else
        win = w(1:n);
    end
else
    w = window(winhandle, 2*n, kaiseropt);    
    if strcmp(direction, 'right')
        win = w(n+1:end);
    else
        win = w(1:n);
    end    
end
end