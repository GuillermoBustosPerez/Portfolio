Predicción ventas retail
================

# Índice

1)  Introducción  
    1.1) Carga de los datos y primer vistazo  
2)  Exploración de los datos  
    2.1) Análisis exploratorio visual  
    2.2) Serie temporal semanal  
3)  Modelo de predicción  
    3.1) Comprobar el *White Noise*  
    3.2) Preprocesado: train y test sets  
    3.3) Visualización y precisión de modelos candidatos  
4)  Predicciones finales

## 1\) Introducción

El presente dataset contiene el conjunto de ventas histórico de uno de
los principales vendedores al por menor de Brasil. Los datos están
disponibles en:  
<https://www.kaggle.com/tevecsystems/retail-sales-forecasting>

Según indica la introducción: una de las principales cuestiones a
afrontar por parte de los vendedores al por menor es la cantidad de
inventario a manejar. Un inventario numeroso implica costes de capital,
costes operacionales, y su consiguiente gestión. Por otra parte, la
ausencia de inventario da lugar a pérdidas de ventas, clientes
insatisfechos y daños en la imagen de la marca.

Esto da lugar a que las **predicciones de series temporales a corto
plazo** sean fundamentales en la venta al por menor y en la industria de
bienes. En este dataset el objetivo es producir un modelo de predicción
de demanda para intervalos de 2/3 semanas.

### 1.1) Carga de los datos y primer vistazo

Vamos a empezar por cargar las librerías de referencia **tidyverse**
(Wickham, 2017; Wickham et al., 2019), **zoo** (Zeileis and
Grothendieck, 2005) y **xts** (Ryan, and Ulrich, 2020)

``` r
library(tidyverse);library(zoo); library(xts) 
```

``` r
retail <- read.csv("Data/mock_kaggle.csv")
```

<table>

<thead>

<tr>

<th style="text-align:left;">

data

</th>

<th style="text-align:right;">

venda

</th>

<th style="text-align:right;">

estoque

</th>

<th style="text-align:right;">

preco

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

2014-01-01

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

4972

</td>

<td style="text-align:right;">

1.29

</td>

</tr>

<tr>

<td style="text-align:left;">

2014-01-02

</td>

<td style="text-align:right;">

70

</td>

<td style="text-align:right;">

4902

</td>

<td style="text-align:right;">

1.29

</td>

</tr>

<tr>

<td style="text-align:left;">

2014-01-03

</td>

<td style="text-align:right;">

59

</td>

<td style="text-align:right;">

4843

</td>

<td style="text-align:right;">

1.29

</td>

</tr>

<tr>

<td style="text-align:left;">

2014-01-04

</td>

<td style="text-align:right;">

93

</td>

<td style="text-align:right;">

4750

</td>

<td style="text-align:right;">

1.29

</td>

</tr>

<tr>

<td style="text-align:left;">

2014-01-05

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

4654

</td>

<td style="text-align:right;">

1.29

</td>

</tr>

</tbody>

</table>

 

Vamos a cambiar el nombre de las columnas para evitar confusiones.

``` r
# Change column names
colnames(retail)[1] <- "date"
colnames(retail)[2] <- "sales"
colnames(retail)[3] <- "stock"
colnames(retail)[4] <- "price"
```

 

## 2\) Exploración de los datos

Lo primero es evaluar la estructura y composición de los datos. Dado que
estamos trabajando con una serie temporal hay que transformar la columna
de *date* a formato de fecha.

``` r
# Check data
str(retail)
```

    ## 'data.frame':    937 obs. of  4 variables:
    ##  $ date : chr  "2014-01-01" "2014-01-02" "2014-01-03" "2014-01-04" ...
    ##  $ sales: int  0 70 59 93 96 145 179 321 125 88 ...
    ##  $ stock: int  4972 4902 4843 4750 4654 4509 4329 4104 4459 5043 ...
    ##  $ price: num  1.29 1.29 1.29 1.29 1.29 1.29 1.29 1.29 1.09 1.09 ...

``` r
dim(retail)
```

    ## [1] 937   4

``` r
# Make into date format
retail$date <- as.Date(retail$date)
```

### 2.1) Análisis exploratorio visual

Vamos a representar gráficamente la evolución de ventas, stock y precio
a lo largo de la serie temporal.

``` r
retail %>% pivot_longer(
  c(sales, stock, price),
  names_to = "Variable",
  values_to = "units"
) %>% 
  
  ggplot(aes(date, units, color = Variable)) +
  geom_line() +
  geom_point() +
  facet_wrap(~Variable, nrow = 3,
                     scales = "free") +
  ggsci::scale_color_aaas() +
  theme_light() +
  theme(legend.position = "none")
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

A primera vista no parece que el precio esté condicionando las ventas.
Vamos a omitir los registros con precio 0 y comprobar visualmente si
diferentes precios afectan a las ventas. No parece ser el caso, ya que
el promedio de ventas es similar para tres intervalos con diferentes
precios, mientras que el intervalo de mayor precio muestra
aproximadamente el mismo número de ventas que el segundo intervalo de
menor precio.

``` r
# Check if price affects sales  
retail %>% filter(price > 0) %>% 
  ggplot(aes(price, sales, fill = cut_width(price, 0.5))) +
  geom_boxplot(aes(group = cut_width(price, 0.5))) +
  ggsci::scale_fill_aaas() +
  theme_light() +
  theme(legend.position = "bottom")
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->  

El modelo de regresión lineal muestra una relación ligeramnete
significaatiiva entre ventas y el precio (notese que esta relación
desaparece a escala logarítmica y excluyendo casos en los que las ventas
y el precio son igual cero).

``` r
# Lineal model of sales as a function of price
summary(lm(sales ~ price, retail))
```

    ## 
    ## Call:
    ## lm(formula = sales ~ price, data = retail)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -106.38  -62.05  -17.19   36.06  452.95 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)   67.534      8.325   8.112 1.56e-15 ***
    ## price         14.442      4.961   2.911  0.00369 ** 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 80.36 on 935 degrees of freedom
    ## Multiple R-squared:  0.008983,   Adjusted R-squared:  0.007923 
    ## F-statistic: 8.475 on 1 and 935 DF,  p-value: 0.003685

``` r
# Lineal model of sales as a function of price (logaritmic)
log_data <- retail %>% 
  filter(sales > 0 & price >0) %>% 
  transmute(log_sales = log(sales),
            log_price = log(price))
summary(lm(log_sales ~ log_price, log_data))
```

    ## 
    ## Call:
    ## lm(formula = log_sales ~ log_price, data = log_data)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -4.2794 -0.2966  0.2394  0.6636  2.0725 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  4.12782    0.07164  57.620   <2e-16 ***
    ## log_price    0.23813    0.13493   1.765    0.078 .  
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.138 on 823 degrees of freedom
    ## Multiple R-squared:  0.00377,    Adjusted R-squared:  0.00256 
    ## F-statistic: 3.115 on 1 and 823 DF,  p-value: 0.07796

 

Vamos a visualizar las ventas diarias por año. Para ello es necesario
hacer dos transformaciones: extraer el año como una variable propia, y
extraer el mes y día como otra variable propia de tipo *date*.

``` r
# Get year amd month-day 
retail<- retail %>% 
  mutate(date_character = as.character(date)) %>% 
  separate(date_character, 
           into =c("year", "Month_Day"),  
           sep = 5,
           remove = TRUE) %>% 
  select(-c(year)) %>% 
  mutate(
    Month_Day = as.Date(Month_Day, "%m-%d"),
    year = lubridate::year(date)) 
```

``` r
# Plot sales per year and month
retail %>% 
  ggplot(aes(Month_Day, sales, color = factor(year))) +
  geom_line() +
  ggsci::scale_color_d3() +
  scale_x_date(date_breaks = "1 month",
               date_labels = "%m") +
  xlab("Month") +
  theme_light() +
  theme(legend.position = "bottom")
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->  

El gráfico de ventas diarias no es muy adecuado, así que aprovechamos
para crear un boxplot de ventas por mes y año.

``` r
# Boxplots of monthly sales per year
retail %>% 
  mutate(month = lubridate::month(date)) %>% 
  ggplot(aes(factor(month), sales, fill = factor(year))) +
  geom_boxplot() +
  xlab("Month") +
  ggsci::scale_fill_d3() +
  theme(legend.position = "bottom") 
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->  

### 2.2) Serie temporal semanal

En el enunciado se señala la importancia de que las predicciones sean
semanales, con la capacidad de crear predicciones para intervales de 2/3
semanas. Para ello es necesario transformar la serie temporal generando
la suma de ventas para cada semana.

``` r
# Make into xts objetc
retail_xts <- as.xts(retail [ , -c(1,5,6)], order.by = retail$date)
```

``` r
# Weekly sum of sales
retail_weeks <- apply.weekly(retail_xts, colSums)

plot(retail_weeks[,1])
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

 

## 3\) Modelo de predicción

### 3.1) Comprobar el *White Noise*

Lo fundamental al inicio del análisis de cualquier serie temporal es
comprobar si se trata de *white noise*. En este caso resulta fundamental
emplear la librería **forecast** (Hyndman and Khandakar, 2008) y seguir
los principios de análisis de series temporales expuestos en Hyndman y
Athanasopoulos (2019). Para ello resulta esencial ver el
**autocorrelation plot** y hacer la prrueba Ljung-Box (Ljung and Box,
1978)

``` r
library(forecast)
```

``` r
# Autocorrelation plot
ggAcf(retail_weeks[,1],
      lag = 52)
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

``` r
# Ljung-Box test of white noise
Box.test(retail_weeks[,1],
         lag = 52,
         fitdf = 0,
         type = "Lj")
```

    ## 
    ##  Box-Ljung test
    ## 
    ## data:  retail_weeks[, 1]
    ## X-squared = 132.93, df = 52, p-value = 5.102e-09

 

El autocorrelation plot y la prueba Ljung-Box muestran que **la serie
temporal no es white-noise**, y que hay información utilizable en los
periodos anteriores para realizar predicciones futuras. Viendo la serie
temporal de las ventas semanales y el autocorrelation plot resulta
aparente que **un modelo ARIMA no va a ser adecuado para generar
predicciones sobre esta serie temporal**.

### 3.2) Preprocesado: train y test sets

Vamos a transformar ahora los datos en el **train y test sets**. Lo
ideal es queambos sean **ts**, que permite aplicar los modelos de
predicción de series temporales de la librería **forecast**. Sin embargo
el indexado y selección de periodos de tiempo en objetos ts puede
resultar menos intuitiivo que en xts, por lo que es adecuado usar este
formato como base para la tarnsformación a ts.

``` r
# Get number of weeks per year
nweeks(retail_weeks["2014"][,1])
```

    ## [1] 52

``` r
nweeks(retail_weeks["2015"][,1])
```

    ## [1] 52

``` r
nweeks(retail_weeks["2016"][,1])
```

    ## [1] 31

``` r
nweeks(retail_weeks[,1])
```

    ## [1] 135

``` r
# make into time series
retail_ts <- ts(retail_weeks[,1],
                start = c(2014, 1),
                end = c(2016, 31),
                   frequency = 52)


# Train set
train_ts <- window(retail_ts, 
               end = c(2016, 11))

# Test set
test_ts <- window(retail_ts,
               start= c(2016, 12))

# Check legth of train and test sets
length(train_ts)
```

    ## [1] 115

``` r
length(test_ts)
```

    ## [1] 20

``` r
# Check the sum is correct
(length(train_ts) + length(test_ts)) == length(retail_ts)
```

    ## [1] TRUE

 

El paso inicial es aplicar una transformación Box-Cox para dar
estacionariedad a la serie temporal que permita aplicar modelos ARIMA.

``` r
BC <- BoxCox.lambda(train_ts)
BC
```

    ## [1] 0.6160325

 

Sin embargo es importante señalar que la serie parece ser bastante
estacionaria, haciendo que sea poco adecuada para modelos ARIMA.

  - Duarante la mayor parte de la serie temporal no se observa una
    tendencia, salvo en el segundo cuarto de 2016, donde parece haber
    una tendencia ascendente.  
  - Hay picos de ventas, pero sin una estacionalidad clara  
  - Se trata de datos semanales, lo cual implica periodos estacionales
    sean muy largos que no son manejados de forma eficiente por la
    mayoría de los modelos.

<!-- end list -->

``` r
ggseasonplot(retail_ts, year.labels=TRUE, year.labels.left=TRUE) +
  ggtitle("Seasonal plot: seasonal sales") +
  ylab("Sales") +
  theme_grey() +
  ggsci::scale_color_d3() + 
  theme(axis.text.x = element_text(size = 7, color = "black")) 
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

### 3.2) Visualización y precisión de modelos candidatos

La fase inicial del análisis se centra en visualizar las predicciones de
los diferentes modelos sobre el test set. Esta primera visualización nos
permite optar por modelos para posteriormente evaluar los residuals y
comparar las métricas. Dada la naturaleza de los datos y el análisis
previo vamos a visualziar un modelo ARIMA, naive estacional y STLF.

``` r
#Make ARIMA predictions
arima_forecast <- auto.arima(train_ts, lambda = BC) %>% 
  forecast(h = 20)

## Plot the three models
autoplot(train_ts) +
    autolayer(test_ts, color = "red") + 
  
# Plot auto ARIMA
  autolayer(arima_forecast,
                     series = "Auto ARIMA", PI = FALSE, 
          color = "navyblue") + 
  
# Plot seasonal naive
  autolayer(snaive(train_ts, h = 20, lambda = BC),
            series = "Seasonal naïve", PI = FALSE,
            color = "purple") +
  
# Plot STLF
    autolayer(stlf(train_ts, h = 20, lambda = BC),
            series = "stlf", PI = FALSE, 
            color = "gold") 
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-21-1.png)<!-- -->  

Con esta visualización queda claro que el modelo ARIMA no es el más
adecuado para realizar las estimaciones. Aún así conviene visualizar las
proyecciones junto con los intervalos de confianza.

``` r
# Forecast of each model along confidance
ggpubr::ggarrange(
  
  (autoplot(train_ts) +
     autolayer(arima_forecast,
                     series = "Auto ARIMA", PI = TRUE, 
          color = "navyblue") +
    autolayer(test_ts, color = "red") +
     ggtitle("ARIMA model")),
  
  (autoplot(train_ts) +
      autolayer(snaive(train_ts, h = 20, lambda = BC),
            series = "Seasonal naïve", PI = TRUE,
            color = "purple") +
    autolayer(test_ts, color = "red") +
     ggtitle("Seasonal naïve model")),
  
   (autoplot(train_ts) +
      
      autolayer(stlf(train_ts, h = 20, lambda = BC),
            series = "stlf", PI = TRUE, 
            color = "gold") +
      autolayer(test_ts, color = "red")+
     ggtitle("STLF model")),
  
  ncol = 1
)
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-22-1.png)<!-- -->  

El cálculo de las métricas de precisión de los modelos muestra que el
modelo STLF y el estacional naïve tienen valores similares. El modelo
ARIMA tiene una MAPE, MAE y RMSE más bajas.

``` r
# Compute forecasts
stlf_forecast <- stlf(train_ts, h = 20, lambda = BC)
snaive_forecast <- snaive(train_ts, h = 20, lambda = BC)

Accuracy <- data.frame(rbind(accuracy(stlf_forecast, test_ts)[2, 1:8],
                                accuracy(snaive_forecast, test_ts)[2, 1:8],
                                accuracy(arima_forecast, test_ts)[2, 1:8]))

colnames(Accuracy) <-  colnames(accuracy(stlf_forecast, test_ts))

Models  <- c("STLF", "S-naive", "ARIMA")
Accuracy <- cbind(Models,Accuracy)
```

<table>

<thead>

<tr>

<th style="text-align:left;">

Models

</th>

<th style="text-align:right;">

ME

</th>

<th style="text-align:right;">

RMSE

</th>

<th style="text-align:right;">

MAE

</th>

<th style="text-align:right;">

MPE

</th>

<th style="text-align:right;">

MAPE

</th>

<th style="text-align:right;">

MASE

</th>

<th style="text-align:right;">

ACF1

</th>

<th style="text-align:right;">

Theil’s U

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

STLF

</td>

<td style="text-align:right;">

528.4004

</td>

<td style="text-align:right;">

727.4158

</td>

<td style="text-align:right;">

597.2324

</td>

<td style="text-align:right;">

39.03600

</td>

<td style="text-align:right;">

53.26733

</td>

<td style="text-align:right;">

1.534676

</td>

<td style="text-align:right;">

0.2776812

</td>

<td style="text-align:right;">

1.357749

</td>

</tr>

<tr>

<td style="text-align:left;">

S-naive

</td>

<td style="text-align:right;">

511.1500

</td>

<td style="text-align:right;">

738.1334

</td>

<td style="text-align:right;">

601.4500

</td>

<td style="text-align:right;">

40.06477

</td>

<td style="text-align:right;">

54.79969

</td>

<td style="text-align:right;">

1.545513

</td>

<td style="text-align:right;">

0.2530285

</td>

<td style="text-align:right;">

1.509951

</td>

</tr>

<tr>

<td style="text-align:left;">

ARIMA

</td>

<td style="text-align:right;">

576.2987

</td>

<td style="text-align:right;">

718.3141

</td>

<td style="text-align:right;">

589.9789

</td>

<td style="text-align:right;">

45.15836

</td>

<td style="text-align:right;">

49.04477

</td>

<td style="text-align:right;">

1.516037

</td>

<td style="text-align:right;">

0.3415656

</td>

<td style="text-align:right;">

1.309740

</td>

</tr>

</tbody>

</table>

### 3.3) ANN

Empleando una ANN con 8 nodos en el *hidden layer*, los 25 últimos
periodos de tiempo como imputs y los datos observados en la misma semana
del año anterior. En este caso incremenamos el hiperparámetro de *decay*
para optener un incremento en los intervalos de confianza de las
predicciones.

``` r
ANN_forecasts <- nnetar(train_ts, p = 25, P = 1, size = 12, 
                        lambda = BC, decay = 0.9) %>% 
  forecast(PI = TRUE, h = 20)



autoplot(ANN_forecasts) +
  autolayer(test_ts) +
  theme(legend.position = "none")
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-25-1.png)<!-- -->

``` r
accuracy(ANN_forecasts, test_ts)
```

    ##                     ME     RMSE      MAE      MPE     MAPE     MASE      ACF1
    ## Training set  21.86373 138.5427 104.3381     -Inf      Inf 0.268112 0.1661261
    ## Test set     226.77902 534.2249 440.0146 7.571435 46.16832 1.130682 0.4810259
    ##              Theil's U
    ## Training set        NA
    ## Test set      1.238946

 

## 4\) Predicciones finales

Podemos optar por dos modelos finales. Por un lado el modelo STLF ya que
presenta valores equilibrados en las métricas de precisión, y las
predicciones procedentes de la ANN, que muestra los mejores valores en
las métricas de precisión. Hacemos una predicción semanal hasta la
primera semana de 2017 (h = 22).

``` r
new_BC <- BoxCox.lambda(retail_ts)

# Final forecast using STLF
final_forecast <- stlf(retail_ts, h = 22, lambda = new_BC) 

autoplot(final_forecast)
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-26-1.png)<!-- -->

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:right;">

Point Forecast

</th>

<th style="text-align:right;">

Lo 80

</th>

<th style="text-align:right;">

Hi 80

</th>

<th style="text-align:right;">

Lo 95

</th>

<th style="text-align:right;">

Hi 95

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

2016.596

</td>

<td style="text-align:right;">

896.0506

</td>

<td style="text-align:right;">

489.34737

</td>

<td style="text-align:right;">

1398.965

</td>

<td style="text-align:right;">

316.506887

</td>

<td style="text-align:right;">

1701.561

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.615

</td>

<td style="text-align:right;">

630.3086

</td>

<td style="text-align:right;">

269.87597

</td>

<td style="text-align:right;">

1107.530

</td>

<td style="text-align:right;">

132.413009

</td>

<td style="text-align:right;">

1403.445

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.635

</td>

<td style="text-align:right;">

1343.7330

</td>

<td style="text-align:right;">

792.68506

</td>

<td style="text-align:right;">

2009.339

</td>

<td style="text-align:right;">

550.983199

</td>

<td style="text-align:right;">

2405.298

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.654

</td>

<td style="text-align:right;">

773.8728

</td>

<td style="text-align:right;">

335.37872

</td>

<td style="text-align:right;">

1352.590

</td>

<td style="text-align:right;">

167.185016

</td>

<td style="text-align:right;">

1710.966

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.673

</td>

<td style="text-align:right;">

827.7269

</td>

<td style="text-align:right;">

355.86504

</td>

<td style="text-align:right;">

1451.804

</td>

<td style="text-align:right;">

175.553575

</td>

<td style="text-align:right;">

1838.607

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.692

</td>

<td style="text-align:right;">

1584.1242

</td>

<td style="text-align:right;">

908.18708

</td>

<td style="text-align:right;">

2407.792

</td>

<td style="text-align:right;">

615.112633

</td>

<td style="text-align:right;">

2899.904

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.712

</td>

<td style="text-align:right;">

1218.9940

</td>

<td style="text-align:right;">

603.68794

</td>

<td style="text-align:right;">

2001.827

</td>

<td style="text-align:right;">

352.914675

</td>

<td style="text-align:right;">

2479.037

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.731

</td>

<td style="text-align:right;">

1239.9999

</td>

<td style="text-align:right;">

599.79729

</td>

<td style="text-align:right;">

2059.942

</td>

<td style="text-align:right;">

341.576076

</td>

<td style="text-align:right;">

2561.246

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.750

</td>

<td style="text-align:right;">

1586.8192

</td>

<td style="text-align:right;">

841.82882

</td>

<td style="text-align:right;">

2515.987

</td>

<td style="text-align:right;">

529.059068

</td>

<td style="text-align:right;">

3077.305

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.769

</td>

<td style="text-align:right;">

1145.4840

</td>

<td style="text-align:right;">

495.65971

</td>

<td style="text-align:right;">

2003.464

</td>

<td style="text-align:right;">

246.587375

</td>

<td style="text-align:right;">

2534.866

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.788

</td>

<td style="text-align:right;">

1478.1996

</td>

<td style="text-align:right;">

719.66991

</td>

<td style="text-align:right;">

2447.919

</td>

<td style="text-align:right;">

412.840886

</td>

<td style="text-align:right;">

3040.319

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.808

</td>

<td style="text-align:right;">

1559.4992

</td>

<td style="text-align:right;">

761.38736

</td>

<td style="text-align:right;">

2579.013

</td>

<td style="text-align:right;">

438.145651

</td>

<td style="text-align:right;">

3201.616

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.827

</td>

<td style="text-align:right;">

1715.4250

</td>

<td style="text-align:right;">

859.09389

</td>

<td style="text-align:right;">

2801.440

</td>

<td style="text-align:right;">

508.376572

</td>

<td style="text-align:right;">

3462.528

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.846

</td>

<td style="text-align:right;">

1791.6090

</td>

<td style="text-align:right;">

897.32272

</td>

<td style="text-align:right;">

2925.733

</td>

<td style="text-align:right;">

531.047138

</td>

<td style="text-align:right;">

3616.097

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.865

</td>

<td style="text-align:right;">

1013.4592

</td>

<td style="text-align:right;">

335.34448

</td>

<td style="text-align:right;">

1970.683

</td>

<td style="text-align:right;">

108.677451

</td>

<td style="text-align:right;">

2579.051

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.885

</td>

<td style="text-align:right;">

839.5570

</td>

<td style="text-align:right;">

218.85990

</td>

<td style="text-align:right;">

1763.057

</td>

<td style="text-align:right;">

39.099507

</td>

<td style="text-align:right;">

2360.668

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.904

</td>

<td style="text-align:right;">

576.3501

</td>

<td style="text-align:right;">

75.87813

</td>

<td style="text-align:right;">

1417.221

</td>

<td style="text-align:right;">

\-5.369715

</td>

<td style="text-align:right;">

1980.864

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.923

</td>

<td style="text-align:right;">

546.2406

</td>

<td style="text-align:right;">

57.43812

</td>

<td style="text-align:right;">

1394.299

</td>

<td style="text-align:right;">

\-15.118509

</td>

<td style="text-align:right;">

1967.324

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.942

</td>

<td style="text-align:right;">

641.2969

</td>

<td style="text-align:right;">

91.48252

</td>

<td style="text-align:right;">

1553.758

</td>

<td style="text-align:right;">

\-2.874389

</td>

<td style="text-align:right;">

2163.432

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.962

</td>

<td style="text-align:right;">

1787.7802

</td>

<td style="text-align:right;">

790.83598

</td>

<td style="text-align:right;">

3096.340

</td>

<td style="text-align:right;">

404.744713

</td>

<td style="text-align:right;">

3904.834

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.981

</td>

<td style="text-align:right;">

1348.9050

</td>

<td style="text-align:right;">

476.08698

</td>

<td style="text-align:right;">

2562.272

</td>

<td style="text-align:right;">

173.956727

</td>

<td style="text-align:right;">

3329.123

</td>

</tr>

<tr>

<td style="text-align:left;">

2017.000

</td>

<td style="text-align:right;">

688.6181

</td>

<td style="text-align:right;">

93.07380

</td>

<td style="text-align:right;">

1685.245

</td>

<td style="text-align:right;">

\-5.234278

</td>

<td style="text-align:right;">

2352.607

</td>

</tr>

</tbody>

</table>

``` r
# Final forecast using ANN
final_forecast <-  nnetar(retail_ts, p = 25, P = 1, size = 12, 
                        lambda = new_BC, decay = 0.9) %>% 
  forecast(h = 22, PI = TRUE) 

autoplot(final_forecast)
```

![](Retail-Sales_files/figure-gfm/unnamed-chunk-28-1.png)<!-- -->

<table>

<thead>

<tr>

<th style="text-align:left;">

</th>

<th style="text-align:right;">

Point Forecast

</th>

<th style="text-align:right;">

Lo 80

</th>

<th style="text-align:right;">

Hi 80

</th>

<th style="text-align:right;">

Lo 95

</th>

<th style="text-align:right;">

Hi 95

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

2016.596

</td>

<td style="text-align:right;">

806.7986

</td>

<td style="text-align:right;">

558.7738

</td>

<td style="text-align:right;">

1065.8451

</td>

<td style="text-align:right;">

464.8410

</td>

<td style="text-align:right;">

1210.1334

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.615

</td>

<td style="text-align:right;">

556.8996

</td>

<td style="text-align:right;">

348.3859

</td>

<td style="text-align:right;">

785.2831

</td>

<td style="text-align:right;">

254.3701

</td>

<td style="text-align:right;">

916.9358

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.635

</td>

<td style="text-align:right;">

850.2842

</td>

<td style="text-align:right;">

577.4931

</td>

<td style="text-align:right;">

1125.0753

</td>

<td style="text-align:right;">

466.3530

</td>

<td style="text-align:right;">

1243.6036

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.654

</td>

<td style="text-align:right;">

952.0997

</td>

<td style="text-align:right;">

690.0166

</td>

<td style="text-align:right;">

1222.2624

</td>

<td style="text-align:right;">

547.4676

</td>

<td style="text-align:right;">

1392.1135

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.673

</td>

<td style="text-align:right;">

901.7683

</td>

<td style="text-align:right;">

648.4095

</td>

<td style="text-align:right;">

1168.8499

</td>

<td style="text-align:right;">

538.2191

</td>

<td style="text-align:right;">

1362.8042

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.692

</td>

<td style="text-align:right;">

1136.0660

</td>

<td style="text-align:right;">

836.8552

</td>

<td style="text-align:right;">

1459.3983

</td>

<td style="text-align:right;">

685.5304

</td>

<td style="text-align:right;">

1650.9225

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.712

</td>

<td style="text-align:right;">

894.2792

</td>

<td style="text-align:right;">

629.6606

</td>

<td style="text-align:right;">

1158.1276

</td>

<td style="text-align:right;">

495.5098

</td>

<td style="text-align:right;">

1334.7598

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.731

</td>

<td style="text-align:right;">

1036.2949

</td>

<td style="text-align:right;">

749.9622

</td>

<td style="text-align:right;">

1312.3906

</td>

<td style="text-align:right;">

631.3059

</td>

<td style="text-align:right;">

1514.8875

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.750

</td>

<td style="text-align:right;">

1108.4998

</td>

<td style="text-align:right;">

821.6257

</td>

<td style="text-align:right;">

1423.4045

</td>

<td style="text-align:right;">

685.7290

</td>

<td style="text-align:right;">

1640.4615

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.769

</td>

<td style="text-align:right;">

1034.6873

</td>

<td style="text-align:right;">

773.8992

</td>

<td style="text-align:right;">

1342.7373

</td>

<td style="text-align:right;">

627.3342

</td>

<td style="text-align:right;">

1538.4046

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.788

</td>

<td style="text-align:right;">

1175.6466

</td>

<td style="text-align:right;">

874.9240

</td>

<td style="text-align:right;">

1511.3413

</td>

<td style="text-align:right;">

725.9806

</td>

<td style="text-align:right;">

1652.3637

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.808

</td>

<td style="text-align:right;">

1050.3305

</td>

<td style="text-align:right;">

783.7763

</td>

<td style="text-align:right;">

1379.6089

</td>

<td style="text-align:right;">

635.1583

</td>

<td style="text-align:right;">

1529.6948

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.827

</td>

<td style="text-align:right;">

1383.3447

</td>

<td style="text-align:right;">

1078.5271

</td>

<td style="text-align:right;">

1709.6232

</td>

<td style="text-align:right;">

916.3351

</td>

<td style="text-align:right;">

1958.6312

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.846

</td>

<td style="text-align:right;">

1045.3212

</td>

<td style="text-align:right;">

759.6644

</td>

<td style="text-align:right;">

1336.9065

</td>

<td style="text-align:right;">

634.0792

</td>

<td style="text-align:right;">

1506.3281

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.865

</td>

<td style="text-align:right;">

1075.5553

</td>

<td style="text-align:right;">

780.1022

</td>

<td style="text-align:right;">

1381.2414

</td>

<td style="text-align:right;">

646.5060

</td>

<td style="text-align:right;">

1557.6861

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.885

</td>

<td style="text-align:right;">

1359.2906

</td>

<td style="text-align:right;">

1047.1352

</td>

<td style="text-align:right;">

1692.6176

</td>

<td style="text-align:right;">

904.5881

</td>

<td style="text-align:right;">

1918.9045

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.904

</td>

<td style="text-align:right;">

1332.2719

</td>

<td style="text-align:right;">

1006.4573

</td>

<td style="text-align:right;">

1685.1206

</td>

<td style="text-align:right;">

871.2713

</td>

<td style="text-align:right;">

1847.1331

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.923

</td>

<td style="text-align:right;">

1456.0301

</td>

<td style="text-align:right;">

1108.9674

</td>

<td style="text-align:right;">

1817.1342

</td>

<td style="text-align:right;">

945.8088

</td>

<td style="text-align:right;">

2068.6951

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.942

</td>

<td style="text-align:right;">

1179.4721

</td>

<td style="text-align:right;">

861.9838

</td>

<td style="text-align:right;">

1498.0089

</td>

<td style="text-align:right;">

727.8305

</td>

<td style="text-align:right;">

1666.2616

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.962

</td>

<td style="text-align:right;">

1306.4934

</td>

<td style="text-align:right;">

1007.3465

</td>

<td style="text-align:right;">

1627.5277

</td>

<td style="text-align:right;">

843.0407

</td>

<td style="text-align:right;">

1805.3694

</td>

</tr>

<tr>

<td style="text-align:left;">

2016.981

</td>

<td style="text-align:right;">

1384.6840

</td>

<td style="text-align:right;">

1050.5374

</td>

<td style="text-align:right;">

1730.7888

</td>

<td style="text-align:right;">

930.0929

</td>

<td style="text-align:right;">

1911.8129

</td>

</tr>

<tr>

<td style="text-align:left;">

2017.000

</td>

<td style="text-align:right;">

1089.4393

</td>

<td style="text-align:right;">

807.4420

</td>

<td style="text-align:right;">

1374.4389

</td>

<td style="text-align:right;">

669.3809

</td>

<td style="text-align:right;">

1542.4156

</td>

</tr>

</tbody>

</table>

## Bibliografía

Hyndman, R.J., Athanasopoulos, 2019. Forecasting: Principles & Practice,
3rd edition. ed. OTexts, Melbourne, Australia.

Hyndman, R.J., Khandakar, Y., 2008. Automatic Time Series Forecasting:
The forecast Package for R. J. Stat. Soft. 27.
<https://doi.org/10.18637/jss.v027.i03>

Ljung, G.M., Box, G.E.P., 1978. On a Measure of Lack of Fit in Time
Series Models. Biometrika 65, 297–303.

Ryan, J.A. and Ulrich,J.M., 2020. xts: eXtensible Time Series. R package
version 0.12.1. <https://CRAN.R-project.org/package=xts>

Wickham, H., 2017. Easily Install and Load the “Tidyverse”. R package
version.

Wickham, H., Averick, M., Bryan, J., Chang, W., McGowan, L., François,
R., Grolemund, G., Hayes, A., Henry, L., Hester, J., Kuhn, M., Pedersen,
T., Miller, E., Bache, S., Müller, K., Ooms, J., Robinson, D., Seidel,
D., Spinu, V., Takahashi, K., Vaughan, D., Wilke, C., Woo, K., Yutani,
H., 2019. Welcome to the Tidyverse. Journal of Open Source Software 4,
1686. <https://doi.org/10.21105/joss.01686>

Zeileis, A., Grothendieck, G., 2005. zoo: S3 Infrastructure for Regular
and Irregular Time Series. Journal of Statistical Software 14.
<https://doi.org/10.18637/jss.v014.i06>
