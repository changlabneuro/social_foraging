%{
    formatpatch.m -- function for preprocessing the raw output_patch.mat
    files generated from Courtney's tasks. <patch> is a struct array in
    which each struct in the array corresponds to a given patch.
    <formatted> contains the same data as <patch>, but is a single struct,
    rather than an array of structs; each field in <formatted> is *either*
    a cell array or a matrix
%}

function formatted = formatpatch(patch)

%{
    reformat (see below for more information about what each function does)
%}

patch = fix_image_names(patch);

sizes = getsizes( patch );

patch = fillempties( patch, sizes );
patch = patch_time_wrt_trialn( patch );
patch = appendzeros(patch);
patch = convert_filename_zeros_to_cell(patch);

formatted = patch_concat(patch);
formatted = fillemptycells(formatted);
formatted = addtrialnumber(formatted);
formatted = separate_travel_delay_time(formatted);

%{
    verify
%}

fields = fieldnames(formatted);

for i = 1:numel(fields)
    if ( i == 1 ); currentsize = size( formatted.(fields{i}), 1 ); continue; end;
    
    assert( size(formatted.(fields{i}), 1) == currentsize, ...
        'Not all of the data properly corresponds w/r/t a given trial' );
    
    currentsize = size( formatted.(fields{i}), 1 );
end

end

function sizes = getsizes(patch)

fields = fieldnames(patch);

sizes = layeredstruct({fields}, [0 0]); %   creates a struct with fields in <fields>
                                        %   preallocated with [0 0]

for i = 1:numel( fields )
    for j = 1:length( patch )
        
        if isempty( patch(j).(fields{i}) )
            continue; 
        end
        
        sizes.(fields{i}) = size( patch(j).(fields{i}) );
    end
end

end

%{
    for each empty matrix of each field in <patch>, fill that matrix with
    zeros, according to the number of columns as calculated in getsizes
%}

function patch = fillempties(patch, sizes)

fields = fieldnames(patch);

for i = 1:numel( fields )
    currentsize = sizes.(fields{i});
    for j = 1:length( patch )
        
        if isempty( patch(j).(fields{i}) )
            patch(j).(fields{i}) = zeros(1, currentsize(2));
        end
    end
end

end

%{
    repeat the patch start time for as many trials are there in each patch
%}

function patch = patch_time_wrt_trialn(patch)

for i = 1:length(patch)
    
    patchstart = patch(i).patchStartTime;
    trials = patch(i).trialStartTime;
    
    patchstarts = repmat( patchstart, size(trials,1), 1 );
    patch_n = repmat( i, size(trials,1), 1 );
    
    patch(i).patchStartTime = patchstarts;
    patch(i).patchN = patch_n;
end

end

%{
    convert <patch> from a struct array to a single struct, where each
    field is a matrix or cell array with matching numbers of rows (each
    corresponding to a trial)
%}

function reformatted = patch_concat(patch)

fields = fieldnames(patch);

reformatted = struct();

for i = 1:numel(fields)
    
    onefield = { patch(:).(fields{i}) }';
    onefield = concatenateData( onefield );
    
    reformatted.(fields{i}) = onefield;
end


end

%{
    if the final trial in a patch began, but ended before a data flag
    associated with <field> was submitted, append zero(s) to that <field>
%}

function patch = appendzeros(patch)

fields = fieldnames(patch);

fields = fields( ~strcmp(fields, 'trialStartTime') );

for j = 1:length(patch)
    ntrials = size( patch(j).trialStartTime, 1 ); 
    for i = 1:numel(fields)
        current = patch(j).(fields{i});
        
        if size( current, 1 ) < ntrials
            append = ntrials - size( current, 1 );
            
            if iscell(current)
                current(end+1:end+append,:) = {0};
            else
                current(end+1:end+append,:) = 0;
            end
        end
        
        patch(j).(fields{i}) = current;
    end
end

end

%{
    reformat such that image names are stored column-wise, like every other
    field
%}   

function patch = fix_image_names(patch)

for i = 1:length(patch)
    dimension = size( patch(i).imageFileName );
    if dimension(2) > dimension(1)
        patch(i).imageFileName = patch(i).imageFileName';
    end
end

end

%{
    where there are 0s of type 'double' in patch(i).imageFileName, 
    replace them with {0}
%}

function patch = convert_filename_zeros_to_cell(patch)

for i = 1:length(patch)
    
    if iscell( patch(i).imageFileName ); continue; end;
    
    zeroed = patch(i).imageFileName;
    celled = cell(size(zeroed));
    
    for j = 1:size( zeroed, 1 )
        celled{j} = 0;
    end
    
    patch(i).imageFileName = celled;
    
end

end

%{
    fill empty cells
%}

function patch = fillemptycells(patch)

assert( length(patch) == 1, 'Only fill empty cells after running patch_concat');

fields = fieldnames(patch);

for i = 1:length(fields)
    
    current = patch.(fields{i});
    
    if ( ~iscell( current ) ); continue; end;
    
    empty = cellfun(@isempty, current);
    
    current(empty) = {0};
    
    patch.(fields{i}) = current;
end

end

%{
    add trial number
%}

function patch = addtrialnumber(patch)

assert( length(patch) == 1, 'Only add trial numbers after running patch_concat');
    
trials = patch.trialStartTime;

trialnumber = trials(:,1);
trialstart = trials(:,2);

patch.trialN = trialnumber;
patch.trialStartTime = trialstart;

end

function patch = separate_travel_delay_time(patch)

assert( length(patch) == 1, 'Run after running patch_concat');

delays = patch.travelDelayDuration;

delayamt = delays(:,1);
delaytime = delays(:,2);

patch.travelDelayTime = delaytime;
patch.travelDelayDuration = delayamt;

end