function fixdurs = courtney__fix_events_relative_to_image_start(processed, varargin)

params = struct( ...
  'h', 1 ...
);
params = parsestruct( params, varargin );

sessions = processed.fix_events.uniques( 'sessions' );

fixdurs = DataObject();

for i = 1:numel(sessions)
  fprintf( '\nProcessing %d of %d', i, numel(sessions) );
  extr = processed.only( sessions{i} );
  
  ns = extr.fix_events.uniques( 'imageN' );
  
  for j = 1:numel(ns)
    n_extr = extr.only( ns{j} );
    evt = n_extr.fix_events; img = n_extr.images;
    
    img_data = img.data;
    
    assert( size(img_data, 1) == 1, 'More than one image was identified' );
    
    evt = unpack( unpack(evt) );
    evt_data = evt.data;
    
    starts = evt_data(:, 1) - img_data(1);
    ends = evt_data(:, 2) - img_data(1);
    
    end_check = (img_data(2) - evt_data(:, 2)) < 0;
    
    starts( starts < 0 ) = 0;
    ends( end_check ) = img_data(2) - img_data(1);
    
    new_data = [starts, ends-starts];
    
    fixdurs = fixdurs.append( DataObject(new_data, evt.labels) );
  end
end

end