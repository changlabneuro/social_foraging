function courtney__plot__observed_and_optimal_travel_time_vs_patch_res( inputs, varargin )

params = struct( ...
    'yLimits', [0 5], ...
    'savePlot', false, ...
    'plotSubfolder', '121916', ...
    'juiceTime', 200, ...
    'plotModeled', true, ...
    'title', [], ...
    'addSEM', false, ...
    'predictionBounds', true ...
);
params = parsestruct( params, varargin );

x_modeled = inputs.tt.modeled;
y_modeled = inputs.patchres.modeled;

observed_intercept = inputs.intercepts.observed;
observed_slope = inputs.slopes.observed;

observed_func = @(x) x.*observed_slope + observed_intercept;

juice_time = params.juiceTime ./ 1000;

figure; hold on;

legend_items = { 'optimal', 'observed', 'optimal juice' };

if ( params.plotModeled )
    plot( x_modeled, y_modeled );
else legend_items(1) = [];
end

if ( params.predictionBounds )
  means = inputs.means.observed;
  result = fit( means.tt(:), means.mean(:), 'poly1' );
  prediction = predint( result, means.tt(:), 0.95, 'functional', 'on' );
  for i = 1:numel(x_modeled)
    ind(i) = find( means.tt == x_modeled(i) );
  end
  
  new_func = @(x) result.p1 .* x + result.p2;
  
  predictions = prediction(ind, :);
  plot( means.tt(ind), new_func( means.tt(ind) ), 'r' );
  plot( means.tt(ind), predictions(:,1), 'k' );
  plot( means.tt(ind), predictions(:,2), 'k' );
  
end

if ( params.addSEM )
  means = inputs.means.observed;
%   ind = zeros(1, numel(x_modeled));
%   for i = 1:numel(x_modeled)
%     ind(i) = find( means.tt == x_modeled(i) );
%   end
%   means.tt = means.tt(ind);
%   means.mean = means.mean(ind);
%   
  mdl = fitlm(means.tt(:), means.mean(:));
  mdl__intercept = table2array(mdl.Coefficients(1,1));
  mdl__slope = table2array(mdl.Coefficients(2,1));
  func = @(x) x.*mdl__slope + mdl__intercept;
  
  ind = [ 2 6 10 11 ];
  means.tt = means.tt(ind);
  
  ys = func( means.tt(:) );
  plot( means.tt(:), ys );
  hold on;
  plot( means.tt(:), ys + mdl.RMSE );
  plot( means.tt(:), ys - mdl.RMSE );
else
%   plot( x_modeled, (x_modeled .* observed_slope) + observed_intercept );  
end

plot( x_modeled, repmat( juice_time, 1, numel(x_modeled) ) );

legend( legend_items );

xlim([0 max(x_modeled) + 1]);
ylim( params.yLimits );

if ( ~isempty(params.title) ), title( params.title ); end;

if ( ~params.savePlot ), return; end;

filename = fullfile( pathfor('plots'), params.plotSubfolder, 'tt_v_patch_res_observed_v_optimal' );

saveas(gcf, filename, 'epsc' );

end