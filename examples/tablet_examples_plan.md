# Tablet Examples Plan

This document outlines a comprehensive set of examples to demonstrate the features of Tablet, a tabular data rendering library for Elixir. These examples will showcase the various capabilities, styles, and customizations available in the library.

## Basic Usage Examples

1. **Simple Table Rendering**
   - Render a basic table with default settings
   - Demonstrate with both map and key-value list data structures

2. **Data Type Handling**
   - Show how Tablet handles different data types (strings, numbers, dates, etc.)
   - Demonstrate handling of special characters and Unicode

3. **Custom Column Headers**
   - Use the formatter function to customize column headers
   - Show multiple ways to format headers

4. **Data Formatting**
   - Format specific columns (like dates, currencies, percentages)
   - Use the formatter function to apply custom formatting to cell values

## Styling Examples

5. **Built-in Styles**
   - Examples of each built-in style:
     - Compact (default)
     - Box
     - Unicode Box
     - Markdown
     - Ledger
   - Comparison of the same data with different styles

6. **Table Titles**
   - Add titles to tables
   - Show how titles appear in different styles

7. **Color and Formatting**
   - Add colors to specific cells or rows
   - Use ANSI formatting (bold, underline, etc.)
   - Mix multiple colors and formatting in a single table

## Layout and Sizing Examples

8. **Column Width Control**
   - Set specific column widths
   - Use different column width strategies:
     - Default
     - Minimum
     - Expand
   - Mix different width strategies in the same table

9. **Multi-line Content**
   - Handle cell content with line breaks
   - Format multi-line content in different styles

10. **Multi-column Wrapping**
    - Demonstrate the wrap_across feature for tables with many rows
    - Show how multi-column wrapping improves readability for certain datasets

## Advanced Examples

11. **Emoji and Unicode Support**
    - Create tables with emojis and special characters
    - Demonstrate proper width calculation for CJK characters

12. **Handling Empty Data**
    - Show how Tablet handles empty datasets
    - Customize empty table appearance

13. **Combining Features**
    - Create complex examples that combine multiple features
    - Show real-world use cases

14. **Large Datasets**
    - Demonstrate performance with larger datasets
    - Show techniques for improving readability with large tables

15. **Custom Styling**
    - Create a custom style function
    - Extend the built-in styles with modifications

## Integration Examples

16. **CLI Application Output**
    - Show how to integrate Tablet in CLI applications
    - Demonstrate conditional styling based on terminal capabilities

17. **File Output**
    - Save table output to files
    - Generate reports with multiple tables

## Data Source Examples

19. **Database Results**
    - Format SQL query results
    - Handle nested data structures

20. **API Data**
    - Format JSON API responses
    - Handle missing fields and inconsistent data

21. **Data Transformation**
    - Transform data before rendering
    - Group and aggregate data

## Implementation Plan

Each example will:
1. Include a descriptive title and explanation
2. Show the source data structure
3. Present the Tablet code to render the table
4. Include expected output and explanation
5. (Where applicable) include variations or alternatives

The examples will be implemented in individual Elixir script files that can be run independently, and will also be consolidated into a comprehensive Examples module that can be included in the documentation.

## File Structure

```
examples/
├── basic/
│   ├── simple_table.exs
│   ├── data_types.exs
│   ├── custom_headers.exs
│   └── data_formatting.exs
├── styling/
│   ├── builtin_styles.exs
│   ├── table_titles.exs
│   └── color_formatting.exs
├── layout/
│   ├── column_width.exs
│   ├── multiline.exs
│   └── multicolumn.exs
├── advanced/
│   ├── emoji_unicode.exs
│   ├── empty_data.exs
│   ├── combined_features.exs
│   ├── large_datasets.exs
│   └── custom_styles.exs
├── integration/
│   ├── cli_output.exs
│   ├── file_output.exs
│   └── livebook_comparison.exs
├── data_sources/
│   ├── database_results.exs
│   ├── api_data.exs
│   └── data_transformation.exs
└── tablet_examples.ex  # Main module consolidating examples
```

This structure allows for easy navigation and reference when implementing the actual examples.
