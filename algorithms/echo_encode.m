function [y] = echo_encode(x, data, Fs, sample_size, zero_delay,...
    one_delay, decay_rate)

    watermark_bits = text2bits(data);

    x = double(x);

    length_in_s = round(length(x) / (Fs * sample_size / 8));
    watermark_size = size(watermark_bits, 1);
    
    if watermark_size >= length_in_s * sample_size,
        y = x;
        return
    end

    % divide up a signal into windows
    zero_delay_signal = single_echo(x, Fs, zero_delay, ...
        decay_rate);
    one_delay_signal = single_echo(x, Fs, one_delay, decay_rate);

    segment_length = round(Fs / sample_size);
    segment_transition_time = round(segment_length / (sample_size * 2));

    % Initialize the mixer signals
    one_mixer_signal = zeros(size(x, 1), 1);

    % Generate the one mixer signal based on watermark information
    last_bit = 2;

    % Calculate starting position so that any silence in the begining of 
    % the recording can be safely ignored
    one_mixer_position = find(x, 1);

    for index = 1 : watermark_size,
        watermark_bit = watermark_bits(index);
        % write the transition if necessary
        for i = 1 : segment_transition_time,
            if watermark_bit == last_bit || last_bit == 2
                one_mixer_signal(one_mixer_position + i) = watermark_bit;
            else
                if watermark_bit == 1,
                    trans_val = (i / segment_transition_time);
                else
                    trans_val = (segment_transition_time - i) ...
                        / segment_transition_time;
                end
                one_mixer_signal(one_mixer_position + i) = trans_val;
            end
        end
        
        one_mixer_position = one_mixer_position + segment_transition_time;

        % write the echo
        one_mixer_signal(one_mixer_position : one_mixer_position ...
            + segment_length) = watermark_bit;

        one_mixer_position = one_mixer_position + segment_length;

        last_bit = watermark_bit;
    end

    zero_mixer_signal = 1 - one_mixer_signal;
    original_mixer_signal = 1 - (zero_mixer_signal + one_mixer_signal);

    zero_signal = zero_delay_signal .* zero_mixer_signal;
    one_signal = one_delay_signal .* one_mixer_signal;
    original_signal = x .* original_mixer_signal;

    y = zero_signal + one_signal + original_signal;

end

function [processed_wave] = single_echo(wav, Fs, time, decay)
    time = time / 1000;
    h = dfilt.delay(round(time * Fs));
    for d = 1 : size(wav, 2),
        delayed_wav(:, d) = filter(h, wav(:, d));
    end
    processed_wave = wav + (delayed_wav * decay);
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
