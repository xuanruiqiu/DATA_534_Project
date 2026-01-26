# rGoldETF Test Plan

## Overview

This document describes the testing strategy for the rGoldETF package, synchronized with the 5-day development plan.

## Test File Structure

```
tests/
├── testthat.R                    # Test runner
└── testthat/
    ├── test-day1-api.R           # Day 1: API foundation tests
    ├── test-day2-price.R         # Day 2: Price function tests
    ├── test-day3-technical.R     # Day 3: Technical indicator tests
    ├── test-day4-options-viz.R   # Day 4: Options and visualization tests
    └── test-day5-integration.R   # Day 5: Integration tests
```

## Daily Test Plan

### Day 1 - Test Framework Setup + API Foundation Tests

**Corresponding dev tasks:**
- XuanruiQiu: Package skeleton + DESCRIPTION
- YaojunLiu: api.R core functions
- RuochenYang: Test framework setup

**Test content (`test-day1-api.R`):**
| Test Item | Description | Status |
|-----------|-------------|--------|
| API URL config | Verify API URL can be configured via options | ✅ |
| Missing API key | Throws error when API key is missing | ✅ |
| API key retrieval | Correctly retrieves API key from environment | ✅ |
| Package load | Verify default options are set on package load | ✅ |

---

### Day 2 - Price Function Tests

**Corresponding dev tasks:**
- XuanruiQiu: get_gld_price()
- YaojunLiu: get_gld_history()
- RuochenYang: Unit tests

**Test content (`test-day2-price.R`):**
| Test Item | Description | Status |
|-----------|-------------|--------|
| Date validation | start_date must be before end_date | ✅ |
| Date format | Accepts valid date formats | ✅ |
| Interval parameter | Supports 1d, 1wk, 1mo | ✅ |
| Data structure | Returned data contains required columns | ✅ |
| Data types | Prices are double, volume is integer | ✅ |
| OHLC logic | high >= low | ✅ |

---

### Day 3 - Technical Indicators Tests

**Corresponding dev tasks:**
- XuanruiQiu: get_technical_indicators()
- YaojunLiu: get_options_chain()
- RuochenYang: Documentation

**Test content (`test-day3-technical.R`):**
| Test Item | Description | Status |
|-----------|-------------|--------|
| SMA calculation | Simple moving average calculates correctly | ✅ |
| SMA length | Output length matches input | ✅ |
| EMA calculation | Exponential moving average calculates correctly | ✅ |
| EMA response | EMA responds faster to trends | ✅ |
| RSI range | RSI values are between 0-100 | ✅ |
| RSI trend | RSI > 70 during uptrend | ✅ |
| MACD components | Returns macd, signal, histogram | ✅ |
| MACD calculation | histogram = macd - signal | ✅ |
| Bollinger components | Returns upper, middle, lower | ✅ |
| Bollinger order | upper > middle > lower | ✅ |
| Integration test | get_technical_indicators adds correct columns | ✅ |
| Data preservation | Original data columns preserved | ✅ |
| Row count | Output row count matches input | ✅ |

---

### Day 4 - Options and Visualization Tests

**Corresponding dev tasks:**
- XuanruiQiu: get_implied_volatility()
- YaojunLiu: plot_gld_chart()
- RuochenYang: plot_iv_surface()

**Test content (`test-day4-options-viz.R`):**
| Test Item | Description | Status |
|-----------|-------------|--------|
| Options chain structure | Contains required columns | ✅ |
| Option types | Only call and put | ✅ |
| Bid/Ask | bid <= ask | ✅ |
| IV range | Implied volatility in reasonable range | ✅ |
| IV data structure | Contains required columns | ✅ |
| Days to expiry | Is positive | ✅ |
| plot_gld_chart | Returns ggplot object | ✅ |
| Line chart | Supports line type | ✅ |
| Candlestick chart | Supports candlestick type | ✅ |
| Indicator overlay | Can add SMA/EMA indicators | ✅ |
| Custom title | Supports custom chart title | ✅ |
| plot_iv_surface | Returns ggplot object | ✅ |
| Call IV | Supports call type | ✅ |
| Put IV | Supports put type | ✅ |
| Axis labels | Correct x/y axis labels | ✅ |

---

### Day 5 - Integration Tests and Final Checks

**Corresponding dev tasks:**
- XuanruiQiu: Vignette
- YaojunLiu: README + CI
- RuochenYang: Final tests + check

**Test content (`test-day5-integration.R`):**
| Test Item | Description | Status |
|-----------|-------------|--------|
| Complete workflow | Data -> Indicators -> Chart | ✅ |
| Data consistency | Calculation doesn't modify original data | ✅ |
| Minimal dataset | Handles 5 data points | ✅ |
| Monotonic increase | RSI trends high | ✅ |
| Monotonic decrease | RSI trends low | ✅ |
| High volatility data | Bollinger Bands work correctly | ✅ |
| Exported functions | All functions exist | ✅ |
| Error handling | Invalid input throws errors | ✅ |
| Performance test | 1000 points < 5 seconds | ✅ |

---

## Running Tests

```r
# Run all tests
devtools::test()

# Run specific day's tests
testthat::test_file("tests/testthat/test-day1-api.R")
testthat::test_file("tests/testthat/test-day2-price.R")
testthat::test_file("tests/testthat/test-day3-technical.R")
testthat::test_file("tests/testthat/test-day4-options-viz.R")
testthat::test_file("tests/testthat/test-day5-integration.R")

# Check test coverage
covr::package_coverage()
covr::report()
```

## Coverage Targets

| File | Target Coverage |
|------|-----------------|
| api.R | > 80% |
| price.R | > 80% |
| technical.R | > 90% |
| options.R | > 70% |
| visualization.R | > 80% |
| zzz.R | > 50% |
| **Overall** | **> 80%** |

## Test Types

1. **Unit tests**: Test individual function correctness
2. **Integration tests**: Test multiple functions working together
3. **Edge case tests**: Test extreme input scenarios
4. **Error handling tests**: Verify error messages are clear and useful
5. **Performance tests**: Ensure large dataset processing efficiency

## Notes

- API-related tests use mock data to avoid actual network calls
- Use `skip_if_not()` to skip tests requiring API key
- Use `skip_on_cran()` to skip time-consuming performance tests
- Each test should be independent, not relying on other tests' state
