function [y] = phase_coding_encode(x, data, segment_size, shift)
    watermark_bits = text2bits(data);

    x = double(x);
    
    text_bit_length = length(watermark_bits);
    
    %%% Process the first valid segment %%%

    % Calculate starting position so that any silence in the begining of 
    % the recording can be safely ignored
    start_segment_position = find(input_bits, 1);

    % For simplicity just cut (skip) these empty bits entirely
    adjusted_input = x(start_segment_position : end);

    % Compute 'delta theta' – the amount to shift phases
    Z = fft(adjusted_input(shift * segment_size + (1 : segment_size)));
    
    theta = angle(Z);
    delta_theta = theta;
    phases = watermark_bits * (-pi) + (pi / 2);

    delta_theta((segment_size / 2 - text_bit_length + 1) ...
        : (segment_size / 2)) = phases;

    delta_theta((segment_size / 2 + 2) : (segment_size / 2 ...
        + text_bit_length + 1)) = -phases(end : -1 : 1);

    delta_theta = delta_theta - theta;

    y = zeros(size(adjusted_input));

    %%% Process (correct) the remaining segments %%%
    % NOTE: since the skipped bits are 0 there is nothing to correct there

    for i = 1 : (length(adjusted_input) / segment_size)
        segment_start = (i - 1) * segment_size + 1;
        segment_end = segment_start + segment_size - 1;
        % Shift phases of the segment
        Z = fft(adjusted_input(segment_start : segment_end));
        R = abs(Z);
        theta = angle(Z);
        new_theta = theta + delta_theta;
        Z = R .* exp(1i * new_theta);
        y(segment_start : segment_end) = ifft(Z);
    end

    % Post-processing the wave
    y = [zeros(start_segment_position - 1, 1); y];

end

function Y = de2bi(X)
    Y = zeros(size(X, 1), 8);
    for i = 1 : size(X, 1)
        Y(i, :) = bitget(X(i), 8 : -1 : 1);
    end
end

function [textBits] = text2bits(text)
    textBytes = unicode2native(text)';
    textBitsMatrix = de2bi(textBytes);
    textBits = reshape(textBitsMatrix', length(textBitsMatrix(:)), 1);
end
