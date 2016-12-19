function er = DoDetection(astego,fs,nbits,m,Nite,varargin)
%
% er = DoDetection(astego,fs,m,Nite)
%
% astego : attacked stego signal (example y.mp3 )
% fs: sampling rate
% m: original message


[h,ch] = size(astego);
for ite = 1:Nite
	ich = randperm(ch,1);
	y = astego(:,ich);

	% Detection Code here
% 	[m_stego(:,ite)] = detection_code(y,....);
	m_stego = decode(y,fs,nbits,m,varargin{:});

% 	% BEGIN == fix for tsedec == 
% 	wavwrite(y,fs,'tseenc.wav');	
% 	[m_stego, idx, cn, flag] = d;
% 	% END == fix for tsedec ==

    m_bits = text2bits(m);
    m_stego_bits = text2bits(m_stego);
	
	lengthm = length(m_bits);
	lengthm_stego = length(m_stego_bits);

    iterCount = lengthm_stego - lengthm;
    
    best_err_coeff = 100;
    
    if iterCount == 0
        iterCount = 1;
    end

    for i = 1 : iterCount
        m_stego_bits_adjusted = m_stego_bits(i : (i + lengthm - 1), 1);
        err_coeff = 100 * length(find(m_bits - m_stego_bits_adjusted)) / lengthm;
    
        if err_coeff < best_err_coeff
            best_err_coeff = err_coeff;
        end
    end

   er(ite) = best_err_coeff;
end
er = mean(er);
end

function Y = de2bi(X)
    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end

function [ textBits ] = text2bits(text)
    textBytes = unicode2native(text)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);
end