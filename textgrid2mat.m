% function readpraattextgrid(fname);
% Convert Praat textgrid file to matlab .mat file for easier access
clear all;
cd D:\Corpus\GMU\audiodata
load FileWav16kHz
%% Phn category
PhonCat = {
    'AA'    'vowel'    
    'AA0'    'vowel'    
    'AA1'    'vowel'    
    'AA2'    'vowel'    
    'AE'    'vowel'    
    'AE0'    'vowel'    
    'AE1'    'vowel'    
    'AE2'    'vowel'    
    'AH'    'vowel'    
    'AH0'    'vowel'    
    'AH1'    'vowel'    
    'AH2'    'vowel'    
    'AO'    'vowel'    
    'AO0'    'vowel'    
    'AO1'    'vowel'    
    'AO2'    'vowel'    
    'AW'    'vowel'    
    'AW0'    'vowel'    
    'AW1'    'vowel'    
    'AW2'    'vowel'    
    'AY'    'vowel'    
    'AY0'    'vowel'    
    'AY1'    'vowel'    
    'AY2'    'vowel'    
    'B'     'stop'     
    'CH'    'affricate'
    'D'     'stop'     
    'DH'    'fricative'
    'EH'    'vowel'    
    'EH0'    'vowel'    
    'EH1'    'vowel'    
    'EH2'    'vowel'    
    'ER'    'vowel'    
    'ER0'    'vowel'    
    'ER1'    'vowel'    
    'ER2'    'vowel'    
    'EY'    'vowel'    
    'EY0'    'vowel'    
    'EY1'    'vowel'    
    'EY2'    'vowel'    
    'F'     'fricative'
    'G'     'stop'     
    'HH'    'aspirate' 
    'IH'    'vowel'    
    'IH0'    'vowel'    
    'IH1'    'vowel'    
    'IH2'    'vowel'    
    'IY'    'vowel'    
    'IY0'    'vowel'    
    'IY1'    'vowel'   
    'IY2'    'vowel'    
    'JH'    'affricate'
    'K'     'stop'     
    'L'     'liquid'   
    'M'     'nasal'    
    'N'     'nasal'    
    'NG'    'nasal'    
    'OW'    'vowel'    
    'OW0'    'vowel'    
    'OW1'    'vowel'    
    'OW2'    'vowel'    
    'OY'    'vowel'    
    'OY0'    'vowel'    
    'OY1'    'vowel'    
    'OY2'    'vowel'    
    'P'     'stop'     
    'R'     'liquid'   
    'S'     'fricative'
    'SH'    'fricative'
    'T'     'stop'     
    'TH'    'fricative'
    'UH'    'vowel'    
    'UH0'    'vowel'    
    'UH1'    'vowel'    
    'UH2'    'vowel'    
    'UW'    'vowel'    
    'UW0'    'vowel'    
    'UW1'    'vowel'    
    'UW2'    'vowel'    
    'V'     'fricative'
    'W'     'semivowel'
    'Y'     'semivowel'
    'Z'     'fricative'
    'ZH'    'fricative'
    'sp'    'SP'
};

%%
keyword = 'class = "IntervalTier"';
for j = 1:length(accnames)
    fname = accnames{j};    
    fid = fopen(fullfile('wav16kHzTextGrid', [fname, '.TextGrid']));
    if fid < 0
        continue;
    end
    
    str = '';
    k = 1;  Fs = 16000;
    
    % Phone
    clear PhnTime PhnStr
    while(~feof(fid))
        str = fgetl(fid);
        
        if strfind(str, keyword)
            fgetl(fid); fgetl(fid); fgetl(fid);
            str = fgetl(fid);
            
            N = str2num(strskip(str, '='));            
            for k = 1:N
                intervals = fgetl(fid);
                xmin = str2num(strskip(fgetl(fid), 'xmin = '));
                xmax = str2num(strskip(fgetl(fid), 'xmax = '));
                text = strtok(strskip(fgetl(fid), 'text = "'), '"');
                PhnTime(k, 1) = xmin;
                PhnStr{k, 1} = text;
                PhnStr{k, 2} = PhonCat{find(strcmp(text, PhonCat(:, 1))), 2};
            end
            % Duplicate remove
            irm = [];
            for k = 2:N
                if strcmp(PhnStr{k-1, 1}, PhnStr{k, 1})
                    irm = [irm, k];
                end
            end
            PhnStr(irm, :) = [];
            PhnTime(irm) = [];
            break;
        end
    end
    try
    PhnTime = round(PhnTime*Fs);
    end
    
    % Word
    clear WrdTime WrdStr
    while(~feof(fid))
        str = fgetl(fid);
        
        if strfind(str, keyword)
            fgetl(fid); fgetl(fid); fgetl(fid);
            str = fgetl(fid);
            
            N = str2num(strskip(str, '='));
            for k = 1:N
                intervals = fgetl(fid);
                xmin = str2num(strskip(fgetl(fid), 'xmin = '));
                xmax = str2num(strskip(fgetl(fid), 'xmax = '));
                text = strtok(strskip(fgetl(fid), 'text = "'), '"');
                WrdTime(k, 1) = xmin;
                WrdStr{k, 1} = text;                
            end
            % Duplicate remove
            irm = [];
            for k = 2:N
                if strcmp(WrdStr{k-1, 1}, WrdStr{k, 1})
                    irm = [irm, k];
                end
            end
            WrdStr(irm, :) = [];
            WrdTime(irm) = [];
            break;
        end        
    end
    
    fclose(fid);
    try
    fprintf('%d, %d\n', length(PhnStr)-length(PhnTime), length(WrdTime)-length((WrdStr)));
    
    save(fullfile('wav16kHzTextGridMat', [fname, '.mat']), 'PhnTime', 'PhnStr', 'WrdTime', 'WrdStr');
    end
end