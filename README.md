DEPENDENCIES
=====

Most of the functionality depends on an external repository, accessible via https://github.com/nfagan/global.

This external resource contains a Matlab object called a DataObject, which is a data-structure
that houses trial `data` (stored row-wise) and trial `labels` (stored row-wise). Data are saved natively as
DataObjects, and use of the `global` repository is required to load our processed .mat files.
