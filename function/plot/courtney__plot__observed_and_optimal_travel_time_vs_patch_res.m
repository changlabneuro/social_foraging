function courtney__plot__observed_and_optimal_travel_time_vs_patch_res( inputs, varargin )

params = struct( ...
    'yLimits', [0 5], ...
    'savePlot', false, ...
    'plotSubfolder', '121916', ...
    'juiceTime', 200, ...
    'plotModeled', true, ...
    'title', [], ...
    'addSEM', false ...
);
params = parsestruct( params, varargin );

x_modeled = inputs.tt.modeled;
y_modeled = inputs.patchres.modeled;

observed_intercept = inputs.intercepts.observed;
observed_slope = inputs.slopes.observed;

juice_time = params.juiceTime ./ 1000;

figure; hold on;

legend_items = { 'optimal', 'observed', 'optimal juice' };

if ( params.plotModeled )
    plot( x_modeled, y_modeled );
else legend_items(1) = [];
end

plot( x_modeled, (x_modeled .* observed_slope) + observed_intercept );
plot( x_modeled, repmat( juice_time, 1, numel(x_modeled) ) );

legend( legend_items );

xlim([0 max(x_modeled) + 1]);
ylim( params.yLimits );

if ( params.addSEM )
  means = inputs.means.observed;
  plot( means.tt, [means.mean + means.sem], 'k' );
  plot( means.tt, [means.mean - means.sem], 'k' );
end

if ( ~isempty(params.title) ), title( params.title ); end;

if ( ~params.savePlot ), return; end;

filename = fullfile( pathfor('plots'), params.plotSubfolder, 'tt_v_patch_res_observed_v_optimal' );

saveas(gcf, filename, 'epsc' );

end