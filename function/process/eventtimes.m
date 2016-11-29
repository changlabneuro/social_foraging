%{

    eventtimes.m -- function for scanning voltage traces to create an index
    of where in the LFP trace each <eventname> occurred. 

%}

function times = eventtimes(neural, eventnames)

if nargin < 2
    eventnames = cell( 1, size(neural,2) );
    for i = 1:numel(eventnames)
        eventnames{i} = ['ev' num2str(i)];
    end
end

%   ensure each channel is properly labeled / accounted for

assert(numel(eventnames) == size(neural, 2), ['Each column in <neural> must' ...
    , ' contain an analog input voltage trace, and correspond to an eventname in' ...
    , ' <eventnames>']);

pulse_length = 100; %   ms - how long the arduino pulse lasts
threshold = 4.5e3;  %   mV

index = 1:size(neural, 1);

for i = 1:numel(eventnames)
    channel = neural(:,i);
    
    pulses = channel > threshold;
    firsts = [false; diff(pulses) == 1];
    
    times.( eventnames{i} ) = index(firsts);
end

%   make sure that no event times occur within <pulse_length> ms of one
%   another, which is impossible, and therefore an error in the threshold
%   detection

for i = 1:numel(eventnames)
    assert( all( diff(times.(eventnames{i})) >= pulse_length ) , ...
        'Some pulses may have been coded inaccurately');
end

end