clear all;
fid = fopen('cmudict-0.7b.dict', 'r');
str = '';

for i = 1:126;
    str = fgetl(fid);    
end


i = 1;
while(~feof(fid))
    str = fgetl(fid);
    [Word{i}, Phn{i}] = strtok(str);
    i = i + 1;
end

mystr = 'Please call Stella.  Ask her to bring these things with her from the store  Six spoons of fresh snow peas five thick slabs of blue cheese and maybe a snack for her brother Bob.  We also need a small plastic snake and a big toy frog for the kids.  She can scoop these things into three red bags and we will go meet her Wednesday at the train station.';


str = '1';
remain = mystr;
i = 0;
while(1)    
    [str, remain] = strtok(remain, ' .');
    if isempty(str)
        break;
    end
    i = i + 1;    
    Str{i} = str;    
end
%% Phn category
PhnCat = {
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
    'sp'    'sp'
};
%%
clear phnarray phnclass
cc = 1;
for k = 1:length(Str)
    str = Str{k};
    idx = find(strcmpi(str, Word));
    wordpick{k} = Word{idx};
    phnpick{k} = deblank(Phn{idx}(3:end));
    [phn1, dum] = strtok(phnpick{k});
    while(~isempty(phn1));
        phnarray{cc, 1} = phn1;
        idx = find(strcmp(phn1, PhnCat(:, 1)));
%         try
            phnclass{cc, 1} = PhnCat{idx, 2};
%         end
        [phn1 dum] = strtok(dum);        
        cc = cc + 1;
    end
    phnarray{cc, 1} = 'SP';
    phnclass{cc, 1} = 'SP'; cc = cc + 1;
end
xlswrite('test.xls', [phnarray, phnclass]);
