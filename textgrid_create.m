% do forced alignment batch
clear all;
cd C:\Praat\FAVE

warning off;
load D:\Corpus\GMU\audiodata\FileWav16kHz;

root = 'D:\Corpus\GMU\audiodata\wav16kHz';
rootto = 'D:\Corpus\GMU\audiodata\wav16kHzTextGrid';  mkdir(rootto);
pycmd = 'C:\Praat\FAVE\faav.py';

for i = 1:length(accnames)
%    for i = 150
    % Create script file
    fid = fopen('accscript', 'w');
    [x, Fs] = wavread(fullfile(root, [accnames{i}, '.wav']));
    Tbegin = 1/Fs;   Tend = length(x)/Fs;
        fprintf(fid, 'D0324\t%d\t%.3f\t%.3f\tPlease call Stella.  Ask her to bring these things with her from the store:  Six spoons of fresh snow peas, five thick slabs of blue cheese, and maybe a snack for her brother Bob.  We also need a small plastic snake and a big toy frog for the kids.  She can scoop these things into three red bags, and we will go meet her Wednesday at the train station.\n',...
            i, Tbegin, Tend);
    fclose(fid);
    
    wavname = fullfile(root, [accnames{i}, '.wav']);
    textgrid = fullfile(rootto, [accnames{i}, '.TextGrid']);
    runcmd = sprintf('python "%s" "%s" "accscript" "%s"', pycmd, wavname, textgrid);
    if system(runcmd)
        disp('dfd');
    end
%     py(pyfile, wavname, annotname)
end