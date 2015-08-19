clear all;

% Compare the Normalized Accumulated Distance

root = 'D:\Corpus\GMU\output3\OutputCost';

kind = {
'N1W180R0S0EdN1'
'N3W180R0S0EdN1'
'N4W180R0S0EdN1'
'N5W180R0S0EdN1'};

refname = 'english]english10.female.N_english.R_usa.Y35.A35';
for k = 1:length(kind)
    allfiles = dir(fullfile(root, kind{k}, refname, '*.mat'));
    allfiles = {allfiles.name};
    
    for i = 1:length(allfiles)
        V = load(fullfile(root, kind{k}, refname, allfiles{i}));        
        NAD1(k, i) = V.SyncOut.Cost.C1;
        NAD2(k, i) = V.SyncOut.Cost.C2;
    end
end
%%
m1 = mean(NAD1, 2);
m2 = mean(NAD2, 2);

m1 = m1/m1(1);
m2 = m2/m2(1);

m1
m2