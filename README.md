# Interactive Data Visualization App

## Overview
This Shiny app provides an interactive platform for creating publication-quality statistical plots from CSV data. It supports multiple plot types with integrated statistical analysis and customizable visual elements.

## Features
### Plot Types
- **Violin Plot**: Shows data distribution with embedded boxplot
- **Box Plot**: Displays statistical summaries
- **Bar Plot**: Shows means with error bars
- **Scatter Plot**: Displays relationships with trend lines

### Statistical Analysis
- T-test
- Wilcoxon test
- ANOVA
- Kruskal-Wallis test
- Automatic p-value display
- Summary statistics

### Customization Options
- Axis ranges and breaks
- Plot dimensions
- Font sizes
- Color schemes
- Transparency levels
- Plot width and spacing

### Export Options
- High-resolution output (up to 600 DPI)
- Multiple formats (PNG, PDF, TIFF)
- Customizable dimensions
- Publication-ready quality

## Installation

### Prerequisites

install.packages(c("shiny", "ggplot2", "dplyr", "tidyr", "broom", "cowplot", "ggpubr", "ggsignif"))

### Quick Start
1. Clone the repository:
```bash
git clone https://github.com/jaannawaz/Basic-Plots-R.git
```

2. Open in RStudio and run:
```r
shiny::runApp("path/to/app/directory")
```

## Data Format
The application accepts CSV files with the following structure:

```csv
Group,Value1,Value2,...
low,10,20,...
low,15,25,...
middle,20,30,...
middle,25,35,...
high,30,40,...
```

### Requirements:
- First column: Group labels (categorical)
- Subsequent columns: Numeric data
- No missing values in group column
- Consistent data types within columns

## Usage Guide

### 1. Data Upload
- Click 'Browse' to select your CSV file
- Select variables for visualization
- Verify data loading in the preview

### 2. Plot Creation
- Choose desired plot type
- Select appropriate statistical test
- Adjust visual parameters as needed

### 3. Customization
- Set axis ranges and breaks
- Adjust plot dimensions
- Modify colors and transparency
- Configure font sizes

### 4. Export
- Set output dimensions
- Choose resolution (DPI)
- Select file format
- Download the plot

## Examples

### Violin Plot
```r
# Example code for violin plot
ggplot(data, aes(x=Group, y=Value)) +
    geom_violin() +
    geom_boxplot(width=0.2)
```
![Violin Plot Example](path_to_violin_example.png)

### Box Plot
```r
# Example code for box plot
ggplot(data, aes(x=Group, y=Value)) +
    geom_boxplot()
```
![Box Plot Example](path_to_box_example.png)

## Troubleshooting

### Common Issues
1. **Data Loading**
   - Verify CSV format
   - Check for missing values
   - Ensure correct column types

2. **Plot Display**
   - Adjust axis ranges
   - Modify plot dimensions
   - Check group labels

3. **Statistical Analysis**
   - Verify sufficient sample size
   - Check test assumptions
   - Review group comparisons

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Citation
If you use this tool in your research, please cite:
```bibtex

}
```

## Contact
- GitHub: [@jaannawaz](https://github.com/jaannawaz)
- Project Link: [https://github.com/jaannawaz/Basic-Plots-R](https://github.com/jaannawaz/Basic-Plots-R)

## Acknowledgments
- R Core Team
- Shiny Team
- ggplot2 developers
- All contributors
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
