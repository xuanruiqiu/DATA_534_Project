# =============================================================================
# rGoldETF 完整使用Demo
# =============================================================================

# -----------------------------------------------------------------------------
# 第一步：安装和加载包
# -----------------------------------------------------------------------------

# 如果还没安装，先安装依赖
# install.packages(c("httr", "jsonlite", "ggplot2", "dplyr"))

# 从本地安装包（在包目录的上级目录运行）
# devtools::install("rGoldETF")

# 或者直接加载开发版本
devtools::load_all(".")

# -----------------------------------------------------------------------------
# 第二步：设置API密钥和延时配置
# -----------------------------------------------------------------------------

# 检查是否已设置API密钥，如果没有则提示用户设置
if (Sys.getenv("TWELVE_DATA_API_KEY") == "") {
  stop("请先设置API密钥：gld_set_api_key('your_api_key')\n",
       "获取免费密钥：https://twelvedata.com/pricing")
}

# API延时设置（免费版每分钟8次调用，设置8秒延时确保不超限）
API_DELAY <- 8  # 秒

# 延时辅助函数
api_wait <- function(seconds = API_DELAY) {
  cat(sprintf("  [等待 %d 秒以避免API限制...]\n", seconds))
  Sys.sleep(seconds)
}

# 方法1：使用环境变量（推荐）
# Sys.setenv(TWELVE_DATA_API_KEY = "your_api_key_here")

# 方法2：使用包函数
# gld_set_api_key("your_api_key_here")

# 获取免费API密钥：
# 1. 访问 https://twelvedata.com/
# 2. 点击 "Get Free API Key"
# 3. 注册账号
# 4. 在Dashboard中复制API Key

cat("\n")
cat("=============================================================\n")
cat("  rGoldETF Demo - 免费版API每分钟限制8次调用\n")
cat("  每次API调用后将等待", API_DELAY, "秒\n")
cat("=============================================================\n")

# -----------------------------------------------------------------------------
# 第三步：获取实时价格
# -----------------------------------------------------------------------------

cat("\n========== 实时价格 ==========\n")

# 获取GLD ETF实时价格
cat("\n1. 获取GLD实时价格...\n")
gld_price <- get_gld_price()
print(gld_price)
api_wait()

# 获取黄金现货价格
cat("\n2. 获取黄金现货价格...\n")
gold_spot <- get_gold_spot_price()
print(gold_spot)
api_wait()

# 获取其他黄金ETF价格
cat("\n3. 获取IAU实时价格...\n")
iau_price <- get_etf_price("IAU")  # iShares Gold Trust
print(iau_price)
api_wait()

# -----------------------------------------------------------------------------
# 第四步：获取历史数据
# -----------------------------------------------------------------------------

cat("\n========== 历史数据 ==========\n")

# 获取GLD最近30天历史数据
cat("\n4. 获取GLD最近30天历史数据...\n")
gld_history <- get_gld_history(
  start_date = Sys.Date() - 30,
  end_date = Sys.Date()
)
print(head(gld_history))
api_wait()

# 获取黄金现货历史数据
cat("\n5. 获取黄金现货历史数据...\n")
gold_history <- get_gold_spot_history(
  start_date = "2024-01-01",
  end_date = "2024-01-31"
)
print(head(gold_history))
api_wait()

# 获取周线数据
cat("\n6. 获取GLD周线数据...\n")
gld_weekly <- get_gld_history(
  start_date = "2023-01-01",
  end_date = "2023-12-31",
  interval = "1week"
)
print(head(gld_weekly))
api_wait()

# -----------------------------------------------------------------------------
# 第五步：计算技术指标
# -----------------------------------------------------------------------------

cat("\n========== 技术指标 ==========\n")

# 获取足够的历史数据用于计算指标
cat("\n7. 获取90天历史数据用于技术指标计算...\n")
history_data <- get_gld_history(
  start_date = Sys.Date() - 90,
  end_date = Sys.Date()
)
api_wait()

# 计算单个指标（本地计算，不消耗API）
cat("\n计算SMA指标（本地计算）...\n")
data_with_sma <- get_technical_indicators(
  history_data,
  indicators = "sma",
  periods = list(sma = 20)
)
print(tail(data_with_sma[, c("date", "close", "sma")]))

# 计算多个指标（本地计算，不消耗API）
cat("\n计算多个技术指标（本地计算）...\n")
data_with_indicators <- get_technical_indicators(
  history_data,
  indicators = c("sma", "ema", "rsi", "macd", "bollinger"),
  periods = list(sma = 20, ema = 12, rsi = 14)
)

# 查看结果
cat("\n最近5天的技术指标：\n")
print(tail(data_with_indicators[, c("date", "close", "sma", "ema", "rsi")], 5))

cat("\nMACD指标：\n")
print(tail(data_with_indicators[, c("date", "macd", "macd_signal", "macd_histogram")], 5))

cat("\n布林带：\n")
print(tail(data_with_indicators[, c("date", "close", "bb_upper", "bb_middle", "bb_lower")], 5))

# -----------------------------------------------------------------------------
# 第六步：可视化
# -----------------------------------------------------------------------------

cat("\n========== 可视化 ==========\n")
cat("（可视化使用本地数据，不消耗API）\n")

# 基础价格图
cat("\n生成基础价格图...\n")
p1 <- plot_gld_chart(history_data, title = "GLD Price Chart")
print(p1)

# 带技术指标的图
cat("\n生成带均线的图表...\n")
p2 <- plot_gld_chart(
  data_with_indicators,
  type = "line",
  indicators = c("sma", "ema"),
  title = "GLD with Moving Averages"
)
print(p2)

# K线图（蜡烛图）
cat("\n生成K线图...\n")
p3 <- plot_gld_chart(
  history_data,
  type = "candlestick",
  title = "GLD Candlestick Chart"
)
print(p3)

# 带布林带的图
cat("\n生成布林带图表...\n")
p4 <- plot_gld_chart(
  data_with_indicators,
  type = "line",
  indicators = c("bb_upper", "bb_middle", "bb_lower"),
  title = "GLD with Bollinger Bands"
)
print(p4)

# -----------------------------------------------------------------------------
# 第七步：比较多个ETF
# -----------------------------------------------------------------------------

cat("\n========== ETF比较 ==========\n")

# 比较多个黄金ETF（每个ETF需要一次API调用）
cat("\n8-10. 比较多个黄金ETF（需要3次API调用，每次间隔8秒）...\n")
comparison <- compare_gold_etfs(
  symbols = c("GLD", "IAU", "SGOL"),
  start_date = Sys.Date() - 30,
  end_date = Sys.Date(),
  delay = API_DELAY  # 传递延时参数
)
print(head(comparison, 20))
api_wait()

# -----------------------------------------------------------------------------
# 第八步：搜索黄金相关标的
# -----------------------------------------------------------------------------

cat("\n========== 搜索功能 ==========\n")

# 搜索黄金相关的股票/ETF
cat("\n11. 搜索黄金相关标的...\n")
gold_symbols <- search_gold_symbols("gold")
print(head(gold_symbols, 10))
api_wait()

# -----------------------------------------------------------------------------
# 第九步：检查市场状态
# -----------------------------------------------------------------------------

cat("\n========== 市场状态 ==========\n")

# 检查美股市场状态
cat("\n12. 检查NYSE市场状态...\n")
market_state <- get_market_state("NYSE")
print(market_state)
api_wait()

# -----------------------------------------------------------------------------
# 第十步：完整分析示例
# -----------------------------------------------------------------------------

cat("\n========== 完整分析示例 ==========\n")

# 综合分析函数
analyze_gold <- function() {
  # 1. 获取当前价格
  cat("\n13. 获取当前GLD价格进行分析...\n")
  current_price <- get_gld_price()
  cat("当前GLD价格:", current_price$price, "\n")
  cat("今日涨跌:", current_price$change, "(", current_price$change_percent, "%)\n\n")
  api_wait()

  # 2. 获取历史数据并计算指标
  cat("14. 获取60天历史数据...\n")
  history <- get_gld_history(
    start_date = Sys.Date() - 60,
    end_date = Sys.Date()
  )
  api_wait()

  cat("计算技术指标（本地计算）...\n")
  data <- get_technical_indicators(
    history,
    indicators = c("sma", "rsi", "macd")
  )

  # 3. 获取最新指标值
  latest <- tail(data, 1)

  cat("技术分析：\n")
  cat("- 20日均线:", round(latest$sma, 2), "\n")
  cat("- RSI(14):", round(latest$rsi, 2), "\n")
  cat("- MACD:", round(latest$macd, 4), "\n")
  cat("- MACD Signal:", round(latest$macd_signal, 4), "\n")

  # 4. 简单信号判断
  cat("\n信号判断：\n")

  if (latest$close > latest$sma) {
    cat("- 价格在均线上方 (看涨)\n")
  } else {
    cat("- 价格在均线下方 (看跌)\n")
  }

  if (latest$rsi > 70) {
    cat("- RSI超买区域 (可能回调)\n")
  } else if (latest$rsi < 30) {
    cat("- RSI超卖区域 (可能反弹)\n")
  } else {
    cat("- RSI中性区域\n")
  }

  if (latest$macd > latest$macd_signal) {
    cat("- MACD金叉 (看涨信号)\n")
  } else {
    cat("- MACD死叉 (看跌信号)\n")
  }

  # 5. 生成图表
  p <- plot_gld_chart(
    data,
    type = "line",
    indicators = c("sma"),
    title = paste("GLD Analysis -", Sys.Date())
  )

  return(list(
    price = current_price,
    data = data,
    chart = p
  ))
}

# 运行分析
result <- analyze_gold()
print(result$chart)

cat("\n========== Demo完成 ==========\n")
cat("总共进行了约14次API调用\n")
cat("更多信息请查看包文档: ?rGoldETF\n")
