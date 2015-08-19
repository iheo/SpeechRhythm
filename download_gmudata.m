clear all;

% Write .mov files to the destination folder
urlmovroot = 'http://chnm.gmu.edu/accent/soundtracks/';
folder.dest = './mov/';    
[NUM, STRWHERE, RAW] = xlsread('allcountries.csv');
dat = struct;
%%
for ii = 263:length(STRWHERE)
    
    strwhere = STRWHERE{ii};
    dat(ii).where = strwhere;
    try
        mkdir(fullfile(folder.dest, strwhere));
    catch
        continue;
    end
    
    % The first webpage for the list of speakers
    parpage = urlread(['http://accent.gmu.edu/browse_language.php?function=find&language=', STRWHERE{ii}]);
    str = 'browse_language.php?function=detail&speakerid=';    
    speakeridstamp = strfind(parpage, str);
    if isempty(speakeridstamp)
        continue;
    end
    parpage = parpage(speakeridstamp(1):end);
    
    for k = 1:length(speakeridstamp)            
        parpage = strskip(parpage, str);
        [speakerid, parpage] = strtok(parpage, '"');
        parpage = strskip(parpage, '>');        
        [linkname, parpage] = strtok(parpage, '<');        
        
        % Open another URL to find the exact embedded address
        urlpage = urlread(['http://accent.gmu.edu/browse_language.php?function=detail&speakerid=', speakerid]);
        
        % birth place
        remain = strskip(urlpage, 'birth place');
        remain = strskip(remain, '</em>');        
        [birthplace remain] = strtok(remain, '<');  birthplace = strtrim(birthplace);
        
        % Native Language
        remain = strskip(remain, 'native language');
        remain = strskip(remain, '</em>');
        remain = strskip(remain, '">');
        [nativelang, remain] = strtok(remain, '<'); nativelang = strtrim(nativelang);
        
        % Other Language
        remain = strskip(remain, 'other language');
        remain = strskip(remain, '</em>');
        [otherlang, remain] = strtok(remain, '<');  otherlang = strtrim(otherlang);
        
        % age and gender
        remain = strskip(remain, 'age,');
        remain = strskip(remain, '</em>');
        [age, remain] = strtok(remain, ',');    age = strtrim(age);
        remain = strskip(remain, ',');
        [gender, remain] = strtok(remain, '<'); gender = strtrim(gender);
        
        % English onset
        remain = strskip(remain, 'age of english onset');
        remain = strskip(remain, '</em>');
        [engonset, remain] = strtok(remain, '<');   engonset = strtrim(engonset);
        
        % English learning method
        remain = strskip(remain, 'english learning method');
        remain = strskip(remain, '</em>');
        [englearningmethod, remain] = strtok(remain, '<');  englearningmethod = strtrim(englearningmethod);
        
        % English Residence
        remain = strskip(remain, 'english residence');
        remain = strskip(remain, '</em>');
        [engresidence, remain] = strtok(remain, '<');   engresidence = strtrim(engresidence);
        
        % Length of english residence
        remain = strskip(remain, 'length of english residence');
        remain = strskip(remain, '</em>');
        [englen, remain] = strtok(remain, '<'); englen = strtrim(englen);
        
        % URL for .mov file
        remain = strskip(remain, '<embed src="');
        [urlmov, remain] = strtok(remain, '"');
        
        % File to write to hard drive
        [dum, fname, fdestext] = fileparts(urlmov);
%         fdestfull = fullfile(folder.dest, strwhere, [fname, fdestext]);
        fdest = sprintf('%s.%s.N_%s.R_%s.Y%1.0f.A%s.mov',...
            fname, gender, nativelang, engresidence, sscanf(englen, '%f'), age);
        
        % Read the URL and Download
        tic;
        fdestfull = fullfile(folder.dest, strwhere, fdest);
        urlwrite(urlmov, fdestfull);
        fprintf('downloading %s completed to %s\n', fname, fdestfull);
        
        % Save Biographical Data and etc.
        dat(ii).bio(k).birthplace = birthplace;
        dat(ii).bio(k).nativelang = nativelang;
        dat(ii).bio(k).otherlang = otherlang;
        dat(ii).bio(k).age = age;
        dat(ii).bio(k).gender = gender;
        dat(ii).bio(k).engonset = engonset;
        dat(ii).bio(k).englearningmethod = englearningmethod;
        dat(ii).bio(k).engresidence = engresidence;
        dat(ii).bio(k).englen = englen;
        dat(ii).url(k).mov = urlmov;
        dat(ii).url(k).dest = fdestfull;    % Hard drive destition
        dat(ii).url(k).fname = fname;                
             
        while toc < .5
            % This avoids the overwriting buffers
        end
    end
end
save('DAT', 'dat')
    
%     while(1)
%         [str, remain] = strtok(remain, '<>');
% 
%         if strfind(str, strwhere)
%             [tmpstr, tmpremain] = strtok(str, strwhere);
%             [idxstr, tmpremain] = strtok(tmpstr, ',');
%             idx = str2num(idxstr);
%     %         if idx > 100
%     %             break;
%     %         end
%             [str, remain] = strtok(remain);
%             [sjinfo(idx).all, remain] = strtok(remain, '</');
% 
%             allstr = strsplit(sjinfo(idx).all, ',');
%             sjinfo(idx).gender = strtrim(allstr{1});
%             sjinfo(idx).city = strtrim(allstr{2});
% 
%             if length(allstr)==4
%                 sjinfo(idx).state = strtrim(allstr{3});
%                 sjinfo(idx).country = strtrim(allstr{4});
%             else
%                 sjinfo(idx).state = '';
%                 sjinfo(idx).country = strtrim(allstr{3});
%             end
% 
%             % File read
%             audio.name2read = [strwhere, num2str(idx), '.mov'];
%             
%             audio.fullurl = strcat(audio.url, audio.name2read);
% 
%             % File write
%             audio.name2write = sprintf('%s_%s_%s_%s_%d.mov', strwhere, sjinfo(idx).country, sjinfo(idx).gender, sjinfo(idx).city, idx);
%             tic;            
%             urlwrite(audio.fullurl, fullfile(folder.dest, strwhere, audio.name2write));
%             while toc < .5
%             end
%             fprintf('\n downloading %s completed...', audio.fullurl);
%         end
%         if isempty(str)
%             break
%         end
%     end
% end
    
