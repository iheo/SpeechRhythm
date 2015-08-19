function frames = vec2varframes(audiodata, OnsetIndex, WinParam)

% Index for Voice onset and offset -- -asymmetric window requires the knowledge of onset and offset index values
% for transition (low -> high, high -> low)
%
%           See AsymWindowsInExcel.xls
%
% Length of Voiced Duration : L
% (if Length(W1) = 120 Used)
% SCENARIOS
% SCN 1
%       0    <= L < 240        W1 -> W1        
% SCN 2 
%       241 <= L < 600  W1 -> W2 -> W2 -> W1
% SCN 3
%       601 <= L < 840  W1 -> W2 -> W3 -> W3 -> W2 -> W1
% SCN 4
%       841 <= L < 1320  W1 -> W2 -> W3 -> W4 -> W3 -> W2 -> W1
% SCN 5
%       1321 <= L           W1 -> W2 -> W3 -> W4 -> ... -> W4 -> W3 -> W2 -> W1
%
% To check it is working, run plot_allwindows(stDat(1));

LenVec = length(audiodata);
Nwins = size(WinParam, 1);
PossibleScenarioCombination = Nwins;

% Ascend window setting
for k = 1:PossibleScenarioCombination
    cc = 1;      
    
    % Ascending windows
    for m = 1:k        
        Scenario(k).WinType(cc) = m;    
        Scenario(k).Ns(cc)= WinParam(m, 1).Ns;
        cc = cc + 1;
    end
    
    % Descending windows
    for m = k : -1 : 1        
        Scenario(k).WinType(cc) = (-1)*m;    
        Scenario(k).Ns(cc)= WinParam(m, 2).Ns;
        cc = cc + 1;
    end    
end

% In the last scenario, there is a single symmetric window in the middle -- remove asymmetric window in the middle
Scenario(k).WinType(k+1) = [];
Scenario(k).Ns(k+1) = [];

% The total length of each scenario
for k = 1:PossibleScenarioCombination
    Scenario(k).Length = sum(Scenario(k).Ns(2:end));
end

% Correct Answer for Scenario.Length 
% Ns = 120, Nwin = 4  ---> [60, 240, 600, 840]
% Ns = 120, Nwin = 5  ---> [60, 240, 600, 1320, 1800]

%%
ScenarioThreshold = [Scenario(2:end).Length];
WindowBetweenThreshold = [WinParam(1, 1).Nw+WinParam(1, 1).Ns, diff(ScenarioThreshold)];
WindowBetweenThreshold = [WindowBetweenThreshold, WindowBetweenThreshold(end)];

U1 = 1; 
p1 = 1;     % Variable hoping index
cc = 1; % output structure index

for ii = 1:length(OnsetIndex)
    U2 = OnsetIndex(ii);
    D = U2 - U1;   % Distance between Onset
    
    % Find the most probable Scenario from the difference between distance and the threshold
    ScenarioKind = min(find(ScenarioThreshold - D >= 0));
    
    if ~isempty(ScenarioKind)
        ScenarioIdx = ScenarioKind;
        NaddWin = -1;
    else % Customized Scenario
        ScenarioIdx = length(Scenario); % the last one + added windows
        NaddWin = floor( (D - ScenarioThreshold(end))/WinParam(Nwins, 1).Ns );    % AW(Nwins, 1).Ns : Increased Length By additional window inserting
    end

    k = 2; % Start with the second window
    
    while(k <= length(Scenario(ScenarioIdx).WinType))
        wintype = Scenario(ScenarioIdx).WinType(k);

        i = abs(wintype);   j = (sign(wintype) < 0) + 1;    % -1 -> 2nd column, 1 -> 1st column

        p2 = p1 + WinParam(i, j).Nw - 1;        
        frames(cc).awin = WinParam(i, j).win;
        frames(cc).p1 = p1;
        frames(cc).p2 = p2;        
        
        if p2 > LenVec
            grain = [audiodata(p1:LenVec); zeros(p2-LenVec,1)];
            frames(cc).frame = grain.*frames(cc).awin;
            break;
        else
            grain = audiodata(p1:p2);
            frames(cc).frame = grain.*frames(cc).awin;
        end            
        
        
        % Update index
        cc = cc + 1;
        p1 = p1 + WinParam(i, j).Ns;
        
        % Additional window insertion
        if i == Nwins & NaddWin > 0
            NaddWin = NaddWin - 1;
        else
            k = k + 1;
        end            
    end
    
    NadditionalWindow = WindowBetweenThreshold(ScenarioIdx)/WinParam(1, 1).Ns;
    NadditionalWindow = NadditionalWindow + 1;
    
    % Additional shortest window (optional)
    % Purpose : To place the onset index in one of the shortest windows (with redundant windows)
    for kk = 1:NadditionalWindow        
        
        
        if p1 + WinParam(1, 1).Nw - 1 > LenVec
            break;
        end
        
        p2 = p1 + WinParam(1, 1).Nw - 1;
        
        frames(cc).awin = WinParam(1, 1).win;
        frames(cc).p1 = p1;
        frames(cc).p2 = p2;
        
        try
            frames(cc).frame = audiodata(p1:p2).*frames(cc).awin;
        catch
            fprintf(' -- (additional window) Limit approached p1 : %d, p2 : %d, Length(vec) %d : \n', p1, p2, length(audiodata));
            break;
        end
        
        % Update Index
        cc = cc + 1;
        p1 = p1 + WinParam(1, 1).Ns;
    end    
    
    U1 = p1;    % Exact Update
end

% Remainder (After the last Unvoice Onset)
p2 = p1 + WinParam(1, 1).Nw - 1;
while(p2 <= length(audiodata))    
    frames(cc).awin = WinParam(1, 1).win;
    frames(cc).p1 = p1;
    frames(cc).p2 = p2;
    frames(cc).frame = audiodata(p1:p2).*frames(cc).awin;
    
    cc = cc + 1;
    p1 = p1 + WinParam(1, 1).Ns;
    p2 = p1 + WinParam(1, 1).Nw - 1;
end