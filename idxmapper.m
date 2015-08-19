function [P TS]= idxmapper(P1Test, P2Test, P1Ref, P2Ref);
% Get Variable Time-Stretching Ratio and pointing index
%
%   [P TS]= idxmapper(P1Test, P2Test, P1Ref, P2Ref);
%
%   P1 : The index of windowing start
%   P2 : The index of windowing end
%
%   XTest(P1Test:P2Test)  -----> Match ----> XRef(P1Ref:P2Ref)
%
%              
% Output : Time stretching Ratios, 
%           Refined P1 and P2 (Repeats and Skips are removed)
%               Repeated indexes in Test 
%                         ---> Shrink
%               Repeated indexes in Ref while increasing index in Test 
%                         ---> Stretch
%
%   Note : size(hopSampleIdxTest) == size(hopSampleIdxRef)
%
% To see the output, 
%
% [TS; P.Abegin; P.Aend; P.Sbegin; P.Send]'

nframe = length(P1Test);
m = 1;  k = 1;  p.Abegin = [];  p.Aend = []; p.Sbegin = []; p.Send = [];
while(1)
    if m >= nframe
        break;
    end
    
    p.Abegin = P1Test(m);   % pointing index of the window beginning for analysis
    p.Sbegin = P1Ref(m);    
    
% "Repeat" occurs   --- repeated indexes of test
    if p.Abegin == P1Test(m+1)        
        while(m < nframe)            
            if p.Abegin~=P1Test(m+1)
                break;
            end
            m = m + 1;
        end
% "Skip" occurs  --- repeated indexes of reference
    elseif p.Sbegin == P1Ref(m+1)
        while(m < nframe)            
            if p.Sbegin ~= P1Ref(m+1)
                break;
            end
            m = m + 1;
        end         
    end
    
    p.Aend = P2Test(m);
    p.Send = P2Ref(m);
    
%         try
%             p.Send = hopsampidxRef(m+1) - Ns + Nw - 1;
%         catch
%             if m >= nframe
%                 break;
%             end
%         end
%     end
    
    R = (p.Send - p.Sbegin )/(p.Aend - p.Abegin); % Time stretching Ratio
    
    % Save Parameters
    P(k) = p;   TS(k) = R;
    
    m = m + 1;
    k = k + 1;
end

% Checking the existence of empty portion
% dumA = zeros(size(P(1).Abegin:P(end).Aend));
% dumS = zeros(size(P(1).Sbegin:P(end).Send));
% for k = 1:length(P)
%     dumA(P(k).Abegin:P(k).Aend) = 1;
%     dumS(P(k).Sbegin:P(k).Send) = 1;
% end
% find(dumA==0);  find(dumS==0);

end