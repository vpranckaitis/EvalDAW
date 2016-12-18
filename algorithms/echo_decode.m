function [message] = echo_decode(y, Fs, sample_size, zero_delay, one_delay)

    % divide up a signal into windows
    zero_delay = zero_delay / 1000;
    one_delay = one_delay / 1000;

    segment_length = round(Fs / sample_size);
    segment_transition_time = round(segment_length / (sample_size * 2));

    nx = length(y);                             % size of signal
    w = hamming(segment_length);                % hamming window
    nw = length(w);                             % size of window

    % Calculate starting position so that any silence in the begining of
    % the recording can be safely ignored
    pos = find(y, 1);

    % NOTE: the linter recomended preallocation here!
    zero_delay_signal = zeros(nx, 1);
    one_delay_signal = zeros(nx, 1);
    decision_signal = zeros(nx, 1);

    % while enough signal left
    while (pos + nw <= nx)                       
        window = y(pos : pos + nw - 1) .* w;     % make window

        % Only process the signal if the segment (vector y) contains some
        % non-zero values. There will be no echoes in an empty segment :)
        if any(window)
            try 
                c = abs(rceps(window));

                zero_delay_signal(pos) = c(round(zero_delay * Fs) + 1);
                one_delay_signal(pos) = c(round(one_delay * Fs) + 1);
            catch
                message = '';
                return
            end
        end

        pos = pos + round(nw / segment_transition_time);    % next window
    end

    last_recorded_bit = 0;
    for pos = 1 : length(zero_delay_signal),
        if one_delay_signal(pos) - zero_delay_signal(pos) > 0
        	decision_signal(pos) = 1;
            last_recorded_bit = 1;
        elseif one_delay_signal(pos) - zero_delay_signal(pos) < 0
            decision_signal(pos) = 0;
            last_recorded_bit = 0;
        else
            decision_signal(pos) = last_recorded_bit;
        end        
    end

    current_bit = 2;
    current_run = 0;
    decoded_bit_count = 0;

    % Predict the size of the decoded bit String (bit count)
    bits_to_decode_size_prediction = ceil(length(decision_signal) / 8 ...
        / segment_length) * 8;

    % Initialize the decoded bit String with all zeroes
    decoded_bit_string = zeros(bits_to_decode_size_prediction, 1);

    for pos = 1 : length(decision_signal),
        if current_bit == 2
            current_bit = decision_signal(pos);
        end

        if decision_signal(pos) == current_bit
            current_run = current_run + 1;
        else
            % Calculate the number of corresponding bits we decoded
            segment = current_run / round(segment_length);
            number_of_bits = round(segment);
            last_bit_position = decoded_bit_count + number_of_bits;
            
            decoded_bit_string(decoded_bit_count + 1 : ...
                last_bit_position, 1) = current_bit;

            decoded_bit_count = last_bit_position;

            current_bit = decision_signal(pos);

            current_run = 0;
        end
    end

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
