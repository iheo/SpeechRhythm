% Speaking rate consistency in native and non-native speakers of English
% Co-authors : Bill Sethares, Eric Raimy
% SR - Speaking Rate
% SRN - SR for Native
% SRO - SR for nOn-native
% RCN - Rate change for native
% RCO - Rate change for non-native

clear all;

load FileWav16kHz
% trainfilelist;

IsNative = IsTrain.IsNative + IsTest.IsNative;
IsNonNative = IsTrain.IsNonNative + IsTest.IsNonNative;

Fs = 16000;

durpath = 'wav16kHzMlfDur';
SentenceLenSam = zeros(size(accnames));

for k = 1:length(accnames)
    V = load(fullfile(durpath, [accnames{k}, '.mat']));
    SenLenSec(k) = (V.Wrd.t1(end)-V.Wrd.t1(1))/Fs/1000;
    
    PhnDurSec(:, k) = V.Phn.dur*V.Phn.t2(end)/Fs/1000;
    PhnDurSecNosp(:, k) = V.PhnNosp.dur*V.PhnNosp.t2(end)/Fs/1000;
    
    WrdDurSec(:, k) = V.Wrd.dur*V.Wrd.t2(end)/Fs/1000;
    WrdDurSecNosp(:, k) = V.WrdNosp.dur*V.WrdNosp.t2(end)/Fs/1000;
end

%%
N.Native = sum(IsNative);
N.NonNative = sum(IsNonNative);
N.Native = 1;
N.NonNative = 1;

SenLen.Native.Mean = mean(SenLenSec(find(IsNative)));
SenLen.Native.Std = std(SenLenSec(find(IsNative)))/sqrt(N.Native);

SenLen.NonNative.Mean = mean(SenLenSec(find(IsNonNative)));
SenLen.NonNative.Std = std(SenLenSec(find(IsNonNative)))/sqrt(N.NonNative);

PhnDur.Native.Mean = mean(mean(PhnDurSec(:, find(IsNative))));
PhnDur.Native.Std = std(std(PhnDurSec(:, find(IsNative))))/sqrt(N.Native);

PhnDur.NonNative.Mean = mean(mean(PhnDurSec(:, find(IsNonNative))));
PhnDur.NonNative.Std = std(std(PhnDurSec(:, find(IsNonNative))))/sqrt(N.NonNative);

WrdDur.Native.Mean = mean(mean(WrdDurSec(:, find(IsNative))));
WrdDur.Native.Std = std(std(WrdDurSec(:, find(IsNative))))/sqrt(N.Native);

WrdDur.NonNative.Mean = mean(mean(WrdDurSec(:, find(IsNonNative))));
WrdDur.NonNative.Std = std(std(WrdDurSec(:, find(IsNonNative))))/sqrt(N.NonNative);

PhnDurAbs.Native.Mean = mean(mean(abs(PhnDurSec(:, find(IsNative)))));
PhnDurAbs.Native.Std = std(std(abs(PhnDurSec(:, find(IsNative)))))/sqrt(N.Native);

PhnDurAbs.NonNative.Mean = mean(mean(abs(PhnDurSec(:, find(IsNonNative)))));
PhnDurAbs.NonNative.Std = std(std(abs(PhnDurSec(:, find(IsNonNative)))))/sqrt(N.NonNative);

WrdDurAbs.Native.Mean = mean(mean(abs(WrdDurSec(:, find(IsNative)))));
WrdDurAbs.Native.Std = std(std(abs(WrdDurSec(:, find(IsNative)))))/sqrt(N.Native);

WrdDurAbs.NonNative.Mean = mean(mean(abs(WrdDurSec(:, find(IsNonNative)))));
WrdDurAbs.NonNative.Std = std(std(abs(WrdDurSec(:, find(IsNonNative)))))/sqrt(N.NonNative);

PhnDurDiff.Native.Mean = mean(mean(diff(PhnDurSec(:, find(IsNative)))));
PhnDurDiff.Native.Std = std(std(diff(PhnDurSec(:, find(IsNative)))))/sqrt(N.Native);

PhnDurDiff.NonNative.Mean = mean(mean(diff(PhnDurSec(:, find(IsNonNative)))));
PhnDurDiff.NonNative.Std = std(std(diff(PhnDurSec(:, find(IsNonNative)))))/sqrt(N.NonNative);

WrdDurDiff.Native.Mean = mean(mean(diff(WrdDurSec(:, find(IsNative)))));
WrdDurDiff.Native.Std = std(std(diff(WrdDurSec(:, find(IsNative)))))/sqrt(N.Native);

WrdDurDiff.NonNative.Mean = mean(mean(diff(WrdDurSec(:, find(IsNonNative)))));
WrdDurDiff.NonNative.Std = std(std(diff(WrdDurSec(:, find(IsNonNative)))))/sqrt(N.NonNative);

PhnDurAbsDiff.Native.Mean = mean(mean(abs(diff(PhnDurSec(:, find(IsNative))))));
PhnDurAbsDiff.Native.Std = std(std(abs(diff(PhnDurSec(:, find(IsNative))))))/sqrt(N.Native);

PhnDurAbsDiff.NonNative.Mean = mean(mean(abs(diff(PhnDurSec(:, find(IsNonNative))))));
PhnDurAbsDiff.NonNative.Std = std(std(abs(diff(PhnDurSec(:, find(IsNonNative))))))/sqrt(N.NonNative);

WrdDurAbsDiff.Native.Mean = mean(mean(abs(diff(WrdDurSec(:, find(IsNative))))));
WrdDurAbsDiff.Native.Std = std(std(abs(diff(WrdDurSec(:, find(IsNative))))))/sqrt(N.Native);

WrdDurAbsDiff.NonNative.Mean = mean(mean(abs(diff(WrdDurSec(:, find(IsNonNative))))));
WrdDurAbsDiff.NonNative.Std = std(std(abs(diff(WrdDurSec(:, find(IsNonNative))))))/sqrt(N.NonNative);


%% 
figure(1);
errorbar([1, 2], [SenLen.Native.Mean, SenLen.NonNative.Mean], [SenLen.Native.Std, SenLen.NonNative.Std], 'o');
set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
ylabel('Averaged spoken time in [sec]');
title('Averaged spoken time of whole paragraph');
% 
% figure(2);
% errorbar([1, 2], [PhnDur.Native.Mean, PhnDur.NonNative.Mean], [PhnDur.Native.Std, PhnDur.NonNative.Std], 'o');
% set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
% ylabel('Averaged spoken time in [sec]');
% title('Phones');
% 
% figure(3);
% errorbar([1, 2], [WrdDur.Native.Mean, WrdDur.NonNative.Mean], [WrdDur.Native.Std, WrdDur.NonNative.Std], 'o');
% set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
% ylabel('Averaged spoken time in [sec]');
% title('Words');

% % figure(4);
% % errorbar([1, 2], [PhnDurAbs.Native.Mean, PhnDurAbs.NonNative.Mean], [PhnDurAbs.Native.Std, PhnDurAbs.NonNative.Std], 'o');
% % set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
% % ylabel('Averaged spoken time in [sec]');
% % title('Please call stella phoneme spoken time');
% 
% figure(5);
% errorbar([1, 2], [WrdDurAbs.Native.Mean, WrdDurAbs.NonNative.Mean], [WrdDurAbs.Native.Std, WrdDurAbs.NonNative.Std], 'o');
% set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
% ylabel('Averaged spoken time in [sec]');
% title('Please call stella word spoken time');

figure(6);
errorbar([1, 2], [PhnDurDiff.Native.Mean, PhnDurDiff.NonNative.Mean], [PhnDurDiff.Native.Std, PhnDurDiff.NonNative.Std], 'o');
set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
ylabel('Averaged spoken time in [sec]');
title('Speaking rate change at PHONEME level');

figure(7);
errorbar([1, 2], [WrdDurDiff.Native.Mean, WrdDurDiff.NonNative.Mean], [WrdDurDiff.Native.Std, WrdDurDiff.NonNative.Std], 'o');
set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
ylabel('Averaged spoken time in [sec]');
title('Speaking rate change at WORD level');

figure(8);
errorbar([1, 2], [PhnDurAbsDiff.Native.Mean, PhnDurAbsDiff.NonNative.Mean], [PhnDurAbsDiff.Native.Std, PhnDurAbsDiff.NonNative.Std], 'o');
set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
ylabel('Averaged spoken time in [sec]');
title('Absolute value of speaking rate change at PHN level');

figure(9);
errorbar([1, 2], [WrdDurAbsDiff.Native.Mean, WrdDurAbsDiff.NonNative.Mean], [WrdDurAbsDiff.Native.Std, WrdDurAbsDiff.NonNative.Std], 'o');
set(gca, 'XTick', [1, 2], 'XTickLabel', {'Native', 'NonNative'});
ylabel('Averaged spoken time in [sec]');
title('Absolute value of speaking rate change at WRD level');

