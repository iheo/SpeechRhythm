function S = calc_featgram(varframes, P)
% Calculate feature-gram that is the input to the dynamic programming
    
    Nwins = [varframes.p2] - [varframes.p1] + 1;
    Nmax = max(Nwins);
    
    Nframe = length(varframes);
    frames = zeros(Nmax, Nframe);
    for k = 1:Nframe
        frames(:, k) = zeropad(varframes(k).frame, Nmax - length(varframes(k).frame));
    end
    
    Vfft = fft(frames, P.nfft);
    Vmag = abs(Vfft);
    Vmag = Vmag(1:P.nffthalf, :);
    
    switch P.featKind
        case 'mag'            
            S = Vmag;
        case 'mfcc'            
            hz2mel = @( hz )( 1127*log(1+hz/700) );     % Hertz to mel warping function
            mel2hz = @( mel )( 700*exp(mel/1127)-700 ); % mel to Hertz warping function
            dctm = @( N, M )( sqrt(2.0/M) * cos( repmat([0:N-1].',1,M) ...
                                       .* repmat(pi*([1:M]-0.5)/M,N,1) ) );
            H = trifbank(P.nFilterBk, P.nffthalf, [100 4000], P.Fs, hz2mel, mel2hz ); % size of H is M x K     
            DCT = dctm(P.nFdim, P.nFilterBk);    
            FE = H*Vmag;
            S = DCT*log(FE);
        case 'mag_winkind'         % Magnitude plus window kind  
            Nmin = min(Nwins);            
            NwinFeat = Nwins/Nmin;
            S = [NwinFeat; Vmag];                        
            S = bsxfun(@minus, S, mean(S, 2));  % Normalize
    end 
end

function Z = zeropad(x, N)
    % pad N zeros to the tail
    % if N<0, then zeros are padded to the front
    [m, n] = size(x);
    if m > n
        Z = [x; zeros(N, 1)];
    else
        Z = [x, zeros(1, N)];
    end
end