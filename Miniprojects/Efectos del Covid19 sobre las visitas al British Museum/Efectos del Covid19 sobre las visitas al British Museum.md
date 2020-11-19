Efectos del Covid19 sobre las visitas al British Museum
================
Guillermo Bustos-Pérez
21/8/2020

## Introducción

El 18 de marzo de 2020 el British Museum junto con otros museos del
Reino Unido cerraban debido a la expansión del Covid-19. ¿Cómo afectó
este cierre al número de visitantes de ese mes? ¿Se notó el impacto del
Covid-19 en el número de visitantes los dos meses anteriores de 2020?

Este mini-proyecto es fácil de llevar a cabo:

1)  Empleando la serie temporal de visitas mensuales al British Museum
    generamos y seleccionamos el mejor modelo predictivo
2)  Realizamos las predicciones para los últimos meses (afectados por el
    Covid-19).  
3)  Contrastamos la diferencia entre las predicciones y los datos reales
    para hacernos una idea de las visitas que ha dejado de recibir el
    British Museum.

Los datos correspondientes a las visitas mensuales a los museos y
galerías del Reino Unido pueden ser accedidos fácilmente y de forma
gratuita a través de la página web del gobierno (<https://www.gov.uk/>),
o usando un buscador de bases de datos como el de Google
(<https://datasetsearch.research.google.com/>).

 

## Serie temporal de visitas mensuales al British Museum

Empezamos por cargar las librerías, el data set, y realizar un filtrado
que permita obtener únicamente los datos de visitas mensuales al British
Museum. Con esto ya podemos hacer una primera exploración de los datos

 

``` r
library(tidyverse); library(lubridate); library(zoo); library(xts); library(forecast)
```

``` r
test <- read.csv("Data/Museums_and_Galleries_monthly_visits_to_March_2020.csv")
```

``` r
BM <- test %>% 
  filter(museum == "BRITISH MUSEUM") 

str(BM)
```

    ## 'data.frame':    192 obs. of  4 variables:
    ##  $ museum: chr  "BRITISH MUSEUM" "BRITISH MUSEUM" "BRITISH MUSEUM" "BRITISH MUSEUM" ...
    ##  $ year  : int  2004 2004 2004 2004 2004 2004 2004 2004 2004 2005 ...
    ##  $ month : int  4 5 6 7 8 9 10 11 12 1 ...
    ##  $ visits: num  403841 367435 352583 504251 490457 ...

``` r
glimpse(BM)
```

    ## Rows: 192
    ## Columns: 4
    ## $ museum <chr> "BRITISH MUSEUM", "BRITISH MUSEUM", "BRITISH MUSEUM", "BRITI...
    ## $ year   <int> 2004, 2004, 2004, 2004, 2004, 2004, 2004, 2004, 2004, 2005, ...
    ## $ month  <int> 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,...
    ## $ visits <dbl> 403841, 367435, 352583, 504251, 490457, 360254, 455236, 3872...

``` r
head(BM)
```

    ##           museum year month visits
    ## 1 BRITISH MUSEUM 2004     4 403841
    ## 2 BRITISH MUSEUM 2004     5 367435
    ## 3 BRITISH MUSEUM 2004     6 352583
    ## 4 BRITISH MUSEUM 2004     7 504251
    ## 5 BRITISH MUSEUM 2004     8 490457
    ## 6 BRITISH MUSEUM 2004     9 360254

 

La base de datos no está en formato de serie temporal, ni los datos
correspondientes a las fechas (año y mes) están en formato adecuado para
el análisis. Es necesario hacer un formateo previo para poder emplearlas
en el análisis.

``` r
# New column with year and month
BM$Date <- paste(BM$year, BM$month, sep = "-")
BM$Date <- as.yearmon(BM$Date, "%Y-%m")

# Clean columns not needed
BM <- BM %>% 
  select(Date,
         visits)


BM <- ts(BM[,2], 
         start = c(2004, 4),
         frequency = 12)

# Check the time series
head(BM)
```

    ##         Apr    May    Jun    Jul    Aug    Sep
    ## 2004 403841 367435 352583 504251 490457 360254

``` r
tail(BM)
```

    ##         Jan    Feb    Mar Apr May Jun Jul Aug Sep    Oct    Nov    Dec
    ## 2019                                              522556 442347 445302
    ## 2020 463881 471593 179887

``` r
length(BM)
```

    ## [1] 192

 

Con esto podemos ver que se trata de una serie temporal de 192 meses,
abarcando desde abril de 2004 hasta marzo de 2020. Un **autoplot()** nos
permite visualizar el desarrollo de la serie y el efecto que ha tenido
el Covid-19 en los tres primeros meses de 2020.

``` r
# Visualize time series
forecast::autoplot(BM, color = "blue") + 
  theme_light() +
  scale_x_continuous(breaks = seq(from = 2004, to = 2020, by = 1)) +
  ylab("British Museum Visitors by month") +
  labs(caption = "Data from gov.uk: Museums and galleries monthly visits") +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(color = "black", size = 9),
    axis.text.x = element_text(color = "black", size = 6.5),
    axis.text.y = element_text(color = "black", size = 7)) 
```

    ## Scale for 'x' is already present. Adding another scale for 'x', which will
    ## replace the existing scale.

![](Efetos-del-Covid19-sobre-las-visitas-al-British-Museum_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

 

``` r
# Exclude Covid-19 months
No_Covid <- window(BM, end = c(2019, 12))

glimpse(No_Covid)
```

    ##  Time-Series [1:189] from 2004 to 2020: 403841 367435 352583 504251 490457 ...

 

Primero vamos a excluir los primeros meses de 2020, correspondientes al
desarrollo de la pandemia. En segundo lugar vamos a limitar la serie
temporal de entrenamiento entre enero de 2013 y diciembre de 2018. Esto
se debe a que al observar la serie temporla hay una marcada diferencia
entre la estacionalidad y tendencia de este periodo y el comprendido
entre 2004 y diciembre de 2012. Por último el test set corresponde al
año 2019.

``` r
train <- window(No_Covid,                
                start= c(2013,1),
                end = c(2018, 12))
test <- window(No_Covid, start = c(2019, 1))

Covid_Months <- window(BM, start = c(2020, 1))
```

 

Vamos a probar tres tipos de modelos: un **ARIMA**, un **bagged tree** y
una **red neuronal**. Los tres están disponibles en el paquete
**forecast**. El procedimiento para seleccionar el mejor modelo es el
conocido para los procesos de machine learning: entrenamos el modelo
sobre el training set, hacemos las predicciones para el periodo
correspondiente del test set, y comparamos las medidas de precisión
(RMSE, MAE, MPE, etc.). El que presente los vamores más bajos es el
modelo más adecuado.

``` r
BC <- BoxCox.lambda(train)

# ARIMA model
Arima_pred <- auto.arima(train, lambda = BC,
                  stepwise = FALSE,
                  approx = FALSE) %>% 
  forecast(h = 12)

# Bagged tree model
Bagged_pred <- baggedModel(train) %>% 
  forecast(h = 12)

# NNW model
nn_pred <- nnetar(train, 
                  lambda = BC, 
                  size = 20, p = 24) %>% 
  forecast(h = 12)

# Compare accuracy measures
accuracy(Arima_pred, test)
```

    ##                    ME      RMSE       MAE       MPE      MAPE      MASE
    ## Training set 89703.22 235317.21 118134.70 15.742751 21.609486 3.0196076
    ## Test set     23498.60  35665.89  26427.08  4.316911  4.972214 0.6754951
    ##                   ACF1 Theil's U
    ## Training set 0.9272008        NA
    ## Test set     0.2921044 0.5461606

``` r
accuracy(Bagged_pred, test)
```

    ##                     ME     RMSE      MAE        MPE     MAPE      MASE
    ## Training set -2310.795 30352.48 25167.07 -0.8019116 4.963287 0.6432883
    ## Test set      2842.152 32747.05 27027.80  0.7741380 5.610915 0.6908498
    ##                   ACF1 Theil's U
    ## Training set 0.3685727        NA
    ## Test set     0.3539059 0.4334972

``` r
accuracy(nn_pred, test)
```

    ##                        ME        RMSE        MAE          MPE        MAPE
    ## Training set     1.562599    39.55516    25.5085 0.0001905391 0.004531733
    ## Test set     17502.252246 46149.41974 38187.4262 2.9442373656 7.481091537
    ##                      MASE         ACF1 Theil's U
    ## Training set 0.0006520155 -0.218692549        NA
    ## Test set     0.9760979911 -0.002754004 0.6901085

 

El **bagged tree** parece ser el modelo más adecuado. Observando el plot
podemos ver que las predicciones parecen bastante correctas. Solo en uno
de los meses cae fuera del intervalo de confianza.

``` r
# plot from bagged predictions
Bagged_pred %>% 
  autoplot() +
  autolayer(test) +
  theme(legend.position = "none")
```

![](Efetos-del-Covid19-sobre-las-visitas-al-British-Museum_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

 

Ahora volvemos a entrenar el modelo sobre la ventana temporal completa
de 2013 a diciembre de 2019.

``` r
# Training on complete time series
train <- window(No_Covid,                
                start= c(2013,1),
                end = c(2019, 12))

# Model on complete time series
Model <- baggedModel(train)

Model_pred <- Model %>% forecast(h = 3)

Model_pred %>% 
  autoplot() +
  autolayer(Covid_Months, color = "red") +
  theme(legend.position = "none")
```

![](Efetos-del-Covid19-sobre-las-visitas-al-British-Museum_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

 

Con esto extraemos la diferencia entre los datos de visitas durante los
tres primeros meses de 2020 y las predicciones del modelo. Las visitas
al British Museum entre los meses de enero y febrero no parecen haber
sufrido demasiado el impacto del Covid-19. En ambos casos las visitas
recibidas superan las predicciones del modelo (cerca de 65.000 visitas
más en enero y 31.000 visitas más en febrero).

Sin embargo, el mes de **marzo** supone un desplome, con **una pérdida
de cerca de 330.000 visitantes** al British Museum debido al cierre de
este el día 18 de ese mes
(<https://www.thenational.ae/arts-culture/art/coronavirus-tate-v-a-museum-and-british-museum-close-1.993733>).
Esto supone el número más bajo de visitantes en la serie temporal
proporcionada desde 2004.

``` r
# Compute diference between predictions and actual data
data.frame(
      Month = c("January", "February", "March"),
      Covid_Months, 
      Model_pred$mean) %>% 
  mutate(Difference = round(Covid_Months - Model_pred$mean))
```

    ##      Month Covid_Months Model_pred.mean Difference
    ## 1  January       463881        399331.9      64549
    ## 2 February       471593        441670.6      29922
    ## 3    March       179887        512275.9    -332389
