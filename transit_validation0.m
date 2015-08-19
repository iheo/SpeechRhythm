% Validation 
% Given A, B, C and D test sentences, compare the mapping
% A -> X -> B for all sentences X and 
% A ------> B 
% B -> X -> C for all sentences X,
% B ------> C
% ... (all 12 combinations)
%

clear all;
load FileWav16kHz

datKind = {
    'N1W180R0S0EdN0'
    'N1W180R0S0EdN1'
    'N3W180R0S0EdN1'
    'N4W180R0S0EdN1'
    'N5W180R0S0EdN1'
    };

datroot = '.\MappingTable\GT100old';
Files = dir(fullfile(datroot, datKind{1}));
Files = {Files(3:end).name};   % Remove . and ..
Files = {
%     'english]english10.female.N_english.R_usa.Y35.A35';
%     'english]english165.female.N_english.R_usa.Y43.A43';
%     'english]english208.male.N_english.R_usa.Y29.A46';
%     'english]english239.male.N_english.R_usa.Y18.A19';
%     'english]english325.male.N_english.R_usa.Y32.A32';
%     'english]english376.male.N_english.R_usa.Y46.A46';
    'english]english451.male.N_english.R_usa.Y44.A44';
%     'english]english462.male.N_english.R_usa.Y20.A20';    
    'japanese]japanese4.male.N_japanese.R_usa.Y1.A20';    
%     'japanese]japanese26.female.N_japanese.R_usa.Y6.A44';    
    'spanish]spanish35.male.N_spanish.R_usa.Y4.A28'
%     'mankanya]mankanya1.male.N_mankanya.R_.Y0.A27'
%     'maltese]maltese1.female.N_maltese.R_.Y0.A30'
    'russian]russian44.female.N_russian.R_usa.Y10.A29'
%     'malayalam]malayalam3.female.N_malayalam.R_usa.Y15.A19'
    'lao]lao3.male.N_lao.R_usa.Y33.A52'
%     'arabic]arabic80.male.N_arabic.R_usa.Y2.A25'
%     'spanish]spanish83.male.N_spanish.R_usa.Y1.A48'
    'english]english108.male.N_english.R_uk.Y22.A21'
%     'mandarin]mandarin27.male.N_mandarin.R_usa.Y3.A18'
%     'english]english490.male.N_english.R_new zealand.Y19.A18'
%     'russian]russian9.male.N_russian.R_.Y0.A23'
% %     'russian]russian41.female.N_russian.R_usa.Y10.A30'
%      'mortlockese]mortlockese1.male.N_mortlockese.R_usa.Y3.A21'
%      'ga]ga3.female.N_ga.R_usa.Y1.A60'
%      'english]english40.male.N_english.R_uk.Y53.A53'
% %      'panjabi]punjabi4.female.N_punjabi.R_australia.Y3.A33'
%      'kikuyu]kikuyu3.female.N_kikuyu.R_kenya, usa.Y45.A45'
% % 	'lithuanian]lithuanian4.female.N_lithuanian.R_.Y0.A23'
% 	'panjabi]punjabi6.male.N_punjabi.R_usa.Y2.A25'
% % 	'bulgarian]bulgarian4.male.N_bulgarian.R_usa.Y2.A22'
% 	'spanish]spanish46.male.N_spanish.R_usa.Y10.A33'
% % % 	'amharic]amharic15.male.N_amharic.R_usa.Y1.A23'
% 	'english]english305.female.N_english.R_uk, usa.Y7.A24'
% % % 	'dutch]dutch28.male.N_dutch.R_.Y0.A22'
% % 	'tagalog]tagalog7.male.N_tagalog.R_australia.Y22.A60'
% 	'bahasa indonesia]indonesian6.male.N_indonesian.R_usa.Y3.A20'
% % 	'japanese]japanese13.male.N_japanese.R_usa.Y0.A28'
% 	'krio]krio5.male.N_krio.R_sierra leone, usa.Y26.A36'
% 	'lithuanian]lithuanian5.female.N_lithuanian.R_ireland.Y1.A24'
	'spanish]spanish2.male.N_spanish.R_usa.Y1.A20'
% 	'arabic]arabic84.female.N_arabic.R_usa.Y2.A26'
% 	'serbian]serbian1.female.N_serbian.R_usa.Y1.A47'	
% 	'mandarin]mandarin57.male.N_mandarin.R_uk.Y0.A20'
% 	'english]english138.female.N_english.R_usa.Y25.A25'
% 	'hindi]hindi11.male.N_hindi.R_usa.Y7.A20'
% 	'mende]mende3.male.N_mende.R_usa.Y3.A32'
% 	'turkish]turkish24.male.N_turkish.R_usa.Y10.A31'
% 	'farsi]farsi17.female.N_farsi.R_usa.Y3.A27'
	'bosnian]bosnian1.male.N_bosnian.R_usa.Y2.A39'
% 	'arabic]arabic87.female.N_arabic.R_usa.Y1.A49'
	'korean]korean39.male.N_korean.R_usa.Y41.A55'
% 	'russian]russian13.male.N_russian.R_.Y0.A26'
	'mandarin]mandarin50.male.N_mandarin.R_usa.Y0.A25'
% 	'english]english409.female.N_english.R_australia.Y60.A60'
% 	 'tigrigna]tigrigna5.male.N_tigrigna.R_uk.Y27.A45'
	'hadiyya]hadiyya1.male.N_hadiyya.R_uk, usa.Y9.A51'
};
offset = 100;
gridwidth = 10;
%% Pick one reference file and use the detour files to get the validation values
ii = 1;  
for iy = 1 :length(Files)
    for ix = 1 : length(Files)        
        for iu = 1 : length(Files)            
            if iy == iu | ix == iu | ix == iy
                continue;
            end
            file(ii).X2Y = fullfile(Files{iy}, [Files{ix}, '.mat']);                
            file(ii).X2U = fullfile(Files{iu}, [Files{ix}, '.mat']);
            file(ii).U2Y = fullfile(Files{iy}, [Files{iu}, '.mat']);
            
            for k = 1:length(datKind)
                load(fullfile(datroot, datKind{k}, file(ii).X2Y));
                M.X2Y = MT;
                load(fullfile(datroot, datKind{k}, file(ii).X2U));
                M.X2U = MT;
                load(fullfile(datroot, datKind{k}, file(ii).U2Y));            
                M.U2Y = MT;
            
                MaxY = max(M.X2Y(end, 2), M.U2Y(end, 2));
                Grid = gridwidth/2:gridwidth:MaxY-gridwidth;
                % Resampling
                G.X2Y = mt2gt(M.X2Y, Grid);
                G.U2Y = mt2gt(M.U2Y, Grid);
                G.X2U2Y = mt2gt(M.X2U, G.U2Y(:, 1));
                G.X2U2Y(:, 2) = G.U2Y(:, 2);

                N = size(G.X2U2Y, 1);
                Intv = offset:N-offset;
                Err1(ix, iy, k) = simmx2(G.X2U2Y(Intv, 1),G.X2Y(Intv, 1), 'cosine');
                Err2(ix, iy, k) = pow(G.X2U2Y(Intv, 1) - G.X2Y(Intv, 1));                
                Err3(ix, iy, k) = simmx2(G.X2U2Y(Intv, 1),G.X2Y(Intv, 1), 'tanimoto');
%                 Err4(ix, iy, k) = simmx2(G.X2U2Y(Intv, 1),G.X2Y(Intv, 1), 'mahal');
%                 Err5(ix, iy, k) = simmx2(G.X2U2Y(Intv, 1),G.X2Y(Intv, 1), 'corrcoef');
                

                % Plotting
%                 figure(k);
%                 plot(G.X2Y(Intv, 1), G.X2Y(Intv, 2));
%                 hold on;
%                 plot(G.X2U2Y(Intv, 1), G.X2U2Y(Intv, 2), 'r');
%                 hold off;
%                 title(k);
%                 pause;
%     %             file(i).X2U

    %             plot(Diff); pause;
                
            end
            ii = ii + 1;
%             pause;
        end
        fprintf('Completed [ix %d, iy %d]\n', ix, iy);
    end
end

%%
Err = Err2;
MaxErr = max(Err(:));
Vmean = 0;   Vvar = 0;
for k = 1 : length(datKind)
    ee = Err(:, :, k);
    Vmean(k) = mean(ee(:));
    Vmed(k) = median(ee(:));
    Vvar(k) = var(ee(:));
end
Vmean = Vmean/Vmean(2);
% Vvar = Vvar/Vvar(1);

Vmean
Vmed
 Vvar

%%
for k = 1 : length(datKind)
    figure(k);
    bar3(Err(:, :, k)');
    xlabel('Y; Reference');    ylabel('X; Test');
    zlabel('Error');
%     set(gca, 'YDir', 'normal');
%     set(gca, 'XDir', 'reverse');
set(gca, 'XDir', 'normal');
end

view([-40, -30]);

for k = 1:length(datKind)
    % Average
    ydat(k, :) = var(Err(:, :, k), [], 1);
    mean(ydat(k, :))
%     ydat(k, :) = mean(Err(:, :, k), 1);
end
figure(k+1);
plot(ydat', 'o-');
legend(datKind);
title('Distance Measure comparison')

% Winner
% figure(k+2);
% ydat = mean(Err(:, :, 1) > Err(:, :, 2), 1);
% plot(ydat'>0.5, 'o-');



% %% 
% GT.ca2 = mt2gt(MT.cb, GT.ba(:, 1));
% GT.ca2(:, 2) = GT.ba(:, 2);
% 
% figure(4);
% plot(GT.ca(:, 1), GT.ca(:, 2), 'LineSmoothing', 'On'); hold on;
% plot(GT.ca2(:, 1), GT.ca2(:, 2), 'r', 'LineSmoothing', 'On'); hold off;
% 
% legend('C - A', 'C - B & B - A');
% 
% figure(5);
% % error plot
% idxs = 50:size(GT.ca, 1)-50;
% I1 = GT.ca(idxs, 1); I2 = GT.ca2(idxs, 1);
% err = I1 - I2;
% plot(GT.ca(idxs, 2), err);
% 
% normerr = sqrt(sum(err.^2))
% coserr = simmx2(I1, I2)
% dum = corrcoef(I1, I2);
% correlation = dum(1, 2)

% Previously the best aligned indexes
% 529 : 'english_ usa_ male_ west covina_71.wav'
% 527 : 'english_ usa_ male_ washington_208.wav'
% 497 : 'english_ usa_ male_ reading_325.wav'
% 484 : 'english_ usa_ male_ pasadena_376.wav'
% 438 : 'english_ usa_ male_ hazlehurst_451.wav'
% 483 : 'english_ usa_ male_ paducah_462.wav'

% Pick a file as a reference, test1, test2
% fidx.ref = 244; % english_ usa_ female_ davenport_10.wav
% 
% fidx.test1 = 529;   % Pick a file as a test
% fidx.test2 = 527;   % Pick another file as intermediate test file
% 
% zrunByIndex(fidx.ref, fidx.test1, false);
% zrunByIndex(fidx.test1, fidx.test2, false);
% zrunByIndex(fidx.ref, fidx.test2, false);