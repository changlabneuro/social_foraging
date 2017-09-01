basepath = fullfile( pathfor('excel_raw_data'), '010717' );
monks = dirstruct( basepath, 'folders' );
monks = { monks(:).name };
labs = cell( size(monks) );
orders = cell( size(monks) );
measures = Container();

for i = 1:numel(monks)
  fullpath = fullfile( basepath, monks{i}, 'valence' );
  labs{i} = getFiles( fullpath );
  orders{i} = targOrder( labs{i} );
  measure = courtney__analysis__targ_percent( orders{i} );
  measure = measure.require_fields( 'monkey' );
  measure( 'monkey' ) = monks{i};
  measures = measures.append( measure );
  
  %   plot
  courtney__plot__targ_percent( measure );
  folder = fullfile( pathfor('plots'), '071217', 'behavior' );
  if ( exist(folder, 'dir') ~= 7 ), mkdir( folder ); end;
  filename = fullfile( folder, monks{i} );
  saveas( gcf, filename, 'epsc' );
  saveas( gcf, filename, 'png' );
end

%%

psth = courtney__analysis__fix_psth( separated, 100 );
figure(1);
clf();
plot( 0:.1:14.9, psth.meaned );
ylim( [0, 1] );
ylabel( 'Mean fixation rate' );
xlabel( 'Time in patch (s)' );
filename = fullfile( folder, 'fig1' );
saveas( gcf, filename, 'epsc' );


