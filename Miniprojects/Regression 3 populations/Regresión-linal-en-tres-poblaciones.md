Regresión lineal en tres poblaciones
================
Guillermo Bustos-Pérez
20/8/2020

## Regresión sobre tres poblaciones

Hay que mantener en mente que **x** puede ser un proxy para calcular
**y**. Este proxy pude ser el resultado de la fórmula de varios
coeficientes de una regresión lineal múltiple. Mientras que **y** es la
variable dependiente a predecir. Las tres poblaciones pueden representan
diferentes categorías.

Por ejemplo, la variable dependiente pude corresponder al precio de una
casa, mientras que x puede ser una combinación de los \(m^2\), número de
baños, número de habitaciones, etc. Las tres categorías pueden
representar el tipo de casa, siendo pisos en ciudad, chalets adosados en
el extrarradio, etc.

En este caso constituyen datos simulados, lo cual facilita mucho el
desarrollo del ejemplo.

 

``` r
load("Data/Resampled Data.RData")
```

``` r
library(tidyverse)
```

    ## -- Attaching packages ----------------------------------------- tidyverse 1.3.0 --

    ## v ggplot2 3.3.2     v purrr   0.3.4
    ## v tibble  3.0.3     v dplyr   1.0.1
    ## v tidyr   1.1.1     v stringr 1.4.0
    ## v readr   1.3.1     v forcats 0.5.0

    ## -- Conflicts -------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

 

La pregunta a la que queremos responder es: **¿el proxy (x) para
determinar la variable dependiente (y) es aplicable a las tres
poblaciones?**

Empezamos por hacer una exploración de los datos para ver que son 3000
casos, siendo 1000 por población, con sus respectivos valores de *x* e
*y*.

 

``` r
# Basic exploration of the data
str(Res_DF)
```

    ## tibble [3,000 x 3] (S3: tbl_df/tbl/data.frame)
    ##  $ x         : num [1:3000] 3.43 23.87 13.2 24.12 16.53 ...
    ##  $ y         : num [1:3000] 1.1 12.05 6.19 11.05 6.82 ...
    ##  $ Population: chr [1:3000] "Pop_1" "Pop_1" "Pop_1" "Pop_1" ...

``` r
glimpse(Res_DF)
```

    ## Rows: 3,000
    ## Columns: 3
    ## $ x          <dbl> 3.426650, 23.870555, 13.202573, 24.118275, 16.530005, 13...
    ## $ y          <dbl> 1.0987601, 12.0480287, 6.1850676, 11.0470406, 6.8195059,...
    ## $ Population <chr> "Pop_1", "Pop_1", "Pop_1", "Pop_1", "Pop_1", "Pop_1", "P...

``` r
head(Res_DF)
```

    ## # A tibble: 6 x 3
    ##       x     y Population
    ##   <dbl> <dbl> <chr>     
    ## 1  3.43  1.10 Pop_1     
    ## 2 23.9  12.0  Pop_1     
    ## 3 13.2   6.19 Pop_1     
    ## 4 24.1  11.0  Pop_1     
    ## 5 16.5   6.82 Pop_1     
    ## 6 13.5   8.41 Pop_1

 

Una rápida representación de los datos nos permite ver que la relación
entre el proxy (*x*) y la variable dependiente (*y*) es muy similar
entre las dos primeras poblaciones, pero la población número 3 presenta
diferencias en la pendiente e intercept.

 

``` r
Res_DF %>% ggplot(aes(x, y, color = Population)) +
  geom_point(alpha = 0.75) +
  geom_smooth(method = 'lm') +
  scale_color_lancet() +
  theme_light() +
  theme(legend.position = "bottom")
```

    ## `geom_smooth()` using formula 'y ~ x'

![](Regresión-linal-en-tres-poblaciones_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

 

A estas alturas conviene repasar la fórmula de la regresión lineal:

\[y = intercept + x*slope\]

Por consiguiente, podemos entrenar un modelo de regresión lineal para
cada población (con sus respectivas pendientes e intercepts) y tras ello
obtener tres nuevas estimaciones de *y* (una por modelo) en base a los
coeficientes. Tras esto basta con comparar si hay diferencias
estadísticamente significativas entre las tres nuevas estimaciones de
*y*.

Empezamos con la primera población:

``` r
# Slope and intercept for population 1  
Temp <- Res_DF %>% filter(Population == "Pop_1")
lm_1 <- lm(y ~ x, Temp)

lm_1_Inter <- lm_1$coefficients[1]
lm_1_Slope <- lm_1$coefficients[2]

lm_1_Inter; lm_1_Slope
```

    ## (Intercept) 
    ##  0.04739327

    ##         x 
    ## 0.4730589

 

Segunda y tercera poblaciones:

``` r
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
```

 

Ahora que disponemos de los intercepts y pendientes de cada modelo
podemos calcular las nuevas estimaciones de *y*:

``` r
# New estimations of y 
New_y <- Res_DF %>% 
  transmute(
    y_1 = lm_1_Inter + (x * lm_1_Slope),
    y_2 = lm_2_Inter + (x * lm_2_Slope),
    y_3 = lm_3_Inter + (x * lm_3_Slope))

head(New_y)
```

    ## # A tibble: 6 x 3
    ##     y_1   y_2   y_3
    ##   <dbl> <dbl> <dbl>
    ## 1  1.67  1.61  1.16
    ## 2 11.3  11.6   5.67
    ## 3  6.29  6.38  3.32
    ## 4 11.5  11.7   5.72
    ## 5  7.87  8.00  4.05
    ## 6  6.43  6.52  3.38

 

Una vez obtenidos los nuevos datos podemos hacer un box y violín plot
que nos permita ver la distribución de estimación de valores según las
nuevas estimaciones de *y*.

``` r
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
```

![](Regresión-linal-en-tres-poblaciones_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

 

Rematamos el análisis con un ANOVA comparando las tres nuevas
estimaciones de *y* (a estas alturas ya resulta evidente que las
estimaciones de y realizadas a partir del modelo de regresión lineal de
la población 3 van a ser diferentes de las otras dos poblaciones).

``` r
# ANOVA on new estimations of y
y_anova <- New_y %>% 
  pivot_longer(
    cols = c(y_1, y_2, y_3),
    names_to = "Pop_Estim",
    values_to = "Value"
  )

summary(aov(Value ~ Pop_Estim, data = y_anova))
```

    ##               Df Sum Sq Mean Sq F value Pr(>F)    
    ## Pop_Estim      2  17896    8948    1050 <2e-16 ***
    ## Residuals   8997  76695       9                   
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

 

A esto añadimos un students-t test para determinar si las estimaciones
de *y* usando las regresiones de las poblaciones 1 y 2 proporcionan
valores que difieren significativamente. Confirmamos lo que ya habíamos
intuido en el scatter plot y el violín-box plot: no hay diferencia
estadísticamente significativa. Por consiguiente entrenar un modelo que
incluya datos de las poblaciones 1 y 2 es correcto.

``` r
# t-test of values from new estimations of y from pop 1 and 2
t.test(New_y$y_1, New_y$y_2)
```

    ## 
    ##  Welch Two Sample t-test
    ## 
    ## data:  New_y$y_1 and New_y$y_2
    ## t = -0.98247, df = 5992.3, p-value = 0.3259
    ## alternative hypothesis: true difference in means is not equal to 0
    ## 95 percent confidence interval:
    ##  -0.25846786  0.08588721
    ## sample estimates:
    ## mean of x mean of y 
    ##  6.239861  6.326152

 

**NOTA:** no es necesario extraer e introducir manualmente los valores
del slope e intercept de los modelos para obtener las nuevas
estimaciones. Podemos hacer esto mismo usando la función **predict()**
junto con los modelos generados y vemos que los resultados son
idénticos.

``` r
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
```

![](Regresión-linal-en-tres-poblaciones_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->
