function fits = courtney__model__mvt( measure, varargin )

params = struct( ...
    'k', .2, ...
    'x0', 13, ...
    'showPlots', true ...
);
params = parsestruct( params, varargin );

fastest_time = 2.4;
patch_times = 0:.1:150;
travel_times = [10 30 50 70];

%   intake function

L = max( measure );

x_plot = 1:length( measure );
non_adjusted = L ./ (1 + exp( -params.k .* (x_plot - params.x0)));
y_shift = non_adjusted(1);

%   calculate best parameters

%   get best parameters -- new fit

% function_expression = sprintf( ...
%     '(%f+%f)/(1+exp(-k*(x-x0)))-%f', L, y_shift, y_shift);
% 
function_expression = sprintf( ...
    '(%f)./(1+exp(-k.*(x-x0)))', L );

fit_model = fittype( function_expression, 'coefficients', { 'k', 'x0' } );

%   new method

logit_measure = [-fliplr(measure) measure];
fit_xs = -(patch_times(end)-1):patch_times(end);
[curve, ~] = fit( fit_xs', logit_measure(:), fit_model );

% [curve, ~] = fit( (1:length(measure))', measure(:), fit_model );


k = curve.k; 
x0 = curve.x0;


% y_shift = curve.b;
% k = params.k; x0 = params.x0;

%   plug parameteres into g();
% g = @(x) L ./ ( 1 + exp( -k .* (x - x0) ) );

% g = @(x) ( L ) ./ ( 1 + exp(-k.*(x - x0)) ) - y_shift;

g = @(x) ( L+y_shift ) ./ ( 1 + exp(-k.*(x - x0)) ) - y_shift;

intake = courtney__model__log_intake( measure );
g = intake.func;



%   polyfit method

n_coefficients = 3;

current_coeff = n_coefficients;

p = polyfit( x_plot, measure, n_coefficients );

for i = 1:n_coefficients+1
    if ( i == 1 )
        func_expression = sprintf('p(1).*x_plot.^%d', current_coeff); 
        current_coeff = current_coeff - 1;
        continue; 
    end;
    
    if ( i == n_coefficients+1 )
        func_expression = sprintf('%s + p(%d)', func_expression, i ); continue;
    end
    
    func_expression = sprintf('%s + p(%d).*x_plot.^%d', func_expression, i, current_coeff );
    current_coeff = current_coeff - 1;
end

%   polyfit

% g = eval( sprintf('@(x_plot) %s', func_expression) );

% plot( x_plot, eval( func_expression ) ); hold on; plot( measure );

%   test params

plot( x_plot, g(x_plot), 'r' ); hold on; plot( measure, 'b' );
set(gca, 'xticklabel', {'0', '5', '10','15'}); xlabel('Seconds');
legend({'Logistic approximation', 'Observed'}); ylabel( 'Cumulative summed fix counts' );

%   model

n_simulations = 1;

%   preallocate

mean_rate = zeros( length( patch_times ),length( travel_times ) );

for j = 1:length( travel_times );
    travel_time = travel_times(j);

    for k = 1:length( patch_times )  %   loop for each patch time

    patch_r_time = patch_times( k ); %   pulling out one time, for example ...

    rate = zeros( 1,n_simulations );
    
    store_gT = zeros( size( rate ) );
    
    for i = 1:n_simulations

        gT = g(patch_r_time);

        rate(i) = gT/( patch_r_time + travel_time );
        store_gT(i) = gT;

    end
    
    mean_rate(k,j) = mean( rate );

    end
    
end

shift_times = zeros( length(patch_times), length(travel_times) );
for k = 1:length( travel_times );
    shift_times(:,k) = patch_times + travel_times(k);
end

max_rate = zeros( 1, size(mean_rate, 2) );
x_coord = zeros( size( max_rate ) );

for k = 1:size(mean_rate,2);

[max_rate(k),maxInd] = max(mean_rate(:,k));
x_coord(k) = maxInd-1;

end

if ( x_coord(1) == 0 )
    x_coord(1) = 1; fprintf('\nWARN: Substituted 1 for 0');
end

%   find slope

fits.travelTime_vs_patchResidence.travel_time = travel_times;
fits.travelTime_vs_patchResidence.rate = patch_times( x_coord );

%   find relationship between 'optimal' leaving time for juice vs.

adjusted = repmat( fastest_time, 1, numel( travel_times ) );
adjusted = mean( [ patch_times( x_coord );adjusted ] );

X = [ ones(numel(travel_times), 1) travel_times' ];

travel_time_vs_patchResidence = X \ patch_times( x_coord )';
adjusted_for_juice = X \ adjusted';

fits.travelTime_vs_patchResidence.intercept = travel_time_vs_patchResidence(1);
fits.travelTime_vs_patchResidence.slope =  travel_time_vs_patchResidence(2);

fits.travelTime_vs_patchResidenceAdjusted.intercept = adjusted_for_juice(1);
fits.travelTime_vs_patchResidenceAdjusted.slope = adjusted_for_juice(2);



%   plotting section

if ( ~params.showPlots ); return; end;

%   1c

figure;
for k = 1:size( mean_rate, 2 );

hold on;
oneTravelTime = mean_rate(:,k);

plot(0:length(oneTravelTime)-1,mean_rate(:,k));

end

hold on;

%   add max-rate to 1c

plot(x_coord,max_rate,'k','Linewidth',2);

labels = cell(1,length(travel_times));
for i = 1:length(travel_times);
    labels{i} = num2str(travel_times(i)/10);
end

d = length(labels);
labels{d+1} = 'Max Rate';
legend(labels,'location','northeast');

xlabel('Time in patch (s)');
ylabel('Reward harvest rate');

%   set limit

% ylim([0 25]);

%   end set limit


x_labels = get(gca,'xTickLabel'); new_x_labels = cell(1,length(x_labels));
for i = 1:length(x_labels);
    if length(x_labels{i}) < 4
        new_x_labels{i} = x_labels{i}(~strcmp(x_labels{i},'0'));
    else
        new_x_labels{i} = x_labels{i}(1:2);
    end
end
set(gca,'xTickLabel',new_x_labels);

%   fig 2a

figure;
travel_times = travel_times/10; patch_times = patch_times/10;

plot( travel_times,patch_times(x_coord) );

ylim([0 max(patch_times)]);
xlim([0 max(travel_times)+travel_times(1)]);

legend('Optimal');
ylabel('Time in patch (s)');
xlabel('Travel time (s)');

end


%   plot binned looking time


%   labeling


% current_labels = get(gca,'xTickLabel');
% new_labels = cell(1,length(current_labels));
% for i = 1:length(current_labels);
%     if ~strcmp(current_labels{i},'0') && i < length(current_labels)
%         new_labels{i} = num2str(travel_times(i-1)/10);
%     elseif strcmp(current_labels{i},'0')
%         new_labels{i} = '0';
%     else
%         new_labels{i} = num2str((max(travel_times) + travel_times(1))/10);
%     end
% end
% 
% 
% set(gca,'xTickLabel',new_labels);
% 
% current_labels_y = get(gca,'yTickLabel');
% 
% new_labels_y = cell(1,length(current_labels_y));
% for i = 1:length(current_labels_y);
%     if ~strcmp(current_labels_y{i},'0')
%         if length(current_labels_y{i}) == 2
%             new_labels_y{i} = current_labels_y{i}(~strcmp(current_labels_y{i},'0'));
%         else
%             new_labels_y{i} = current_labels_y{i}(1:2);
%         end
%     else
%         new_labels_y{i} = '0';
%     end
% end
% 
% set(gca,'yTickLabel',new_labels_y);


% L = max( measure );
% k = .2; %Lager and Kuro
% %k = 0.15; %Jodo
% % x0 = 10; %Kuro
% % x0 = 17; %Jodo
%  x0 = 13; %Lager


function best = determine_best_parameters( observed )

observed_area = sum( observed );

k = .1;
x0 = 13;
x_plot = 1:length( observed );
L = max( observed );

n_repititions = 100;

bests = cell( 1, n_repititions );

for i = 1:n_repititions
    bests{i} = one_loop( observed_area, L, k, x0, x_plot );
end

ks = cellfun( @(x) x.k, bests );
x0s = cellfun( @(x) x.x0, bests );
differences = cellfun( @(x) x.difference, bests );

min_diff = min( differences );
min_diff_index = min( find( differences == min_diff ) );

best.k = ks( min_diff_index );
best.x0 = x0s( min_diff_index );

end

function bests = one_loop( observed_area, L, k, x0, x_plot )

step_resolution.k = .1;
step_resolution.x0 = .1;

bests.difference = Inf;
bests.k = k;
bests.x0 = x0;

n_repititions = 10e3;

for i = 1:n_repititions
    
    if ( rand() > .5 )
        k = k + step_resolution.k;
        x0 = x0 + step_resolution.x0;
    else
        k = k - step_resolution.k;
        x0 = x0 - step_resolution.k;
    end
    
    non_adjusted = L ./ ( 1 + exp( -k .* (x_plot - x0)) );
    
    y_shift = non_adjusted(1);
    
    g = @(x) ( L+y_shift ) ./ ( 1 + exp(-k.*(x - x0)) ) - y_shift;
    
    modeled_area = sum( g( x_plot ) );
    
    difference = abs( modeled_area - observed_area );
    
    if ( difference >= bests.difference )
        continue;
    end
    
    bests.difference = difference;
    bests.k = k;
    bests.x0 = x0;
    
end


end