function [IsTrain, IsTest] = idxpart(IsAll, PrTrain);
% [TrainIdx, TestIdx] = idxpart(LogicalIndex, PrTrain);
%   Input
%       LogicalIndex = [0, 1, 0, 0, 0, 1, 1, 1, 0, 1]
%       PrTrain = 0.7;
% 
%   Output
%       TrainIdx = [0, 1, 0, 0, 0, 0, 1, 1, 0, 0]
%       TestIdx = [0, 0, 0, 0, 0, 1, 0, 0, 0, 1]
% 

idx = find(IsAll);
N = length(idx);

Ntrain = round(N*PrTrain);
Ntest = length(idx) - Ntrain;

TrainIdx = nofk(idx, Ntrain);
IsTrain = zeros(size(IsAll));
IsTrain(TrainIdx) = 1;

IsTest = IsAll - IsTrain;