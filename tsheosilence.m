function varargout = tsheosilence(varargin)

% Xout = tsheo(Xin, Ref, mappingtable)

Ref = varargin{1};
stX = varargin{2};
Xin = stX.vec;
XinLen = stX.len;

XoutLen = XinLen;
Xout = zeros(XoutLen, 1);
silenceStart = min(find(stX.isSilence));
Xout(1: silenceStart) = Xin(1:silenceStart);

mappingTable = varargin{3};
A = mappingTable(:, 1);
B = mappingTable(:, 2);

NwFix = round( max(diff(A))*1.1);   % 5000
NsFix = round( min(diff(A))/4); % 30

if nargin > 3
    NwFix = varargin{4};
    NsFix = varargin{5};
end

M = length(A)-1;

alignoffset = 0;
for m = 1:M
    a1 = A(m);  a2 = A(m+1);    a0 = round( (a1+a2)/2);
    b1 = B(m);  b2 = B(m+1);    b0 = round( (b1+b2)/2);% index for the reference    
    c1 = a1 + alignoffset;
    
    Chunk = zeros(4*(max(a2-a1, b2-b1)), 1);  % to be filled
    
    % Silence duration    
    if ~stX.isSilence(a0) | ~Ref.isSilence(b0)        
        ChunkLen = a2-a1;
        Chunk = Xin(a1:min(a2+1000, A(end)));          
        
    else % stX.isSilence(a0) & Ref.isSilence(b0)  % --> Silence duration
        
        % Initialize
        p1 = a1;
        q1 = 1;    % index for 'chunk'
        
        % Time Stretching Ratio
        tsratio = (b2-b1) / (a2-a1);
        
        % Analysis window length and hop
        pNw = max(round(length(a1:a2)/3), 120);
        pNs = round(pNw/8);
        
        % Synthesis window length and hop
%         qNw = round(pNw*tsratio);
        qNs = round(pNs*tsratio);
        
        % Goal :   signal(a1:a2) ----> signal(b1:b2)
        ChunkLen = b2 - b1; % will be cut by this amount later        
        
        k = 1;
        while(p1 < a2)
            
            p2 = p1 + pNw - 1;  
            q2 = q1 + pNw - 1;            
            
            if k == 1 % Fill the empty bin by the first segment of analysis
                Chunk(1:(a2-a1)+1) = Xin(a1:a2);
            else % Need to store q1Prev, and q2Prev
                Uprev.i1 = q1Prev;  Uprev.i2 = q2Prev;
                Uprev.vec = Chunk(q1Prev:q2Prev);
                
                U.i1 = q1;  U.i2 = q2;
                U.vec = Xin(p1:p2);
                
                stZ = sola(Uprev, U);
                Chunk(stZ.i1 : stZ.i2) = stZ.vec;
            end
            q1Prev = q1;    q2Prev = q2;
            
            p1 = p1 + pNs;
            q1 = q1 + qNs;
            k = k + 1;
        end
        alignoffset = alignoffset + ChunkLen - (a2 - a1); % The amount shifted by the alignment
        % Replace the analysis signal by the Filled Chunk (aligned)       
    end
    
    % another cross fade
    if m>2
        Lo = 50;
        Uprev.i1 = 1;   Uprev.i2 = Lo;    Uprev.vec = ChunkResidue(1:Lo);
        U.i1 = 1;  U.i2 = length(Chunk);  U.vec = Chunk;
        stZ = sola(Uprev, U, 0);
        Chunk = stZ.vec;
    end
    
    c2 = c1 + ChunkLen - 1;        
    
    Xout(c1 : c2) = Chunk(1:ChunkLen);
    ChunkResidue = Chunk(ChunkLen+1:end);
    
%     figure(1);        
%     onecolor = rand(1, 3);
%     subplot(311);   plot(A(m):A(m+2), Xin(A(m):A(m+2)), 'Color', onecolor); vline([A(m), A(m+1)]); hold on;
% %     subplot(312);   plot(stZ.i1 : stZ.i2, Chunk(stZ.i1 : stZ.i2));      vline(ChunkLen); hold off;
%     subplot(313);   plot(c1:c2, Xout(c1:c2), 'Color', onecolor); vline([c1, c2]); hold on;
    datlog = [~stX.isSilence(a0) | ~Ref.isSilence(b0) , a1, a2, b1, b2, c1, c2];
end

varargout{1} = Xout(1:c2);
varargout{2} = datlog;