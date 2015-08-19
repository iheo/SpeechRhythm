function remainstr = strskip(strX, skipstr)
% strY = strskip(strX, skipstr)
% Skip str
%   For example
%       lyric = 'A B C C C D E C F G E F';
%       skipstr = 'C';
%       strY = strskip(lyric, skipstr)
%           returns
%       strY = ' C C D E F F G E F

remainstr = strX;
strindex = strfind(strX, skipstr);
if ~isempty(strindex)
    remainstr = strX(strindex(1)+length(skipstr):end);
end