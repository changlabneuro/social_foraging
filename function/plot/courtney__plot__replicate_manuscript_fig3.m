function all_stats = courtney__plot__replicate_manuscript_fig3( images, varargin )

params = struct( ...
  'patch_time_thresholds', [100, 5e3], ...
  'modeled', [], ...
  'addScatter', false, ...
  'addJuice', true, ...
  'addModeled', true, ...
  'addRibbon', false, ...
  'allOnOneFigure', true, ...
  'append', [], ...
  'save', false ...
);
params = parsestruct( params, varargin );

modeled = params.modeled;

patch_time_thresholds = params.patch_time_thresholds;
assert( numel(patch_time_thresholds) == 2, 'Specify min + max patch times' );
assert( patch_time_thresholds(1) < patch_time_thresholds(2), ...
  'patch_time_thresholds(1) must be less than patch_time_thresholds(2)' );

if ( isa(images, 'DataObject') )
  images = Container.create_from(images); 
else assert( isa(images, 'Container'), '`images` must be a Container or DataObject' );
end

error_tts = { 'endbatch', 'image_state_maxed_out', 'travelbarselected' };

images = images.remove( error_tts );
monks = unique( images('monkey') );

if ( params.allOnOneFigure )
  figure; hold on;
end

all_stats = Container();

for i = 1:numel(monks)
  monk = images.only( monks{i} );
  %   if we haven't yet calculated patch-res time
  if ( shape(monk, 2) == 3 )
    monk.data = [ monk.data(:,2) - monk.data(:,1) monk.data(:,3) ];
  end
  
  ind = monk.data(:,1) > patch_time_thresholds(1) & ...
    monk.data(:,1) <= patch_time_thresholds(2);
  
  monk = monk(ind);
  assert( ~isempty(monk), 'No data were found within the specified time-bounds' );
  travel_times = monk.data(:,2);
  patch_residence = monk.data(:,1);
  
  legend_items = { 'Observed' };
  
  if ( ~params.allOnOneFigure ), figure; hold on; end;
  if ( params.addScatter), scatter( travel_times, patch_residence ); end;
  
  %   stats
  
  [r,p] = corr( travel_times, patch_residence, 'tail', 'right', 'type', 'Kendall');
  stats_permonk = monk(1);
  
  mdl = fitlm( travel_times, patch_residence/1e3 );
  
  table = cell2table( {r, p, 'right', 'Kendall', size(travel_times,1), ...
    mdl.Coefficients{2, 'Estimate'}, mdl.Coefficients{2, 'pValue'}} );
  table.Properties.VariableNames = { 'r', 'p', 'tail', 'type', 'N', 'Beta', 'BetaP' };
  stats_permonk.data = table;
  all_stats = all_stats.append( stats_permonk );
  
  %   add reg line
  
  p = polyfit( travel_times, patch_residence, 1 );
  unique_tts = unique( travel_times );
  v = polyval( p, unique_tts );
  plot( unique_tts, v, 'b' );
  
  if ( ~isempty(modeled) && params.addModeled )
    current = modeled;
    if ( isa(current, 'DataObject') )
      current = current.only( monks{i} );
      current = current.data{1}.travelTime_vs_patchResidence;
    end
    tt = current.travel_time / 10; pt = current.patch_time * 1e2;
    ind = tt >= min(unique_tts) & tt <= max(unique_tts);
    tt = tt( ind ); 
    pt = pt( ind );
    plot( tt, pt, 'r' );
    legend_items{end+1} = 'Optimal';
  end
  
  if ( params.addJuice );
    ys = repmat( 200, size(unique_tts) );
    xs = unique_tts;
    plot( xs(:), ys(:), 'k' );
    legend_items{end+1} = 'Juice';
  end
  
  if ( params.addRibbon )
    result = fit( travel_times, patch_residence/1e3, 'poly1' );
    predictions = predint( result, unique_tts(:), 0.95, 'functional', 'on' );
    plot( unique_tts(:), predictions(:,1)*1e3, 'b' );
    plot( unique_tts(:), predictions(:,2)*1e3, 'b' );
  end
  
  legend( legend_items );
  
  %   plot styling
  if ( ~params.allOnOneFigure )
    title( monks{i} );
  elseif ( i == numel(monks) )
    title( strjoin(monks, ' ') );
  end
  ylim([0 5e3]);
  xlim([ min(unique_tts)-1 max(unique_tts)+1]);
  if ( ~params.allOnOneFigure || i == 1 )
    yticks = get( gca, 'yticklabels' );
    yticks = cellfun( @(x) str2double(x)/1e3, yticks, 'UniformOutput', false );
    yticks = cellfun( @(x) num2str(x), yticks, 'UniformOutput', false );
    set( gca, 'yticklabel', yticks );
  end
  xlabel( 'Travel time (s)' );
  ylabel( 'Patch residence time (s)' );
  
  if ( params.save )
    if ( params.addRibbon )
      save_str = [monks{i} '_ribbon']; 
    else save_str = [monks{i} '_noribbon'];
    end
    if ( ~isempty(params.append) && i == numel(monks) )
      save_str = [save_str params.append];
    end;
    if ( ~params.allOnOneFigure || i == numel(monks) )
      saveas( gcf, save_str, 'epsc' );
    end
  end
end


end

%     means = zeros( size(unique_tts) );
%     for k = 1:numel(unique_tts)
%       extr = travel_times == unique_tts(k);
%       means(k) = mean( patch_residence(extr) );
%     end
%     means = means / 1e3;  %   match units b/w patch_res and tts
