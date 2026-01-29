# Contributing to rGoldETF

Thank you for your interest in contributing to rGoldETF!

## How to Contribute

### Reporting Bugs

- Check if the bug has already been reported in Issues
- If not, create a new issue with a clear description and reproducible example

### Suggesting Features

- Open an issue describing the feature and its use case
- Discuss with maintainers before implementing

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Run tests (`devtools::test()`)
5. Run R CMD check (`devtools::check()`)
6. Commit your changes (`git commit -m 'Add your feature'`)
7. Push to the branch (`git push origin feature/your-feature`)
8. Open a Pull Request

### Code Style

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use roxygen2 for documentation
- Write tests for new functions

### Development Setup

```r
# Install development dependencies
install.packages(c("devtools", "testthat", "roxygen2", "knitr", "rmarkdown"))

# Load the package for development
devtools::load_all()

# Run tests
devtools::test()

# Build documentation
devtools::document()

# Run R CMD check
devtools::check()
```

## Team Members

- Xuanrui Qiu
- Yaojun Liu
- Ruochen Yang
