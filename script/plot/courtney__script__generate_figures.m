OPTS = struct();

OPTS.SAVE = true;
OPTS.MAX_PATCH_TIME = 5e3;
OPTS.SUBFOLDER = '010307_5s';
OPTS.FIGS = { '1c' };
OPTS.ADD_SEM = false;

OPTS = struct2varargin( OPTS );

courtney__generate_figures( processed, OPTS{:} );