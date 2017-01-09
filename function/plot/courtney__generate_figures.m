function courtney__generate_figures(processed, varargin)

OPTS = struct( ...
  'SAVE', false, ...
  'SUBFOLDER', '010307', ...
  'FIGS', {{ '1ab', '1c' }}, ...
  'MAX_PATCH_TIME', 15e3, ...
  'ADD_SEM', false ...
);

OPTS = parsestruct( OPTS, varargin );

redefined_blocks = processed;

redefined_blocks = ...
  redefined_blocks.replace( {'block__valence', 'block__color_control'}, 'block__val_color' );
redefined_blocks = redefined_blocks.replace( 'nonsocial', 'scrambled' );

monks = redefined_blocks.looking_duration.uniques( 'monkey' );
blocks = redefined_blocks.looking_duration.uniques( 'blocktype' );

% separate per monk

separators = { allcomb({monks, blocks}) };

% add collapsed across monk

separators = [ separators {blocks} ];

for i = 1:numel(separators)
  current_separators = separators{i};
  for j = 1:size(current_separators, 1)
    separator = current_separators(j, :);
    separated = redefined_blocks.only( separator );
    
    store.block = separated.looking_duration.uniques( 'blocktype' );
    store.monkeys = separated.looking_duration.uniques( 'monkey' );
    
    if ( any(strcmp(store.block, 'block__val_color')) )
      imagetypes = separated.looking_duration.uniques( 'valence' );
    else imagetypes = separated.looking_duration.uniques( 'social' );
    end
    
    for k = 1:numel(imagetypes)
      
      store.imagetype = imagetypes(k);
      
      forsaving = store;
      
      forsaving = structfun( @(x) strjoin(x, '_'), forsaving, 'UniformOutput', false );
    
      full_savepath = fullfile( OPTS.SUBFOLDER, forsaving.block, ...
        forsaving.monkeys, forsaving.imagetype );
    
      path_to_test_existence = fullfile( pathfor('plots'), full_savepath );
    
      if ( exist(path_to_test_existence, 'dir') ~= 7 ), mkdir( path_to_test_existence ); end;
      
      further_separated = separated.only( imagetypes{k} );
      
      %   fig 1a. 1b.

      analyses.psth = courtney__analysis__fix_psth( further_separated, 100 );

      analyses.fits = courtney__model__mvt( analyses.psth.summed, ...
        'binnedMeasure', analyses.psth.binned, ...
        'savePlots', OPTS.SAVE, ...
        'plotSubfolder', full_savepath, ...
        'showPlots', any( strcmp(OPTS.FIGS, '1ab') ) ...
      );
      
      %   fig 1c.
      
      if ( any(strcmp(OPTS.FIGS, '1c')) )
      
        analyses.fits.tt_observed = courtney__analysis__tt_v_patchres( ...
          further_separated.images, analyses.fits.travelTime_vs_patchResidence, ...
          'maxPatchTime', OPTS.MAX_PATCH_TIME );

        courtney__plot__observed_and_optimal_travel_time_vs_patch_res( ...
          analyses.fits.tt_observed, ...
          'yLimits', [0 5], ...
          'savePlot', OPTS.SAVE, ...
          'plotModeled', true, ...
          'title', [], ...
          'plotSubfolder', full_savepath, ...
          'addSEM', OPTS.ADD_SEM ...
        );    
      
      end

      if ( OPTS.SAVE ), close all; end;
    
    end
  end
end

end

