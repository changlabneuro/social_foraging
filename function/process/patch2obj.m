function [obj, out_fields] = patch2obj(folder)

ignorefields = { 'wasRewarded', 'errorBatchEnd', 'errorTargetNotSelected' };

patches = getall(folder, ignorefields);

allfields = fieldnames(patches);

excludes = {'colorOrder'}; excludes = [excludes ignorefields];

%   get rid of fields in excludes

for i = 1:numel(excludes)
    allfields( strcmp(allfields, excludes{i}) ) = [];
end

%   get data fields

datafields = allfields( ...
    cellfun(@(x) ~isempty(strfind(lower(x),'time')), allfields) ...
    );

%   add non 'time' containing fields

datafields = [ datafields; {'travelDelayDuration'} ];

%   label fields are allfields except datafields

for i = 1:numel(datafields)
    allfields( strcmp(allfields, datafields{i}) ) = [];
end

labelfields = allfields;

%   get data

data = zeros( size(patches.(datafields{1}),1), numel(datafields) );

for i = 1:numel(datafields)
    data(:,i) = patches.(datafields{i});
end

%   get labels

mapping = struct(...
    'targetColor', 'color', ...
    'targetNumber', 'target', ...
    'imageValence', 'valence', ...
    'errorTravelBarNotSelected', 'TBerr', ...
    'errorTargetNotSelected', 'TGerr', ...
    'errorBatchEnd', 'BEerr', ...
    'patchN', 'patch', ...
    'trialN', 'trial', ...
    'session', 'session' ...
);

labels = struct();

for i = 1:numel(labelfields)
    current = patches.(labelfields{i})(:,1);
    
    if iscell(current)
        nonstr = cellfun( @ischar, current );
        current(~nonstr) = {'na'};
        labels.(labelfields{i}) = current;
        continue;
    end
    
    cellcurrent = cell( size(current) );
    
    for j = 1:numel(current)
        cellcurrent{j} = [ mapping.(labelfields{i}) '_' num2str(current(j)) ];
    end
    
    labels.(labelfields{i}) = cellcurrent;
end

obj = DataObject(data, labels);

%{
    cleanup
%}

obj = obj.renamefield('targetColor', 'colors');
obj = obj.renamefield('targetNumber', 'numbers');
obj = obj.renamefield('imageValence', 'valences');
obj = obj.renamefield('imageFileName', 'filenames');
% obj = obj.renamefield('errorTravelBarNotSelected', 'err');
obj = obj.renamefield('session', 'sessions');

obj = obj.replace('valence_1', 'negative');
obj = obj.replace('valence_2', 'positive');
obj = obj.replace('valence_0', 'na');

out_fields.data = datafields;
out_fields.labels = labelfields;

end

function allpatches = getall(folder, fields_to_ignore)

mats = dirstruct(folder, '.mat');

for i = 1:length(mats)
    patch = load( fullfile(folder, mats(i).name) ); 
    
    try
        patch = patch.output_patch;
    catch
        patch = patch.ans;
    end
    
    patch = formatpatch( patch );
    
    if ( i == 1 )
        fields = fieldnames(patch);
        
        for k = 1:numel( fields_to_ignore )
            fields( strcmp(fields, fields_to_ignore{k}) ) = [];
        end
        fields = [ fields; {'session'} ];
    end;
    
    %   add session ids / other per-file meta-data
    
    session = parsesession( mats(i).name );
    
    patch.session = repmat( {session}, size(patch.patchStartTime, 1), 1 );
    
    if ( i == 1 ); allpatches = patch; continue; end;
    
    current_patch_fields = fieldnames( patch );
    one_field = current_patch_fields{ 1 };
    
    for j = 1:numel( fields )
        if ~( any( strcmp( current_patch_fields, fields{j} ) ) )
            patch.( fields{j} ) = zeros( size( patch.( one_field ), 1 ), ...
                size( allpatches.( fields{j} ), 2 ) );
        end
    end
    
    for j = 1:numel(fields)
        current = allpatches.(fields{j});
        updated = [current; patch.(fields{j})];
        allpatches.(fields{j}) = updated;
    end
    
end

% allpatches = rmfield(allpatches, 'wasRewarded');
% allpatches = rmfield(allpatches, 'errorBatchEnd');
% allpatches = rmfield(allpatches, 'errorTargetNotSelected');

end

function session = parsesession(filename)

period = strfind(filename,'.');
underscore = max(strfind(filename,'_'));

if ( isempty(period) || isempty(underscore) )
    error(['The file format has changed -- could not find an underscore or period in' ...
        , ' %s'], filename);
end

session = filename(underscore+1:period-1);

end