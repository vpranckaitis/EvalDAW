function [message] = phase_coding_decode(y, text_length, segment_size, ...
    shift)

    text_bit_length = text_length * 8;

    % Calculate starting position so that any silence in the begining of 
    % the recording can be safely ignored
    start_segment_position = find(input_bits, 1);
    
%     Z = fft(y(shift * segment_size + (1 : segment_size)));
    Z = fft(y(shift * segment_size + (start_segment_position ...
        : (start_segment_position - 1 + segment_size))));

    theta = angle(Z);

    phases = theta((segment_size / 2 - text_bit_length + 1) ...
        : (segment_size / 2));

    % NOTE: should be '< -(pi / 2) - <some threashold>' if we want to be
    % completely accurate. But in general terms the below should do just
    % fine
    decoded_bit_string = phases < 0;

    % Retrieve the textual representation of the decoded information
    message = bits2text(decoded_bit_string);

end

function Y = bi2de(X)
    Y = zeros(size(X, 1), 1);
    weights = 2 .^ (7 : -1 : 0);
    for i = 1 : size(X, 1) 
        Y(i) = sum(X(i, :) * weights');
    end
end

function [text] = bits2text(textBits)
    textBitsMatrix = reshape(textBits, 8, length(textBits) / 8)';
    textBytes = bi2de(textBitsMatrix);
    text = native2unicode(textBytes)';
end
