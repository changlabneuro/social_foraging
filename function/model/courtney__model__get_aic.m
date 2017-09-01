function aics = courtney__model__get_aic( discount, mvt )

discount_aic = zeros( 1, numel(discount) );
mvt_aic = zeros( size(discount_aic) );
tt = zeros( size(discount_aic) );

for i = 1:numel( discount )
  discount_aic(i) = discount{i}.mdl.ModelCriterion.AIC;
  mvt_aic(i) = mvt{i}.mdl.ModelCriterion.AIC;
  tt(i) = discount{i}.travel_time;
end

m1_name = discount{1}.name;
m2_name = mvt{1}.name;

aics.(m1_name) = discount_aic;
aics.(m2_name) = mvt_aic;
aics.travel_time = tt;

end