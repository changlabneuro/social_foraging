function [mvts, discounts, only_r_term, only_t_terms] = ...
  courtney__model__sci_rev( measures, images, varargin )

params = struct( ...
    'binResolution', 100, ...
    'travelTimes', [], ...
    'minimumPatchTime', 200, ...
    'maximumPatchTime', 5e3, ...
    'patchStart', 100, ...
    'patchEnd', 15e3, ...
    'mvtYLims', [], ...
    'ddYLims', [], ...
    'format', 'epsc', ...
    'showPlots', true, ...
    'SAVE', false, ...
    'filenames', [] ...
);
params = parsestruct( params, varargin );

%   keep only fully completed, valid trials

images = images.remove({ 'endbatch', 'image_state_maxed_out', 'travelbarselected' } );

%   get the unique travel times present in the object

% travel_times = str2double( images.uniques('travelTime') );
travel_times = [ 1 3 5 7 ];

%   overwrite these with the ones inputted in <params> if they exist

if ( ~isempty(params.travelTimes) ), travel_times = params.travelTimes; end;

%   get the cumulative summed looking time 

psth = courtney__analysis__fix_psth( measures, params.binResolution );

binned = psth.binned;

% figure; hold on;

mvts = cell( 1, numel(travel_times) );
discounts = cell( 1, numel(travel_times) );
only_r_term = cell( size(mvts) );
only_t_terms = cell( size(mvts) );

for i = 1:numel( travel_times )
  [mvts{i}, discounts{i}, only_r_term{i}, only_t_terms{i}] = ...
    model_per_travel_time__no_valence_term( binned, travel_times(i), images, params );
  if ( ~params.showPlots ), continue; end;
%   plot__mvt( mvts{i}, travel_times(i), params );
%   plot__discount( discounts{i}, travel_times(i), params );
%   plot__combined( mvts{i}, discounts{i}, travel_times(i), params );
  %   plot all;
  tt = travel_times(i);
  filenames = params.filenames;
  combined = [mvts(i), discounts(i), only_r_term(i), only_t_terms(i)];
  plot__mult( combined, tt, filenames.combined, params );
  %   plot each individually
  plot__mult( mvts(i), tt, filenames.mvt, params );
  plot__mult( discounts(i), tt, filenames.discount, params );
  plot__mult( only_r_term(i), tt, filenames.only_r_term, params );
  plot__mult( only_t_terms(i), tt, filenames.only_t_terms, params );
end

% legend( images.uniques('travelTime') );

end

%{

      PLOT

%}


function plot__mvt( mvt, travel_time, params )
figure;
% plot( mvt.log_response, 'r' ); hold on; plot( mvt.fitted, 'b' );
plot( mvt.response, 'r' ); hold on; plot( mvt.fitted, 'b' );
% ylabel( 'log( p_l_e_a_v_e / (1-p_l_e_a_v_e))' ); 
ylabel( 'p_l_e_a_v_e' );
xlabel('time(s)'); 
% set(gca, 'xticklabel', {'0','5','10','15'});
legend( {'observed', 'estimated'} );
title( sprintf('Travel time: %f', travel_time) );

if ( ~isempty(params.mvtYLims) ), ylim( params.mvtYLims ); end;
if ( ~params.SAVE ), return; end;
if ( exist(params.filenames.mvt, 'dir') ~= 7 ); mkdir( params.filenames.mvt ); end;

tt = round( travel_time*1000 );

filename = fullfile( params.filenames.mvt, sprintf('tt__%dms', tt) );
saveas( gcf, filename, params.format );
close gcf;

end

function plot__discount( discount, travel_time, params )
figure;

plot( discount.estimated ); hold on; plot( discount.observed );

% log_estimate = log( discount.estimated ./ (1-discount.estimated) );
% log_observed = log( discount.observed ./ (1-discount.observed) );

% plot( 1:numel( discount.estimated ), log_estimate ); 
% hold on; 
% plot( log_observed );
legend( {'Estimated', 'Observed'} );
title( sprintf('Travel time: %f', travel_time) );
% ylabel( 'log( p_l_e_a_v_e / (1-p_l_e_a_v_e))' );
ylabel( 'p_l_e_a_v_e' );
xlabel('time(s)'); 
% set(gca, 'xticklabel', {'0','5','10','15'});

if ( ~isempty(params.mvtYLims) ), ylim( params.mvtYLims ); end;
if ( ~params.SAVE ), return; end;
if ( exist(params.filenames.discount, 'dir') ~= 7 ); mkdir( params.filenames.discount); end;

tt = round( travel_time*1000 );
filename = fullfile( params.filenames.discount, sprintf('tt__%dms', tt) );
saveas( gcf, filename, params.format );
close gcf;

end

function plot__combined( mvt, discount, travel_time, params )

figure; hold on;
plot( discount.observed, 'k' );
plot( discount.estimated, 'r' );
plot( mvt.fitted, 'b' );

legend( {'Observed', 'Discount', 'MVT'} );
ylabel( 'p_l_e_a_v_e' );
xlabel('time(s)'); 
% set(gca, 'xticklabel', {'0','5','10','15'});
title( sprintf('Travel time: %f', travel_time) );

if ( ~isempty(params.mvtYLims) ), ylim( params.mvtYLims ); end;
if ( ~params.SAVE ), return; end;
if ( exist(params.filenames.combined, 'dir') ~= 7 ); mkdir( params.filenames.combined); end;

tt = round( travel_time*1000 );
filename = fullfile( params.filenames.combined, sprintf('tt__%dms', tt) );
saveas( gcf, filename, params.format );
close gcf;

end

function plot__mult( models, travel_time, folder, params )

figure(1); 
clf();
hold on;
names = cell( size(models) );
for i = 1:numel(models)
  mdl = models{i};
  if ( i == 1 )
    observed = mdl.observed;
    plot( observed, 'k' );
  end
  plot( mdl.fitted );
  names{i} = mdl.name;
end

names = cellfun( @(x) strrep(x, '_', ' '), names, 'un', false );

legend( [{'Observed'}, names(:)'] );
ylabel( 'p_l_e_a_v_e' );
xlabel('time(s)'); 
title( sprintf('Travel time: %f', travel_time) );

if ( ~isempty(params.mvtYLims) ), ylim( params.mvtYLims ); end;
if ( ~params.SAVE ), return; end;
if ( exist(folder, 'dir') ~= 7 ); mkdir( folder ); end;

tt = round( travel_time*1000 );
filename = fullfile( folder, sprintf('tt__%dms', tt) );
saveas( gcf, filename, params.format );
close gcf;

end



%{


    R VARIANTS

  
%}


%{
    r delay discount
%}


function discount = r__delay_discount( binned, travel_time, p_leave_pdf )

binned = binned / max(binned);

r_path = fullfile( pathfor('court'), 'function', 'model', 'r' );
tmp_path = fullfile( r_path, 'tmp' );
csvwrite( fullfile(tmp_path, 'tmp__binned.csv'), binned(:) );
csvwrite( fullfile(tmp_path, 'tmp__p_leave_pdf.csv'), p_leave_pdf(:) );

r_script_name = fullfile( r_path, 'courtney__delay_discount__get_aic.R' );

command = sprintf( 'Rscript ''%s'' ''%s'' %f', r_script_name, tmp_path, travel_time );

[~, out] = system( command );

brackets = strfind( out, '[1]' );

assert( numel(brackets) == 4, ...
  'Too many or too few outputs were returned from the Rscript' );

i = 1; outs = cell( 1, numel(brackets) );
while ( i < numel(brackets) )
  outs{i} = out( brackets(i)+4:brackets(i+1)-1 ); i = i + 1;
end
outs{end} = out( brackets(end)+4:end );
outs = cellfun( @str2double, outs );

discount.mdl.ModelCriterion.AIC = outs(1);
discount.mdl.LogLikelihood = outs(3);
discount.RMSE = outs(4);
discount.k = outs(2);
discount.func = @(x, k, t) binned ./ (1+discount.k*t);
discount.travel_time = travel_time;
discount.estimated = discount.func( binned, discount.k, travel_time );
discount.observed = p_leave_pdf;


% outs{1} = out( brackets(1)+4:brackets(2)-1 );
% outs{2} = out( brackets(2)+4:brackets(3)-1 );
% outs{3} = out( brackets(3)+4:end );

end







%{

      NO VALENCE TERM

%}







function [mvt, discount, only_r_term, only_t_terms] = model_per_travel_time__no_valence_term( binned, travel_time, images, params )

extracted_times = images.only( num2str(travel_time) );
patch_res = extracted_times.data(:,2) - extracted_times.data(:,1);

%%%%    OLD METHOD

patch_res = patch_res( patch_res > params.minimumPatchTime );
patch_res = patch_res( patch_res <= params.maximumPatchTime );

times = (params.binResolution):(params.binResolution):(params.maximumPatchTime);
binned = binned(1:params.maximumPatchTime/100);

ind = find( times == params.minimumPatchTime );
times = times(ind:end); binned = binned(ind:end);
assert( numel(times) == numel(binned), 'Mismatch in number of elements between sums and times' );

%%%%    END OLD METHOD

%%%%% BEGIN NEW METHOD

% patch_res = patch_res( patch_res > params.patchStart & patch_res <= params.patchEnd );
% times = (params.binResolution):(params.binResolution):(params.patchEnd);

%%%%% END NEW METHOD

p_leave = zeros( 1, numel(times) );

for i = 1:numel( times )
    p_leave(i) = perc( patch_res < times(i) ) / 100;
end

p_leave_pdf = zeros( size(p_leave) );

for i = 2:numel( times )
  p_leave_pdf(i) = perc( patch_res > times(i-1) & patch_res <= times(i) ) / 100;
end

%%%%% BEGIN NEW METHOD

% ind = find( times >= params.minimumPatchTime & times <= params.maximumPatchTime );
% times = times(ind); 
% binned = binned(ind); 
% p_leave = p_leave(ind); 
% p_leave_pdf = p_leave_pdf(ind);
% assert( numel(times) == numel(binned), 'Mismatch in number of elements between sums and times' );

%%%%% END NEW METHOD

%   mvt glm model

% mvt.log_response = log( p_leave ./ (1-p_leave) );
mvt.log_response = log( p_leave_pdf ./ (1-p_leave_pdf) );
% mvt.response = p_leave;
mvt.response = p_leave_pdf;
mvt.rewards = binned;
mvt.n = times;
mvt.n2 = mvt.n .^ 2;
mvt.travel_time = travel_time;
mvt.name = 'mvt';
mvt.observed = mvt.response;

fit_params.dist = 'normal';
% fit_params.response = mvt.log_response(:);
fit_params.response = mvt.response;
fit_params.response( isinf(fit_params.response) ) = NaN;

mvt.coefficient_names = { 'intercept', 'reward', 'time', 'timeSq' };
mvt.mdl = fitglm( ...
    [mvt.rewards(:) mvt.n(:) mvt.n2(:)], fit_params.response, ...
    'distribution', fit_params.dist );
mvt.b = table2array( mvt.mdl.Coefficients(:,1) );

mvt.fitted = mvt.b(1) + (mvt.b(2) .* mvt.rewards(:)) + (mvt.b(3) .* mvt.n(:)) + ...
    (mvt.b(4) .* mvt.n2(:));

residuals = mvt.mdl.Residuals{:,'Raw'};
  
mvt.RMSE = sqrt( sum((residuals.^2 ./ numel(residuals))) );

%   discount model

discount = r__delay_discount( binned, travel_time, p_leave_pdf );
discount.fitted = discount.estimated;
discount.name = 'discount';

%   only_r_term

only_r_term = mvt;
only_r_term.name = 'only_r_term';
only_r_term.coefficient_names = { 'intercept', 'reward' };
only_r_term.mdl = fitglm( only_r_term.rewards(:), fit_params.response ...
  , 'distribution', fit_params.dist );
coeffs = table2array( only_r_term.mdl.Coefficients(:,1) );
fitted = coeffs(1) + (coeffs(2) .* only_r_term.rewards(:));
only_r_term.fitted = fitted;

%   only_t_terms

only_t_terms = mvt;
only_t_terms.name = 'only_t_terms';
only_t_terms.coefficient_names = { 'intercept', 'time', 'timeSq' };
only_t_terms.mdl = fitglm( [only_t_terms.n(:), only_t_terms.n2(:)] ...
  , fit_params.response, 'distribution', fit_params.dist );
B = table2array( only_t_terms.mdl.Coefficients(:,1) );
fitted = B(1) + (B(2) .* only_t_terms.n(:)) + (B(3) .* only_t_terms.n2(:));
only_t_terms.fitted = fitted;

return;

% %   old
% 
% k = 1.2;
% sigma = .1;
% 
% cumulative = binned(1);
% % cumulative = sum( binned );
% % cumulative = sum( binned ); cumulative = cumulative ./ max(cumulative);
% % normalized = binned ./ sum(binned);
% 
% discount.rewards.leave = repmat( cumulative, 1, numel(binned) );
% 
% discount.rewards.stay = zeros( size(discount.rewards.leave) );
% for i = 1:numel( binned )
%     discount.rewards.stay(i) = cumulative - sum(binned(1:i));
% end
% 
% % discount.rewards.stay = binned ./ 1e3;
% % discount.rewards.stay = binned ./ max(binned);
% discount.rewards.stay = binned;
% 
% discount.v.leave = discount.rewards.leave ./ (1 + k*travel_time);
% discount.v.stay = discount.rewards.stay;
% 
% discount.exponential_component = exp( discount.v.leave - discount.v.stay ) ./ sigma;
% 
% discount.likelihood = discount.exponential_component ./ (1 + discount.exponential_component);
% 
% 
% plot(p_leave); hold on; plot(discount.likelihood); disp(discount.likelihood);

end

function discount = model__dd(binned, travel_time, p_leave_pdf)

normalized = binned ./ max(binned);
next_patch_rwd = normalized(1);

fit_function = ...
    sprintf( ...
    'exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ) ./ (1 + exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ))', ...
next_patch_rwd, travel_time, travel_time, next_patch_rwd, travel_time, travel_time);

func = eval( sprintf('@(x, k, sigma) %s', fit_function) );

% phat = mle( p_leave_pdf, 'pdf', func, 'start', [-100 -100] );

d = 10;






end


%{
    implement a delay discount model
%}



function discount = model__delay_discounting(binned, travel_time, p_leave)

binned = binned ./ max(binned); 

%   cumulative is a bit of a misnomer -- it's really the largest reward in
%   the next patch

% cumulative = max( binned );
cumulative = binned(1);
% cumulative = sum( binned ) ./ numel(binned)/10;

fit_function = ...
    sprintf( ...
    'exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ) ./ (1 + exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ))', ...
cumulative, travel_time, travel_time, cumulative, travel_time, travel_time);

fit_model = fittype( fit_function, 'coefficients', { 'k', 'sigma' } );

[curve, ~] = fit( (1:numel(p_leave))', p_leave(:), fit_model, 'lower', [0 0], 'upper', [.5 .5] );

k = curve.k;
sigma = curve.sigma;

if ( any( [k == .5, sigma == .5] ) ), warning('k was .5'); end;

updated_func = sprintf( ...
    'exp( (%f./(1 + %f.*%f ) - x./(1 + %f.*%f) ) ./ %f ) ./ (1 + exp( (%f./(1 + %f.*%f ) - x./(1 + %f.*%f) ) ./ %f ))', ...
cumulative, k, travel_time, k, travel_time, sigma, cumulative, k, travel_time, k, travel_time, sigma);
updated_func = eval( ['@(x)' updated_func] );

updated_binned = binned ./ sum(binned);

stay = zeros( size(binned) );
for i = 1:numel( binned )
    stay(i) = cumulative - sum(updated_binned(1:i));
end

stay = binned;

a = updated_func( stay );

% figure;
% plot( 1:numel(a), a ); hold on; plot( p_leave );
% legend( {'Estimated', 'Observed'} );

%%%%

%%%%

test__mle = eval( ['@(x, k, sigma)' fit_function] );
phat = mle( p_leave, 'pdf', test__mle, 'start', [-0.1, -0.1] );
phat = mle( binned, 'pdf', test__mle, 'start', [.1, .1]);
loglik = sum( log( test__mle( binned, phat(1), phat(2) ) ) );
aic = 2*2 - (2*log( loglik ));

if ( isnan(loglik) )
    error( 'loglik was NaN' );
end

discount.phat = phat;
discount.loglik = loglik;
discount.aic = aic;
discount.estimated = a;
discount.observed = p_leave;


end


function [mvt, discount] = model_per_travel_time__with_valence_term( binned, travel_time, images, params )

images = images.only( num2str( travel_time ) );

valences = images.uniques( 'valence' );

time = []; rewards = [];

binned = binned( 1:params.maximumPatchTime/100 );

for i = 1:numel( valences )
    time = [time params.binResolution: params.binResolution: params.maximumPatchTime];
    rewards = [rewards(:); binned(:)];
end

valence = zeros( size(time) );
p_leave = zeros( size(time) ); 
stp = 1;

all_patch_res = images.data(:,2) - images.data(:,1);
all_patch_res = all_patch_res( all_patch_res > params.minimumPatchTime & all_patch_res <= params.maximumPatchTime );

for i = 1:numel( valences )
    
    switch valences{i}
        case 'neg'
            val = 0;
        case 'pos'
            val = 1;
        otherwise
            error( 'Unrecognized valence ''%s''', valences{i} );
    end
    
    times = images.only( valences{i} );
    
    patch_res = times.data(:,2) - times.data(:,1);
    patch_res = ...
        patch_res( patch_res > params.minimumPatchTime & patch_res <= params.maximumPatchTime );
    
    for k = 1:( numel( time ) / numel(valences))
        p_leave(stp) = perc( patch_res < time(k) ) / 100;
%         p_leave(stp) = perc( all_patch_res < time(k) ) / 100;
        valence(stp) = val;
        stp = stp + 1;
    end
        
end

%   get p_leave irrespective of valence

all__p_leave = zeros( 1, numel(time)/numel(valences) );

for i = 1:numel( time ) / numel(valences)
    all__p_leave(i) = perc( all_patch_res < time(i) ) / 100;
end

%   mvt glm model

mvt.log_response = log( p_leave ./ (1-p_leave) );
mvt.response = p_leave;
mvt.rewards = rewards;
mvt.n = time;
mvt.n2 = mvt.n .^ 2;
mvt.valences = valence;
mvt.travel_time = travel_time;

% [mvt.b, mvt.dev, mvt.stats] = glmfit( ...
%     [mvt.rewards(:) mvt.n(:) mvt.n2(:) mvt.valences(:)], mvt.response(:), 'binomial' ...
% );

mvt.mdl = fitglm( ...
    [mvt.rewards(:) mvt.n(:) mvt.n2(:) mvt.valences(:)], mvt.response(:), ...
    'distribution', 'binomial' );

mvt.b = table2array( mvt.mdl.Coefficients(:,1) );

mvt.fitted = mvt.b(1) + (mvt.b(2) .* mvt.rewards(:)) + (mvt.b(3) .* mvt.n(:)) + ...
    (mvt.b(4) .* mvt.n2(:)) + (mvt.b(5) .* mvt.valences(:));


% model__delay_discounting( binned, travel_time, 

end

% 
% function test__mle( data, params )
% 
% d = 10;
% 
% end


% fit_function = sprintf(...
%         '(exp( (%f/(1+k*%f) - %f ) / sigma )) / (1 + (exp( (%f/(1+k*%f) - %f) ) / sigma ))', ...
%         cumulative_sum, travel_time, remaining_reward, cumulative_sum, travel_time, remaining_reward );
%     
%     fit_model = fittype( fit_function, 'coefficients', { 'k', 'sigma' } );