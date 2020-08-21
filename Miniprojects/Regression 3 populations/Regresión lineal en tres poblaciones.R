#### Load data and libraries
load("Data/Resampled Data.RData")
library(tidyverse); library(ggsci)

#### Basic exploration of the data
str(Res_DF)
glimpse(Res_DF)
head(Res_DF)

# Scatter plot of data with regression lineas and according to population
Res_DF %>% ggplot(aes(x, y, color = Population)) +
  geom_point(alpha = 0.75) +
  geom_smooth(method = 'lm') +
  scale_color_lancet() +
  theme_light() +
  theme(legend.position = "bottom")
  
#### Extract intercept and slope oregression from each population

# Slope and intercept for population 1  
Temp <- Res_DF %>% filter(Population == "Pop_1")
lm_1 <- lm(y ~ x, Temp)

lm_1_Inter <- lm_1$coefficients[1]
lm_1_Slope <- lm_1$coefficients[2]

# Slope and intercept for population 2  
Temp <- Res_DF %>% filter(Population == "Pop_2")
lm_2 <- lm(y ~ x, Temp)

lm_2_Inter <- lm_2$coefficients[1]
lm_2_Slope <- lm_2$coefficients[2]


# Slope and intercept for population 3  
Temp <- Res_DF %>% filter(Population == "Pop_3")
lm_3 <- lm(y ~ x, Temp)

lm_3_Inter <- lm_3$coefficients[1]
lm_3_Slope <- lm_3$coefficients[2]

#### New estimations of y based on the regressions of each population
New_y <- Res_DF %>% 
  transmute(
    y_1 = lm_1_Inter + (x * lm_1_Slope),
    y_2 = lm_2_Inter + (x * lm_2_Slope),
    y_3 = lm_3_Inter + (x * lm_3_Slope))

head(New_y)  

##### Box and violin plot to cheack distribution of estimations of y acording to population

New_y %>% 
  pivot_longer(
    cols = c(y_1, y_2, y_3),
    names_to = "Pop_Estim",
    values_to = "Value"
  ) %>% 
  ggplot(aes(Pop_Estim, Value, fill = Pop_Estim)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  scale_fill_lancet() +
  theme(legend.position = "none")
  
#### ANOVA on new estimations of y
y_anova <- New_y %>% 
  pivot_longer(
    cols = c(y_1, y_2, y_3),
    names_to = "Pop_Estim",
    values_to = "Value"
  )

summary(aov(Value ~ Pop_Estim, data = y_anova))
  
#### t-test of values from new estimations of y from pop 1 and 2
t.test(New_y$y_1, New_y$y_2)

#### ALTERNATIVE to get new estimations of y according to each model population

# Generate predictions wwith models
Alt <- data.frame(
  predict(data = Res_DF[,2], lm_1),
  predict(data = Res_DF[,2], lm_2),
  predict(data = Res_DF[,2], lm_3))

# Plot violin and box plot 
Alt %>% pivot_longer(
    cols = starts_with("p"),
    names_to = "Pop_Estim",
    values_to = "Value"
  ) %>% 
  ggplot(aes(Pop_Estim, Value, fill = Pop_Estim)) +
  geom_violin(alpha = 0.5) +
  geom_boxplot(width = 0.2) +
  scale_fill_lancet() +
  theme(legend.position = "none")
