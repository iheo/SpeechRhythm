function [mappingTable, SampIdx, IdxmappingTable, COST] = dat2warp(stDat1, stDat2)

% Windowing index setting
Ref.featgram = stDat1.featgram;
Ref.p1 = [stDat1.frameStructure.p1];
Ref.p2 = [stDat1.frameStructure.p2];

Test.featgram = stDat2.featgram;
Test.p1 = [stDat2.frameStructure.p1];    % windowing begin index
Test.p2 = [stDat2.frameStructure.p2];    % windowing end index   --> p1 ~ p2 are the support for window

% Metric -- Cosine Distance
DIST = simmx2(Ref.featgram, Test.featgram, 'cosine');     % size(DIST) : Len(Ref) Y -axis  by Len(Test X-axis

% Dynamic Programming
[Ref.idxDP, Test.idxDP, Cost] = dp(1 - DIST);    % X : test Y : reference % size(DIST) : M-by-N Ppath(end) = M, Qpath(end) = N
% [Ref.idp, Test.idp, Cost] = dptw(1 - DIST);    % X : test Y : reference % size(DIST) : M-by-N Ppath(end) = M, Qpath(end) = N

%% Old Version
% Time stretching ratio from variable-length windowed frames
% The result of DTW is the indices that may include repeats or skips.
% get_vts eliminate the repeats and skips, so the resulted new indexes are shorter than .idp
% The output of get_vts is the indices for the Test waveform with overlapping windows
[P TS] = idxmapper(Test.p1(Test.idxDP), Test.p2(Test.idxDP), Ref.p1(Ref.idxDP), Ref.p2(Ref.idxDP));

% Mapping Table
Pbegin = [P.Abegin];   % Analysis hoping index
Qbegin = [P.Sbegin];  % Synthesis hoping index (need to be aligned)

% [Pbegin, Qbegin] = tsrelease(Pbegin, Qbegin, Rthr);
mappingTable = [Pbegin(:), Qbegin(:)];

% How the output looks like ?
SampIdx = [TS; P.Abegin; P.Aend; diff([0, [P.Abegin]]); P.Sbegin; P.Send]';

% Added in 2015/01/26
newTestIdx = idxmapperv2(Test.idxDP, Ref.idxDP, 'center');
IdxmappingTable = [newTestIdx, (1:max(Ref.idxDP))'];    % Column1 : Test, Column2 : Ref

% D2i1 = zeros(1, size(Ref.featgram, 2));
% p = Ref.idxDP;  q = Test.idxDP;
% for i = 1:length(D2i1); 
%     D2i1(i) = q(min(find(p >= i))); 
% end

COST.C = Cost(end,end);
COST.C1 = Cost(end,end)/length(Ref.idxDP);
COST.C2 = Cost(end,end)/size(mappingTable, 1);
