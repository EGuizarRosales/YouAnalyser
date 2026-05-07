myModel_lm <- lm(F600 ~ ., data = bkw_processed)
myModel_lm_reduced <- lm(
  F600 ~ F800_1 +
    F800_2 +
    F800_3 +
    F800_4 +
    F800_5 +
    F800_6 +
    F800_7 +
    F800_8 +
    F800_9 +
    F800_10,
  data = bkw_processed
)
myModel_glm <- glm(F600 ~ ., data = bkw_bin_outcome, family = binomial())

imp_obj <- kda_importance_jrw(myModel_lm)
perf_obj <- kda_performance(myModel_lm)
ipma_obj <- kda_ipma(imp_obj, perf_obj)

p_imp <- kda_importance_barPlot(myModel_lm, imp_obj)
p_perf <- kda_performance_barPlot(myModel_lm, perf_obj)
p_ipma <- kda_ipma_scatterPlot(myModel_lm, ipma_obj)

################################################################################
