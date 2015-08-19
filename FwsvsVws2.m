clear all;
cd C:\Users\iheo\Dropbox\_AMatlab\_AccentGMU\mfiles
% Comparison between Fixed-len window and Variable-len windows
% 1. Impulse signal
sigcolor = 0.5*[1, 1, 1];

[x, Fs] = timit_read('old_files/SX118_MTAS1');
[y, Fs] = timit_read('old_files/SX118_FSEM0');
x = .99*x/max(abs(x));
y = .99*y/max(abs(y));
X.vec = x;  Y.vec = y;

% Fixed length parameter
F.Ns = 0.01*Fs;  % Step size
F.Nw = F.Ns*3;  % Win Size

% Fixed and variable length windowed frames
X.F = vec2fixframes(X.vec, window(@hanning, F.Nw), F.Ns);
Y.F = vec2fixframes(Y.vec, window(@hanning, F.Nw), F.Ns);

% Asymmetric windows
Awins = calc_wins(@hanning, F.Nw/3, 4);
X.V = vec2varframes(X.vec, [2125,5505,10630,11820,16440,21230,24000,27540,29310,30300,33610,37070,37980,39070,42610], Awins);
Y.V = vec2varframes(Y.vec, [2314,2967,4792,7296,10290,13470,13960,15870,19810,20270,21570,22610,24430,28500,29180,30110,31290,36890], Awins);

%% Plot two signals for fixed windows
% Fwx = getvwins(X.F); plot(0.1*Fwx); plot(0.1*Fwx(:, 1:2:end), 'Color', [0, .1, .9]); plot(0.1*Fwx(:, 2:2:end), 'Color', [.9, .1, 0]);
L = max(length(x), length(y))/3;
t = 1:10:min(length(x), length(y));

figure(1);  % Test signal with fixed windows
plot(t, X.vec(t), 'linewidth', 1, 'Color', sigcolor); hold on;
plotawins(1, X.F);  xlim([0, L]);   ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(1, 'tikz\pdf_xfix_s.pdf');
% matlab2tikz('.\tikz\tikz_xfix_s.tex', 'standalone', true);

figure(2);  % Reference signal with fixed windows
plot(t, Y.vec(t), 'linewidth', 1, 'Color', sigcolor);    hold on;
plotawins(2, Y.F);  xlim([0, L]);   ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(2, 'tikz\pdf_yfix_s.pdf');
% matlab2tikz('.\tikz\tikz_yfix_s.tex', 'standalone', true);

% Plot two signals for variable windows
figure(3);
plot(t, X.vec(t), 'linewidth', 1, 'Color', sigcolor); hold on;
plotawins(3, X.V);  xlim([0, L]);   ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(3, 'tikz\pdf_xvar_s.pdf');
% matlab2tikz('.\tikz\tikz_xvar_s.tex', 'standalone', true);

figure(4);
plot(t, Y.vec(t), 'linewidth', 1, 'Color', sigcolor);    hold on;
plotawins(4, Y.V);  xlim([0, L]);   ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(4, 'tikz\pdf_yvar_s.pdf');
% matlab2tikz('.\tikz\tikz_yvar_s.tex', 'standalone', true);

%% Plot DTW cost matrix for fixed vs var len (and the normalized cost)
Fx.P.nfft = F.Nw; Fx.P.nffthalf = round(F.Nw/2);    Fx.P.featKind = 'mag';
Va.P.nfft = Awins(end).Nw; Va.P.nffthalf = round(Va.P.nfft/2);    Va.P.featKind = 'mag';

Feat.XF = calc_featgram(X.F, Fx.P);
Feat.YF = calc_featgram(Y.F, Fx.P);

Feat.XV = calc_featgram(X.V, Va.P);
Feat.YV = calc_featgram(Y.V, Va.P);

Dist.Fx = simmx2(Feat.YF, Feat.XF, 'cosine'); %tanimoto
Dist.Va = simmx2(Feat.YV, Feat.XV, 'cosine');

[Yidx.Fx, Xidx.Fx, Cost.Fx] = dp(1 - Dist.Fx);
[Yidx.Va, Xidx.Va, Cost.Va] = dp(1 - Dist.Va);

% normalize
NCost.Fx = Cost.Fx(end,end)/sum(size(Dist.Fx));
NCost.Va = Cost.Va(end,end)/sum(size(Dist.Va));

NCost.Fx = Cost.Fx(end,end)/length(Yidx.Fx);
NCost.Va = Cost.Va(end,end)/length(Yidx.Va);

figure(5);
imagesc(Cost.Fx);  hold on;    colormap('gray');
plot([1, Xidx.Fx], [1, Yidx.Fx], 'w--', 'linewidth', 2);
text(240, 10, num2str(NCost.Fx(end, end)), 'Color', 'r');
set(gca, 'YDir', 'normal');
hold off;
matlab2tikz('.\tikz\tikz_dtwfix_s.tex', 'standalone', true);

figure(6);
imagesc(Cost.Va);  hold on;    colormap('gray');
plot([1, Xidx.Va], [1, Yidx.Va], 'w--', 'linewidth', 2);
text(220, 8, num2str(NCost.Va(end, end)), 'Color', 'r');
set(gca, 'YDir', 'normal');
hold off;
matlab2tikz('.\tikz\tikz_dtwvar_s.tex', 'standalone', true);

X.Fp1 = [X.F.p1];X.Fp2 = [X.F.p2];
X.Vp1 = [X.V.p1];X.Vp2 = [X.V.p2];
Y.Fp1 = [Y.F.p1];Y.Fp2 = [Y.F.p2];
Y.Vp1 = [Y.V.p1];Y.Vp2 = [Y.V.p2];

[P TS] = idxmapper(X.Fp1(Xidx.Fx), X.Fp2(Xidx.Fx), Y.Fp1(Yidx.Fx), Y.Fp2(Yidx.Fx));
FxMT = [ [P.Abegin]', [P.Sbegin]'];
[P TS] = idxmapper(X.Vp1(Xidx.Va), X.Vp2(Xidx.Va), Y.Vp1(Yidx.Va), Y.Vp2(Yidx.Va));
VaMT = [ [P.Abegin]', [P.Sbegin]'];

%% Plot the resulted waveform 

% Synthesis
[FxOut IndexLog] = tsheo_20140914(Y.vec, X.vec, FxMT, 12, 2);
[VaOut IndexLog] = tsheo_20140914(Y.vec, X.vec, VaMT, 12, 2);

%% 
figure(7);
plot(FxOut,'color', sigcolor, 'linewidth', 2);    xlim([0, L]); ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(7, 'tikz/pdf_outfix_s.pdf');
% matlab2tikz('.\tikz\tikz_outfix_s.tex', 'standalone', true);

figure(8);
plot(VaOut, 'color', sigcolor, 'linewidth', 2);    xlim([0, L]); ylim([-.8, .8]);
axis off; set(gca, 'YTick', [], 'XTick', []); hold off;   box off;
pdfexport(8, 'tikz/pdf_outvar_s.pdf');
% matlab2tikz('.\tikz\tikz_outvar_s.tex', 'standalone', true);