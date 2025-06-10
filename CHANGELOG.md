# Changelog

## v0.3.0

* Backwards incompatible changes
  * Styling functions can modify pretty much everything and layer themselves on
    other styles. If you created a custom style, check out the built-in styles
    for how to update.

* New features
  * Support multi-line cell data. This works in all built-in styles and includes
    color support. The `:markdown` style will convert new lines to `<br>` tags
    to render as you'd expect.
  * Add `usage-rules.md` to help LLMs especially with ansidata. See
    [usage_rules](https://hex.pm/packages/usage_rules).

* Changes
  * Match `Kino.DataFrame` semantics better with the default formatter. This
    notably improves date and time formatting.
  * Improve width calculations so that automatically expanding columns better
    match the terminal width
  * Significantly improve test coverage

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
