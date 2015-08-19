% transit_validation2.m

% Mapping to Y1
% 
% X1 -> Y1        vs      X1 -> Y2 -> Y1
% X2 -> Y1        vs      X2 -> Y2 -> Y1
% X3 -> Y1        vs      X3 -> Y2 -> Y1
% ...
% X2263 -> Y1     vs      X2263 -> Y2 -> Y1
% 
% Mapping to Y2
% 
% X1 -> Y2        vs      X1 -> Y1 -> Y2
% X2 -> Y2        vs      X2 -> Y1 -> Y2
% X3 -> Y2        vs      X3 -> Y1 -> Y2
% ...
% X2263 -> Y2     vs      X2263 -> Y1 -> Y2

clear all;

load FileWav16kHz
Fs = 16000;
% maproot = '.\MappingTable\GT100old';
maproot = '.\MappingTable\GT100';
% maproot = '.\MappingTable\MT';

Y1.Fname = 'english]english239.male.N_english.R_usa.Y18.A19';   Y1.Samples = [7352, 355332]; % Sample numbers of starting and ending the waveform
Y2.Fname = 'english]english10.female.N_english.R_usa.Y35.A35';  Y2.Samples = [6928, 328688];

% Y1.Samples = [4000, 360000];    Y2.Samples = [4000, 340000];
% 
% Y1.Fname = 'english]english451.male.N_english.R_usa.Y44.A44';   Y1.Samples = [5000, 415711];
% Y2.Fname = 'japanese]japanese4.male.N_japanese.R_usa.Y1.A20';   Y2.Samples = [5000, 629372];

% Y1.Fname = 'english]english165.female.N_english.R_usa.Y43.A43'; Y1.Samples = [5500, 366808];
% Y2.Fname = 'japanese]japanese26.female.N_japanese.R_usa.Y6.A44'; Y2.Samples = [5000, 510711];

% Y1.Fname = 'english]english165.female.N_english.R_usa.Y43.A43'; Y1.Samples = [5500, 366808];
% Y2.Fname = 'japanese]japanese13.male.N_japanese.R_usa.Y0.A28';  Y2.Samples = [13400, 465000];

Y1.wav = wavread(fullfile('wav16kHz', [Y1.Fname, '.wav']));
Y2.wav = wavread(fullfile('wav16kHz', [Y2.Fname, '.wav']));

V1 = load(fullfile('wav16kHzTextGridMat', [Y1.Fname, '.mat']));
V2 = load(fullfile('wav16kHzTextGridMat', [Y2.Fname, '.mat']));
% V2 = load('english10');

NX = length(accnames);

Config = {
    'N1W180R0S0EdN0'
    'N1W180R0S0EdN1'
    'N3W180R0S0EdN1'
    'N4W180R0S0EdN1'
    'N5W180R0S0EdN1'
    };
iConfig = 3;

%% Short pause remove or not
RemoveSP = 0;   % 1 - remove Short Pause -> the misalignment of short pauses 
jtmp = find(strcmp(V2.PhnStr(:, 1), 'sp'));
jtmp = V2.PhnTime([jtmp(1:end-1),jtmp(1:end-1)+1])/Fs;

%% Loop begins
for ix = 1:NX    
    
    if ix==2034
        disp('dfd');
    end
    if strcmp(Y1.Fname, accnames{ix}) | strcmp(Y2.Fname, accnames{ix})
        continue;
    end
    XY1.fname = fullfile(Y1.Fname, [accnames{ix}, '.mat']);
    XY2.fname = fullfile(Y2.Fname, [accnames{ix}, '.mat']);
    
    Y1Y2.fname = fullfile(Y2.Fname, [Y1.Fname, '.mat']);
    Y2Y1.fname = fullfile(Y1.Fname, [Y2.Fname, '.mat']);
    
    %% Load mapping tables of XY1, XY2, Y1Y2, Y2Y1
    tmp1 = load(fullfile(maproot, Config{iConfig}, XY1.fname));
    XY1.mt = tmp1.MT; 
%     XY1.mt = tmp1.SyncOut.Log.MappingTable;
    
    tmp2 = load(fullfile(maproot, Config{iConfig}, XY2.fname));
    XY2.mt = tmp2.MT;
%     XY2.mt = tmp2.SyncOut.Log.MappingTable;
    
    tmp3 = load(fullfile(maproot, Config{iConfig}, Y1Y2.fname));
    Y1Y2.mt = tmp3.MT;
%     Y1Y2.mt = tmp3.SyncOut.Log.MappingTable;
    
    tmp4 = load(fullfile(maproot, Config{iConfig}, Y2Y1.fname));
    Y2Y1.mt = tmp4.MT;
%     Y2Y1.mt = tmp4.SyncOut.Log.MappingTable;
    
    %% Normalize the duration of every X mapping to a fixed Y
    %  Silence at the beginning and at the end is removed and convert it to
    %  in second
    XY1.MT = XY1.mt(find(XY1.mt(:, 2) >= Y1.Samples(1) & XY1.mt(:, 2) <= Y1.Samples(2)), :)/Fs;
    XY2.MT = XY2.mt(find(XY2.mt(:, 2) >= Y2.Samples(1) & XY2.mt(:, 2) <= Y2.Samples(2)), :)/Fs;
    Y1Y2.MT = Y1Y2.mt(find(Y1Y2.mt(:, 2) >= Y2.Samples(1) & Y1Y2.mt(:, 2) <= Y2.Samples(2)), :)/Fs; 
    Y2Y1.MT = Y2Y1.mt(find(Y2Y1.mt(:, 2) >= Y1.Samples(1) & Y2Y1.mt(:, 2) <= Y1.Samples(2)), :)/Fs; 
    
    % Polynomial fitting
%     P = polyfit(XY1.MT(:, 1), XY1.MT(:, 2), 1);
%     XY1.MT(:, 1) = polyval(P, XY1.MT(:, 1));
%     P = polyfit(XY2.MT(:, 1), XY2.MT(:, 2), 1);
%     XY2.MT(:, 1) = polyval(P, XY2.MT(:, 1));    
%     P = polyfit(Y1Y2.MT(:, 1), Y1Y2.MT(:, 2), 1);
%     Y1Y2.MT(:, 1) = polyval(P, Y1Y2.MT(:, 1));
%     P = polyfit(Y2Y1.MT(:, 1), Y2Y1.MT(:, 2), 1);
%     Y2Y1.MT(:, 1) = polyval(P, Y2Y1.MT(:, 1));
    
    % Naive fitting
    C = XY1.MT(1, 1);
    XY1.MT(:, 1) = (XY1.MT(:, 1) - C)/(XY1.MT(end, 1) - C)*(XY1.MT(end, 2) - C) + C;
    C = XY2.MT(1, 1);
    XY2.MT(:, 1) = (XY2.MT(:, 1) - C)/(XY2.MT(end, 1) - C)*(XY2.MT(end, 2) - C) + C;
    C = Y1Y2.MT(1, 1);
    Y1Y2.MT(:, 1) = (Y1Y2.MT(:, 1) - C)/(Y1Y2.MT(end, 1) - C)*(Y1Y2.MT(end, 2) - C) + C;
    C = Y2Y1.MT(1, 1);
    Y2Y1.MT(:, 1) = (Y2Y1.MT(:, 1) - C)/(Y2Y1.MT(end, 1) - C)*(Y2Y1.MT(end, 2) - C) + C;
    
    %% Checking the normalization effect by plotting
%     figure(1);
%     plot(XY1.mt(:, 1),XY1.mt(:, 2)); hold on;
%     plot(Y2Y1.mt(:, 1), Y2Y1.mt(:, 2),'r'); hold off;
%     title('Before Normaliztion');
%     
%     figure(2);
%     plot(XY1.MT(:, 1),XY1.MT(:, 2)); hold on;
%     plot(Y2Y1.MT(:, 1), Y2Y1.MT(:, 2),'r'); hold off;
%     title('After Normaliztion');

    %% create Composite mapping XY1Y2, XY2Y1
    Y1.Grid = XY1.MT(:, 2);
    Y2.Grid = XY2.MT(:, 2);
       
    XY1Y2.MT = compositmap(XY1.MT, Y1Y2.MT, Y2.Grid);    
    XY2Y1.MT = compositmap(XY2.MT, Y2Y1.MT, Y1.Grid);
    
    % Mean subtraction
    XY1.MT = bsxfun(@minus, XY1.MT, mean(XY1.MT));
    XY2Y1.MT = bsxfun(@minus, XY2Y1.MT, mean(XY2Y1.MT));
    XY2.MT = bsxfun(@minus, XY2.MT, mean(XY2.MT));
    XY1Y2.MT = bsxfun(@minus, XY1Y2.MT, mean(XY1Y2.MT));

    % Variance Normalization
%     XY1.MT = bsxfun(@times, XY1.MT, 1./std(XY1.MT));
%     XY2Y1.MT = bsxfun(@times, XY2Y1.MT, 1./std(XY2Y1.MT));
%     XY2.MT = bsxfun(@times, XY2.MT, 1./std(XY2.MT));
%     XY1Y2.MT = bsxfun(@times, XY1Y2.MT, 1./std(XY1Y2.MT));
    
    %% Compare the direct vs indirect map
%     figure(1);
%     plot(XY2Y1.MT(:, 1), XY2Y1.MT(:, 2), '.-'); hold on;
%     plot(XY1.MT(:, 1), XY1.MT(:, 2), '.-r');
% %     plot(Y1.wav+10, (1:length(Y1.wav))/Fs);  hold off; grid on;
%     
%     
%     figure(2);
%     plot(XY1Y2.MT(:, 1), XY1Y2.MT(:, 2), '.-'); hold on;
%     plot(XY2.MT(:, 1), XY2.MT(:, 2), '.-r'); 
%     plot(Y2.wav+10, (1:length(Y2.wav))/Fs);  hold off; grid on;
    
%% Remove SP (SHort Pause) ?
    if RemoveSP
        i_SP = find( Y2.Grid > jtmp(1, 1) & Y2.Grid <= jtmp(1, 2));
        for i = 2:size(jtmp, 1)-1
            i_SP = [i_SP; find( Y2.Grid > jtmp(i, 1) & Y2.Grid <= jtmp(i, 2))];
        end
        i_SP = [i_SP; find(Y2.Grid > jtmp(end, 1))];        
        XY2.MT(i_SP, :) = [];
        XY1Y2.MT(i_SP, :) = [];
    end
    
    %% Error calculation    
    Diff.XY1 = XY1.MT(:, 1) - XY2Y1.MT(:, 1);   N1 = size(Diff.XY1, 1);
    Diff.XY2 = XY2.MT(:, 1) - XY1Y2.MT(:, 1);   N2 = size(Diff.XY2, 1);
    
%     Diff.XY1 = Diff.XY1 - mean(Diff.XY1);
%     Diff.XY2 = Diff.XY2 - mean(Diff.XY2);
    
    Err(ix).XY1 = sum(abs(Diff.XY1))/N1;
    Err(ix).XY2 = sum(abs(Diff.XY2))/N2;
    
    PC20(ix).XY1 = sum(abs(Diff.XY1) < .02)/N1;
    PC20(ix).XY2 = sum(abs(Diff.XY2) < .02)/N2;
    
    PC25(ix).XY1 = sum(abs(Diff.XY1) < .025)/N1;
    PC25(ix).XY2 = sum(abs(Diff.XY2) < .025)/N2;
    
%     Err(ix).XY1, Err(ix).XY2
    
    %% status printing
    if mod(ix, 100) == 0        
        fprintf('[ %d / %d]\n', ix, NX);
    end
end

%% Pick speakers with least transitive validation error
SpkrSubset(1, 1).Fname = Y1.Fname;
SpkrSubset(1, 1).Kind = '80% least transitive error';
[yy, ii] = sort([Err.XY1]);
SpkrSubset(1, 1).bool = zeros(1, NX);
SpkrSubset(1, 1).bool(ii(1:round(NX*.8))) = 1;

SpkrSubset(1, 2).Fname = Y1.Fname;
SpkrSubset(1, 2).Kind = '60% least transitive error';
[yy, ii] = sort([Err.XY1]);
SpkrSubset(1, 2).bool = zeros(1, NX);
SpkrSubset(1, 2).bool(ii(1:round(NX*.6))) = 1;

SpkrSubset(1, 3).Fname = Y1.Fname;
SpkrSubset(1, 3).Kind = '60% Random pick';
SpkrSubset(1, 3).bool = zeros(1, NX);
SpkrSubset(1, 3).bool(randsample(NX, round(.6*NX))) = 1;

SpkrSubset(2, 1).Fname = Y2.Fname;
SpkrSubset(2, 1).Kind = '80% least transitive error';
[yy, ii] = sort([Err.XY2]);
SpkrSubset(2, 1).bool = zeros(1, NX);
SpkrSubset(2, 1).bool(ii(1:round(NX*.8))) = 1;

SpkrSubset(2, 2).Fname = Y2.Fname;
SpkrSubset(2, 2).Kind = '60% least transitive error';
[yy, ii] = sort([Err.XY2]);
SpkrSubset(2, 2).bool = zeros(1, NX);
SpkrSubset(2, 2).bool(ii(1:round(NX*.6))) = 1;

SpkrSubset(2, 3).Fname = Y2.Fname;
SpkrSubset(2, 3).Kind = '60% Random pick';
SpkrSubset(2, 3).bool = zeros(1, NX);
SpkrSubset(2, 3).bool(randsample(NX, round(.6*NX))) = 1;

save SpkrSubset SpkrSubset

%% Error
% .1838, .2233 --> polyfit
% .1597, .1891 --> Naive Fit (SP removed -- .1902)
% .1734, .1992 --> N1(Naive)
% .1983, .2264 --> N1(Polyfit)
median([Err.XY1])
median([Err.XY2])

figure(5);
plot([Err.XY1]); xlabel('# Speaker'); ylabel('Error in [Sec]');
title(Y1.Fname, 'Interpreter', 'None');

figure(6);
plot([Err.XY2]); xlabel('# Speaker'); ylabel('Error in [Sec]');
title(Y2.Fname, 'Interpreter', 'None');