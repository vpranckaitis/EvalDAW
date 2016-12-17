function [y] = phase_coding_encode(x, data, segment_size, shift)
    textBits = text2bits(data);

    x = double(x);
    
    m = length(textBits);
    % Compute 'deltaTheta' – the amount to shift phases
    Z = fft(x(shift * segment_size + (1 : segment_size)));
    theta = angle(Z);
    deltaTheta = theta;
    phases = textBits * (-pi) + (pi / 2);
    deltaTheta((segment_size / 2 - m + 1) : (segment_size / 2)) = phases;
    deltaTheta((segment_size / 2 + 2) : (segment_size / 2 + m + 1)) = -phases(end : -1 : 1);
    deltaTheta = deltaTheta - theta;

    y = zeros(size(x));

    for i = 1 : (length(x) / segment_size)
        segmentStart = (i - 1) * segment_size + 1;
        segmentEnd = segmentStart + segment_size - 1;
        % Shift phases of the segment
        Z = fft(x(segmentStart:segmentEnd));
        R = abs(Z);
        theta = angle(Z);
        newTheta = theta + deltaTheta;
        Z = R .* exp(1i * newTheta);
        y(segmentStart : segmentEnd) = ifft(Z);
    end

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