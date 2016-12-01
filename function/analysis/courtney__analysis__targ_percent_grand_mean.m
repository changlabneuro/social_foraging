function store_percents = courtney__analysis__targ_percent_grand_mean( orders )

total_patches = orders.count( 1 );    %   same as size( orders.data, 1 )

monkeys = orders.uniques( 'monkeys' );

multiply_fields = { 'neg', 'pos' };
std_fields = { 'negVar', 'posVar' };

weights = struct(); percents = struct();

for i = 1:numel( monkeys )
    monk = orders.only( monkeys{i} );
    weight = monk.count( 1 ) / total_patches;
    
    percent = targPercent( monk.data );
    
    for k = 1:numel( multiply_fields )
        percent.( multiply_fields{k} )(1,:) = percent.( multiply_fields{k} )(1,:) * weight;
    end
    
    weights.( monkeys{i} ) = weight;
    percents.( monkeys{i} ) = percent;
end

first_loops = layeredstruct( { std_fields }, true );

for i = 1:numel( monkeys )
    for k = 1:numel( std_fields )
        one_field = percents.( monkeys{i} ).( std_fields{k} );
        
        if ( first_loops.( std_fields{k} ) )
            first_loops.( std_fields{k} ) = false;
            all_fields.( std_fields{k} ) = one_field; continue;
        end
        
        all_fields.( std_fields{k} ) = all_fields.( std_fields{k} ) + one_field;
        
    end
end

variances = structfun( @(x) sqrt( x / numel(monkeys) ), all_fields, 'UniformOutput', false );

first_monk = monkeys{1}; monkeys(1) = [];

store_percents = percents.( first_monk );

for i = 1:numel( monkeys )
    for k = 1:numel( multiply_fields )
        current = percents.( monkeys{i} ).( multiply_fields{k} );
        
        store_percents.( multiply_fields{k} )(1,:) = ...
            store_percents.( multiply_fields{k} )(1,:) + current(1,:);
        store_percents.( multiply_fields{k} )(2,:) = ...
            store_percents.( multiply_fields{k} )(2,:) + variances.( [ multiply_fields{k} 'Var' ] );
        store_percents.( multiply_fields{k} )(3,:) = ...
            store_percents.( multiply_fields{k} )(3,:) - variances.( [ multiply_fields{k} 'Var' ] );
    end
end

figure;
plot_targ_percent( store_percents );


end


function old_code()

%%%
store_means_jodo_wt = store_means_jodo;
store_means_lager_wt = store_means_lager;
store_means_kuro_wt = store_means_kuro;

%%% weight each one
total_patches = (n_valid_patches_jodo + n_valid_patches_kuro + n_valid_patches_lager);
lager_wt = (n_valid_patches_lager / total_patches); 
jodo_wt = (n_valid_patches_jodo / total_patches);
kuro_wt = (n_valid_patches_kuro / total_patches);

%%% make a product store_means with grand mean and sem
store_means_jodo_wt.pos(1,:) = (jodo_wt * store_means_jodo.pos(1,:));
store_means_jodo_wt.neg(1,:) = (jodo_wt * store_means_jodo.neg(1,:));
store_means_kuro_wt.pos(1,:) = (kuro_wt * store_means_kuro.pos(1,:));
store_means_kuro_wt.neg(1,:) = (kuro_wt * store_means_kuro.neg(1,:));
store_means_lager_wt.pos(1,:) = (lager_wt * store_means_lager.pos(1,:));
store_means_lager_wt.neg(1,:) = (lager_wt * store_means_lager.neg(1,:));

%%% take a mean of variances and sqrt to get std deviation

intermediate_std_deviation_pos = sqrt((store_means_jodo_wt.posVar + store_means_lager_wt.posVar...
    + store_means_kuro_wt.posVar)/3);
intermediate_std_deviation_neg = sqrt((store_means_jodo_wt.negVar + store_means_lager_wt.negVar...
    + store_means_kuro_wt.negVar)/3);


grand_mean.pos(1,:) = store_means_jodo_wt.pos(1,:) + store_means_lager_wt.pos(1,:) + store_means_kuro_wt.pos(1,:);
grand_mean.pos(2,:) = grand_mean.pos(1,:) + intermediate_std_deviation_pos;
grand_mean.pos(3,:) = grand_mean.pos(1,:) - intermediate_std_deviation_pos;

grand_mean.neg(1,:) = store_means_jodo_wt.neg(1,:) + store_means_lager_wt.neg(1,:) + store_means_kuro_wt.neg(1,:);
grand_mean.neg(2,:) = grand_mean.neg(1,:) + intermediate_std_deviation_neg;
grand_mean.neg(3,:) = grand_mean.neg(1,:) - intermediate_std_deviation_neg;

end