% SVD


for i = 0:4
    V = load(['BatchPC\BatchPCi', num2str(i)]);
    SvdPCNative(V.IdxSet, :) = V.APC(V.IdxSet, :);
end

for i = 5:14
    V = load(['BatchPC\BatchPCi', num2str(i)]);
    SvdPCGender(V.IdxSet, :) = V.APC(V.IdxSet, :);
end


figure(1);
SvdPCGender(301:397, :) = [];
plot(SvdPCGender); hold on; plot(.52*SvdPCGender(:, 1) + .48*SvdPCGender(:, 2), 'g'); hold off;
legend({'Male', 'Female', 'w-Average'});
title('SVD - Gender');
xlabel('Index for pairs of (male, female) - arbitrary chosen');
ylabel('Percentage of correct');

figure(2);
% SvdPCNative(302:344, :) = [];
plot(SvdPCNative); hold on; plot(.25*SvdPCNative(:, 1) + .75*SvdPCNative(:, 2), 'g'); hold off;
legend({'Native', 'NonNative', 'w-Average'});
title('SVD - Native');
xlabel('Index for pairs of (native, non-native) - arbitrary chosen');
ylabel('Percentage of correct');

[mean(SvdPCGender), mean(SvdPCNative)]
%%
for i = 0:4
    V = load(['BatchPC\SvmBatch', num2str(i)]);
    SvmPCNative(V.IdxSet, :) = V.APC(V.IdxSet, :);    
end

figure(4);
plot(SvmPCNative); hold on; plot(.25*SvmPCNative(:, 1) + .75*SvmPCNative(:, 2), 'g'); hold off;
legend({'Native', 'NonNative', 'w-Average'});
title('K-SVM - Native');
xlabel('Index for pairs of (native, non-native) - arbitrary chosen');
ylabel('Percentage of correct');

for i = 5:14
    V = load(['BatchPC\SvmBatch', num2str(i)]);
    SvmPCGender(V.IdxSet, :) = V.APC(V.IdxSet, :);
end
SvmPCNative([1:43, 87:120], :) = [];
[mean(SvmPCGender), mean(SvmPCNative)]

%% 

for i = 0:4
    V = load(['BatchPC\GmmBatchN2D50i', num2str(i)]);
    GmmPCNative(V.IdxSet, :) = V.APC(V.IdxSet, :);    
end

for i = 5:14
    V = load(['BatchPC\GmmBatchN2D50i', num2str(i)]);
    GmmPCGender(V.IdxSet, :) = V.APC(V.IdxSet, :);
end

[mean(GmmPCGender), mean(GmmPCNative)]
