# Changelog

## v0.2.0

* Backwards incompatible changes
  * Replace `left_trim_pad/2` with more generic `fit_to_width/3` that supports
    left, right, and center alignment in cells for styling.  This only affects
    custom styles.

* Changes
  * Render titles using the `:name` option
  * Add `compute_column_widths/2` to pre-calculate column widths so that they
    can be used across repeated renderings of a table. This prevents column
    widths changing each time.
  * Replace ANSI resets with more specific codes to avoid affecting globally
    applied ANSI features.
  * Fix several edge cases when trimming cell contents
  * Fix width calculations for Japanese text by embedding a very simple port of
    Markus Kuhn's `wcwidth` implementation

## v0.1.0

Initial release to hex.
