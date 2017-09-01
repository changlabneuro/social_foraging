goto( 'processed_data' ); cd( './010317' );
load( 'processed.mat' );
processed = courtney__add_day_labels( processed );
processed = processed.foreach( @courtney__fix_day_labels );
processed = processed.replace( 'neg', 'negative' );
processed = processed.replace( 'pos', 'positive' );

%%
BLOCK = 'social';
VALENCE = 'positive';

%%  delay discount

separators = { ['block__' BLOCK] };
% separators = { 'block__social' };

% separate_images = raw.excel_images.images.only( separators );

separated = processed.only( separators );
separate_images = separated.images;

base_filename = fullfile( pathfor('plots'), ['071017/model/%s/' BLOCK] );
model_names = { 'mvt', 'discount', 'only_r_term', 'only_t_terms', 'combined' };
filenames = struct();

for i = 1:numel(model_names);
  filenames.(model_names{i}) = sprintf( base_filename, model_names{i} );
end

% courtney__model__delay_discounting

[mvt_fit, discount_fit, only_r_term_fit, only_t_terms_fit] = ...
  courtney__model__sci_rev( separated, separate_images, ...
    'showPlots', false, ...
    'mvtYLims', [-.0005 .1], ...
    'SAVE', false, ...
    'filenames', filenames ...
  );

analyses.fits.mvts = mvt_fit;
analyses.fits.discount = discount_fit;
analyses.fits.only_r_term = only_r_term_fit;
analyses.fits.only_t_terms = only_t_terms_fit;

analyses.aics.aic = cellfun( @(x) x.mdl.ModelCriterion.AIC, analyses.fits.mvts );
analyses.aics.tt = cellfun( @(x) x.travel_time, analyses.fits.mvts );
%%  MODEL SUMMARY

tbls1 = courtney__model__summary( analyses.fits.discount, analyses.fits.mvts );
tbls2 = courtney__model__summary( analyses.fits.discount, analyses.fits.only_r_term );
tbls3 = courtney__model__summary( analyses.fits.discount, analyses.fits.only_t_terms );

tbls2.only_r_term = tbls2.mvt; tbls2 = rmfield( tbls2, 'mvt' ); 
tbls2 = rmfield( tbls2, 'discount' );
tbls3.only_t_terms = tbls3.mvt; tbls3 = rmfield( tbls3, 'mvt' ); 
tbls3 = rmfield( tbls3, 'discount' );

tbls = structconcat( tbls1, tbls2, tbls3 );

glm_fits = rmfield( analyses.fits, 'discount' );
glm_fit_tbls = structfun( @courtney__model__coefficient_summary, glm_fits, 'un', false );

filename = fullfile( pathfor('analyses'), '071017', 'tables', BLOCK );
if ( exist(filename, 'dir') ~= 7 ), mkdir(filename); end;
fs = fieldnames(tbls);
for i = 1:numel(fs)
  writetable( tbls.(fs{i}), fullfile(filename, [fs{i} '__table.csv']) );
end

glm_fs = fieldnames( glm_fit_tbls );
for i = 1:numel(glm_fs)
  fit_tbl = glm_fit_tbls.(glm_fs{i});
  writetable( fit_tbl, fullfile(filename, [glm_fs{i} '__regression_table.csv']) );
end

%%  GET APPROPRIATE WEIGHTS

tbl = courtney__model__summary2( analyses.fits.mvts );


%% PLOT AIC

aics = courtney__model__get_aic( analyses.fits.discount, analyses.fits.mvts );
aics = courtney__model__get_aic( analyses.fits.mvts, analyses.fits.only_r_term );
weights = courtney__model__get_ak_weights( aics );
%   plot aics
courtney__plot__aic( aics, ...
  'savePath', fullfile(pathfor('plots'), ['071017/model/aics/whole_session/' BLOCK]), ...
  'SAVE', true, 'yAxisLocation', 'right', 'yLim', [] );
%%   plot weights
courtney__plot__ak_weights( weights, aics, ... 
  'savePath', fullfile(pathfor('plots'), ['071017/model/weights/whole_session/' BLOCK]), ...
  'SAVE', true, 'plotRelative', true );

%%  REVISION AIC PLOTS

fnames = fieldnames( analyses.fits );
% C = combnk( fnames, 2 );
C = { 'only_r_term', 'discount' };
C(2, :) = { 'only_t_terms', 'discount' };
for i = 1:size(C, 1)
  name1 = C{i, 1};
  name2 = C{i, 2};
  fit1 = analyses.fits.(name1);
  fit2 = analyses.fits.(name2);
  fit1{1}.name = name1;
  fit2{1}.name = name2;
  aic1 = courtney__model__get_aic2( fit1 );
  aic2 = courtney__model__get_aic2( fit2 );
  
  weights = ...
    courtney__model__get_ak_weights2( aic1.(name1), aic2.(name2), name1, name2 );
  
  %   plot actual aics
  courtney__plot__aic( aic1, aic2, ...
    'savePath', fullfile(pathfor('plots'), ['071117/model/aics/whole_session/' BLOCK]), ...
    'SAVE', true, 'yAxisLocation', 'right', 'yLim', [-325, -275] );
  
  %   plot relative weights
  courtney__plot__ak_weights( weights, aic1.travel_time, name1, name2, ... 
    'savePath', fullfile(pathfor('plots'), ['071117/model/weights/whole_session/' BLOCK]), ...
    'SAVE', true, 'plotRelative', true, 'yLim', [10e-8, 10e8] );
end

%%  REVISION AIC WEIGHTS

fnames = fieldnames( analyses.fits );
aics = cell( size(fnames) );

for i = 1:numel(fnames)
  [aics{i}, tt] = courtney__model__get_aic_basic( analyses.fits.(fnames{i}) );
end

[weights, d_aics] = courtney__model__get_ak_weights_mult( aics{:} );

C = combnk( fnames, 2 );
C(end+1, :) = { 'only_r_term', 'discount' };
C(end+1, :) = { 'only_t_terms', 'discount' };
for i = 1:size(C, 1)
  name1 = C{i, 1};
  name2 = C{i, 2};
  
  weight1 = weights( strcmp(fnames, name1), : );
  weight2 = weights( strcmp(fnames, name2), : );
  
  weights_ = struct( 'weights', struct('relative', weight1./weight2) );
  
  %   plot relative weights
  courtney__plot__ak_weights( weights_, tt, name1, name2, ... 
    'savePath', fullfile(pathfor('plots'), ['071217/model/weights/whole_session/' BLOCK]), ...
    'SAVE', true, 'plotRelative', true, 'yLim', [10e-8, 10e8] );
end

first_row = arrayfun( @(x) ['travelTime_' num2str(x)], tt, 'un', false );
first_row{end+1} = 'modelName';
weights_tbl = arrayfun( @(x) {x}, weights );
weights_tbl(:, end+1) = fnames;
weights_tbl = cell2table( weights_tbl );
weights_tbl.Properties.VariableNames = first_row;

save_folder = fullfile( pathfor('analyses'), '071217', 'tables', BLOCK );
if ( exist(save_folder, 'dir') ~= 7 ), mkdir( save_folder ); end;
writetable( weights_tbl, fullfile(save_folder, 'weights.csv') );

%% PLOT AIC DIFFERENCE OVER TIME

[aics, weights] = courtney__model__aic_difference_over_time( separated );
courtney__plot__aic_over_time( aics, ...
  'savePath', fullfile(pathfor('plots'), ['042117/model/aics/over_time/' BLOCK]), ...
  'SAVE', true );
courtney__plot__ak_weights_over_time( weights, aics, ...
  'savePath', fullfile(pathfor('plots'), ['042117/model/weights/over_time/' BLOCK]), ...
  'SAVE', true );

%% AIC OVER TIME REVISION

[weights, ids, tt] = courtney__model__aic_difference_over_time_rev( separated );

for i = 1:size(ids, 1)
  courtney__plot__ak_weights_over_time_rev( weights{i}, tt, ids(i, :) ...
    , 'SAVE', true ...
    , 'savePath', fullfile(pathfor('plots'), ['071117/model/weights/over_time']) ...
    , 'yLim', [10e-5, 10e3] ...
    );
end

%%  mvt

% separators = { 'block__social', 'nonsocial' };
% separators = { 'block__valence', 'block__color_control' };
% separators = { 'block__valence', 'block__color_control' };
% separators = { 'block__valence', 'block__color_control', 'jodo' };
% separators = { 'block__social', 'lager', 'expression__na' };

separators = { ['block__' BLOCK] };

separated = processed.only( separators );
  
analyses.psth = courtney__analysis__fix_psth( separated, 100 );
    
analyses.fits = courtney__model__mvt( analyses.psth.summed, ...
  'intakeFunction', 'empirical', ...
  'binnedMeasure', analyses.psth.binned, ...
  'savePlots', true, ...
  'showPlots', true, ...
  'plotSubfolder', '071217/fig1/valence' );

%%  new intake f(x)

analyses.psth = courtney__analysis__look_proportion( separated.proportion, 100 );
figure;
plot( abs(1-analyses.psth.binned) );
figure;
plot( -diff(analyses.psth.binned) );

%%  1c

% separate_images = raw.excel_images.images.only( separators );
separate_images = processed.images.only( separators );

analyses.fits.tt_observed = courtney__analysis__tt_v_patchres( ...
    separate_images, analyses.fits.travelTime_vs_patchResidence, ...
    'maxPatchTime', 15e3 );

courtney__plot__observed_and_optimal_travel_time_vs_patch_res( ...
    analyses.fits.tt_observed, ...
    'yLimits', [0 5], ...
    'savePlot', false, ...
    'plotModeled', true, ...
    'addSEM', false, ...
    'title', [], ...
    'plotSubfolder', '121916/valence/negative' );
%% REPLICATE 

blocks = { 'valence', 'color_control' };
valences = { 'negative', 'positive' };
C = allcomb( {blocks, valences} );
C(end+1, :) = { 'social', 'social' };
C(end+1, :) = { 'social', 'nonsocial' };

C(:, 2) = { 'all' };

for j = 1:size(C, 1)
  BLOCK = C{j, 1};
  VALENCE = C{j, 2};

  if ( strcmp(VALENCE, 'all') )
    separators = { ['block__' BLOCK] };
  else
    separators = { ['block__' BLOCK], VALENCE };
  end
  
  separated = processed.only( separators );

  separated = separated.collapse( 'monkey' );

  monks = separated.images.uniques( 'monkey' );
  sep = separated.images;
  psths = DataObject();
  for i = 1:numel(monks)
    labels.monkeys = monks(i);
    current = separated.only( monks{i} );
    data = courtney__analysis__fix_psth( current, 100 );
    data = courtney__model__mvt( data.summed, ...
      'intakeFunction', 'empirical', 'binnedMeasure', data.binned, ...
      'savePlots', false, 'showPlots', false ...
    );
    psths = psths.append( DataObject( {data}, labels ) );
  end

  stats = courtney__plot__replicate_manuscript_fig3( sep.remove({'0.5', '9'}) ...
    , 'modeled', psths, 'allOnOneFigure', true ...
    , 'addRibbon', true, 'save', true ...
    , 'saveFolder', fullfile(pathfor('plots'), '071217', 'behavior') ...
    , 'append', ['_' BLOCK '_' VALENCE] );

  filename = fullfile( pathfor('analyses'), '071217', 'tables', BLOCK );
  if ( exist(filename, 'dir') ~= 7 ), mkdir( filename ); end;
  filename = fullfile( filename, VALENCE );
  writetable( stats.data, filename );
end

%%  bootstrapped intercept comparison
separators = { ['block__' BLOCK] };
separated = processed.only( separators );
sep = separated.images;
selector1 = 'social';
selector2 = 'nonsocial';
category = 'social';
n_perms = 1e3;

p = courtney__model__intercept_permutation_test( sep, ...
  selector1, selector2, category, n_perms );

%%  sliding window slope comparison

separators = { 'block__valence', 'lager' };

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

analyses.sliding_slope = courtney__analysis__sliding_window_slope( ...
    separated, separate_images, 'resolution', .1 );

ys = analyses.sliding_slope.intercepts.observed;
xs = 1:numel( ys ); xs = xs'; xs = [ones(size(xs)) xs];

%   make fractional to optimal

ys = ys / (analyses.fits.travelTime_vs_patchResidence.intercept/10);

[r, p] = corr( xs(:,2), ys(:) );
fits = xs \ ys(:);
intercept = fits(1);
slope = fits(2);

figure;
plot( xs(:,2), (xs(:,2) .* slope) + intercept ); hold on;
% plot( analyses.sliding_slope.intercepts.observed );
plot( ys );

% plot( analyses.sliding_slope.weights );
% plot( analyses.sliding_slope.slopes.observed );

%%  bootstrapped sliding slope

analyses.bootstrap = courtney__analysis__sliding_slope_bootstrap( ...
    separated, separate_images, ...
    'sampleLevel', 'withinSessionPortion', ...
    'iterations', 20 ...
);

%%  sliding window slope per session

separators = { 'block__color_control', 'lager' };

separated = processed.only( separators );
separate_images = raw.excel_images.images.only( separators );

courtney__analysis__sliding_window_slope_per_session( separated, separate_images );
