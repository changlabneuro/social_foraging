function outs = courtney__analysis__tt_v_patchres( observed, modeled, varargin )

params = struct( ...
    'minPatchTime', 100, ...
    'maxPatchTime', 15e3 ...
);
params = parsestruct( params, varargin );

observed = observed.remove( {'endbatch', 'image_state_maxed_out', 'travelbarselected' } );

x_modeled = modeled.travel_time;
y_modeled = modeled.patch_time;

if ( size( observed.data, 2) == 3 )
  x_observed = observed.data(:,3);
  y_observed = observed.data(:,2) - observed.data(:,1);
else
  x_observed = observed.data(:, 2);
  y_observed = observed.data(:, 1);
end

y_observed = y_observed( y_observed >= params.minPatchTime & y_observed <= params.maxPatchTime );
x_observed = x_observed( y_observed >= params.minPatchTime & y_observed <= params.maxPatchTime );

%   match units -> s

y_observed = y_observed ./ 1000;

x_modeled = x_modeled ./ 10; y_modeled = y_modeled ./ 10;

%   regress

[r, p] = corr( x_observed, y_observed );

x_pad = ones( numel(x_observed), 1 );
x_observed = [ x_pad(:) x_observed(:) ];

regressed = x_observed \ y_observed;
observed_slope = regressed(2); observed_intercept = regressed(1);

tt.modeled = x_modeled;
patchres.modeled = y_modeled;

tt.observed = x_observed;
patchres.observed = y_observed;

%   calculate observed mean

tts = unique( x_observed(:,2) );

means = layeredstruct( {{ 'tt', 'mean', 'sem' }}, zeros( 1, numel(tts) ) );

for i = 1:numel(tts)
  extr = y_observed( x_observed(:,2) == tts(i) );
  
  means.tt(i) = tts(i);
  means.mean(i) = mean( extr );
  means.sem(i) = SEM( extr );
  
end

outs.correlations.observed = [r, p];
outs.means.observed = means;
outs.slopes.observed = observed_slope;
outs.intercepts.observed = observed_intercept;
outs.tt = tt;
outs.patchres = patchres;

end