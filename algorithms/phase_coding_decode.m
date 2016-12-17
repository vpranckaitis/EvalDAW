function [message] = phase_coding_decode(y, text_length, segment_size, shift)
    m = text_length * 8;

    Z = fft(y(shift * segment_size + (1 : segment_size)));
    theta = angle(Z);

    phases = theta((segment_size / 2 - m + 1) : (segment_size / 2));
    textBits = phases < 0;

    message = bits2text(textBits);
end

function Y = bi2de(X)
    Y = zeros(size(X, 1), 1);
    weights = 2 .^ (7 : -1 : 0);
    for i = 1 : size(X, 1) 
        Y(i) = sum(X(i, :) * weights');
    end
end

function [ text ] = bits2text(textBits)
    textBitsMatrix = reshape(textBits, 8, length(textBits) / 8)';
    textBytes = bi2de(textBitsMatrix);
    text = native2unicode(textBytes)';
end