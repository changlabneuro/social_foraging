function courtney__plot__targ_percent( obj )

means = obj.only( 'mean' );
devs = obj.only( 'sem' );

means = means.for_each( 'valence', @mean );
devs = devs.for_each( 'valence', @mean );

[neg_means, neg_devs] = get_means_devs( means, devs, 'neg' );
[pos_means, pos_devs] = get_means_devs( means, devs, 'pos' );

figure(1);
h = gobjects(1, 2);
clf();
hold on;
h(1) = plot( neg_means, 'r' );
plot( neg_devs', 'r' );
h(2) = plot( pos_means, 'b' );
plot( pos_devs', 'b' );

legend( h, {'negative', 'positive'} );
title( strjoin(obj('monkey'), '_' ) );

ylim( [0, 1] );
xlim( [1, 8] );

end

function [means, devs] = get_means_devs( means, devs, valence )

means = means.only( valence );
devs = devs.only( valence );

means = means.data;
devs = devs.data;
devs = [means+devs; means-devs];

end