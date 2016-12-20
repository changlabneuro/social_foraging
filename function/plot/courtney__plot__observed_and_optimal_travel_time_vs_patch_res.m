function courtney__plot__observed_and_optimal_travel_time_vs_patch_res( observed, modeled, varargin )

params = struct( ...
    'minPatchTime', 100, ...
    'maxPatchTime', 15e3, ...
    'juiceTime', 200, ...
    'yLimits', [0 5e3], ...
    'savePlot', false, ...
    'plotSubfolder', '121916' ...
);
params = parsestruct( params, varargin );

observed = observed.remove( {'endbatch', 'image_state_maxed_out', 'travelbarselected' } );

x_modeled = modeled.travel_time;
y_modeled = modeled.patch_time;

x_observed = observed.data(:,3);
y_observed = observed.data(:,2) - observed.data(:,1);

y_observed = y_observed( y_observed >= params.minPatchTime & y_observed <= params.maxPatchTime );
x_observed = x_observed( y_observed >= params.minPatchTime & y_observed <= params.maxPatchTime );

%   match units

y_observed = y_observed ./ 1000;

x_modeled = x_modeled ./ 10; y_modeled = y_modeled ./ 10;

juice_time = params.juiceTime ./ 1000;

%   regress

x_pad = ones( numel(x_observed), 1 );
x_observed = [ x_pad(:) x_observed(:) ];

regressed = x_observed \ y_observed;
observed_slope = regressed(2); observed_intercept = regressed(1);

figure; hold on;
plot( x_modeled, y_modeled );
plot( x_modeled, (x_modeled .* observed_slope) + observed_intercept ); 
plot( x_modeled, repmat( juice_time, 1, numel(x_modeled) ) );

legend( { 'optimal', 'observed', 'optimal juice' } );

xlim([0 max(x_modeled) + 1]);
ylim( params.yLimits );

if ( ~params.savePlot ), return; end;

filename = fullfile( pathfor('plots'), params.plotSubfolder, 'tt_v_patch_res_observed_v_optimal' );

saveas(gcf, filename, 'epsc' );

end