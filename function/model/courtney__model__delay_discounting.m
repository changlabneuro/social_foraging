function [mvts, discounts] = courtney__model__delay_discounting( measures, images, varargin )

params = struct( ...
    'binResolution', 100, ...
    'travelTimes', [], ...
    'minimumPatchTime', 100, ...
    'maximumPatchTime', 5e3 ...
);
params = parsestruct( params, varargin );

%   keep only fully completed, valid trials

images = images.remove({ 'endbatch', 'image_state_maxed_out', 'travelbarselected' } );

%   get the unique travel times present in the object

travel_times = str2double( images.uniques('travelTime') );

%   overwrite these with the ones inputted in <params> if they exist

if ( ~isempty(params.travelTimes) ), travel_times = params.travelTimes; end;

%   get the cumulative summed looking time 

psth = courtney__analysis__fix_psth( measures, params.binResolution );

binned = psth.binned;

% figure; hold on;

mvts = cell( 1, numel(travel_times) );
discounts = cell( 1, numel(travel_times) );

for i = 1:numel( travel_times )
%     model_per_travel_time__with_valence_term( binned, travel_times(i), images, params );
    [mvts{i}, discounts{i}] = model_per_travel_time__no_valence_term( binned, travel_times(i), images, params );
end

% legend( images.uniques('travelTime') );

d = 10;

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


function [mvt, discount] = model_per_travel_time__no_valence_term( binned, travel_time, images, params )

extracted_times = images.only( num2str(travel_time) );
patch_res = extracted_times.data(:,2) - extracted_times.data(:,1);

patch_res = patch_res( patch_res > params.minimumPatchTime );
patch_res = patch_res( patch_res <= params.maximumPatchTime );

times = (params.binResolution):(params.binResolution):(params.maximumPatchTime);
binned = binned(1:params.maximumPatchTime/100);

assert( numel(times) == numel(binned), 'Mismatch in number of elements between sums and times' );

p_leave = zeros( 1, numel(times) );

for i = 1:numel( times )
    p_leave(i) = perc( patch_res < times(i) ) / 100;
end

%   mvt glm model

mvt.log_response = log( p_leave ./ (1-p_leave) );
mvt.response = p_leave;
mvt.rewards = binned;
mvt.n = times;
mvt.n2 = mvt.n .^ 2;
mvt.travel_time = travel_time;

% [mvt.b, mvt.dev, mvt.stats] = glmfit( ...
%     [mvt.rewards(:) mvt.n(:) mvt.n2(:)], mvt.response(:), 'binomial' ...
% );

mvt.mdl = fitglm( ...
    [mvt.rewards(:) mvt.n(:) mvt.n2(:)], mvt.response(:), ...
    'distribution', 'binomial' );
mvt.b = table2array( mvt.mdl.Coefficients(:,1) );

mvt.fitted = mvt.b(1) + (mvt.b(2) .* mvt.rewards(:)) + (mvt.b(3) .* mvt.n(:)) + ...
    (mvt.b(4) .* mvt.n2(:));
plot( mvt.log_response, 'r' ); hold on; plot( mvt.fitted, 'b' );

ylabel( 'log( p_l_e_a_v_e / (1-p_l_e_a_v_e))' ); xlabel('time(s)'); set(gca, 'xticklabel', {'0','5','10','15'});
legend( {'observed', 'estimated'} );

%   discount model

discount = model__delay_discounting(binned, travel_time, p_leave);

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


%{
    implement a delay discount model
%}



function discount = model__delay_discounting(binned, travel_time, p_leave)

% cumulative = sum(binned);
% cumulative = 1;
binned = binned ./ max(binned); cumulative = binned(1);

fit_function = ...
    sprintf( ...
    'exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ) ./ (1 + exp( (%f/(1 + k*%f ) - x/(1 + k*%f) ) / sigma ))', ...
cumulative, travel_time, travel_time, cumulative, travel_time, travel_time);

fit_model = fittype( fit_function, 'coefficients', { 'k', 'sigma' } );

[curve, ~] = fit( (1:numel(p_leave))', p_leave(:), fit_model, 'lower', [0 0], 'upper', [10 10] );

k = curve.k;
sigma = curve.sigma;

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

figure;

plot( 1:numel(a), a ); hold on; plot( p_leave );

legend( {'Estimated', 'Observed'} );

%%%%

test__mle = eval( ['@(x, k, sigma)' fit_function] );
phat = mle( p_leave, 'pdf', test__mle, 'start', [-0.1, -0.1] );

phat = mle( p_leave, 'pdf', test__mle, 'start', [-0.1, -0.1] );

loglik = sum( log( test__mle( binned, phat(1), phat(2) ) ) );
% loglik = sum( log( test__mle( 1/10:.1:numel(a)/10 , phat(1), phat(2) ) ) );
aic = 2*2 - (2*log( loglik ));

if ( isnan(loglik) )
    error( 'loglik was NaN' );
end

discount.phat = phat;
discount.loglik = loglik;
discount.aic = aic;


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