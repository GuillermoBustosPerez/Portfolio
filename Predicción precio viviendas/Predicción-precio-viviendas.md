Predicción precio viviendas
================

## Introducción

Mencionabamos en el inicio que se trata de un **ejercicio clásico de
regeresión** (predecir un outcome numérico).

En este caso vamos a emplear la base de datos de viviendas de King
County (Washington State, USA). Se trata de un datset de 21613 viviendas
con 21 variables asociadas al precio.

El dataset está disponible en:  
<https://www.kaggle.com/shivachandel/kc-house-data>

``` r
# Read in the data
housing <- read.csv("Data/kc_house_data.csv")
```

``` r
# Get dimensions of dataset
dim(housing)
```

    ## [1] 21613    21

``` r
# Instead of head
kable(housing[1:5,])
```

<table>

<thead>

<tr>

<th style="text-align:right;">

id

</th>

<th style="text-align:left;">

date

</th>

<th style="text-align:right;">

price

</th>

<th style="text-align:right;">

bedrooms

</th>

<th style="text-align:right;">

bathrooms

</th>

<th style="text-align:right;">

sqft\_living

</th>

<th style="text-align:right;">

sqft\_lot

</th>

<th style="text-align:right;">

floors

</th>

<th style="text-align:right;">

waterfront

</th>

<th style="text-align:right;">

view

</th>

<th style="text-align:right;">

condition

</th>

<th style="text-align:right;">

grade

</th>

<th style="text-align:right;">

sqft\_above

</th>

<th style="text-align:right;">

sqft\_basement

</th>

<th style="text-align:right;">

yr\_built

</th>

<th style="text-align:right;">

yr\_renovated

</th>

<th style="text-align:right;">

zipcode

</th>

<th style="text-align:right;">

lat

</th>

<th style="text-align:right;">

long

</th>

<th style="text-align:right;">

sqft\_living15

</th>

<th style="text-align:right;">

sqft\_lot15

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

7129300520

</td>

<td style="text-align:left;">

20141013T000000

</td>

<td style="text-align:right;">

221900

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

1.00

</td>

<td style="text-align:right;">

1180

</td>

<td style="text-align:right;">

5650

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

1180

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1955

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98178

</td>

<td style="text-align:right;">

47.5112

</td>

<td style="text-align:right;">

\-122.257

</td>

<td style="text-align:right;">

1340

</td>

<td style="text-align:right;">

5650

</td>

</tr>

<tr>

<td style="text-align:right;">

6414100192

</td>

<td style="text-align:left;">

20141209T000000

</td>

<td style="text-align:right;">

538000

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

2.25

</td>

<td style="text-align:right;">

2570

</td>

<td style="text-align:right;">

7242

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

2170

</td>

<td style="text-align:right;">

400

</td>

<td style="text-align:right;">

1951

</td>

<td style="text-align:right;">

1991

</td>

<td style="text-align:right;">

98125

</td>

<td style="text-align:right;">

47.7210

</td>

<td style="text-align:right;">

\-122.319

</td>

<td style="text-align:right;">

1690

</td>

<td style="text-align:right;">

7639

</td>

</tr>

<tr>

<td style="text-align:right;">

5631500400

</td>

<td style="text-align:left;">

20150225T000000

</td>

<td style="text-align:right;">

180000

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1.00

</td>

<td style="text-align:right;">

770

</td>

<td style="text-align:right;">

10000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

770

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1933

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98028

</td>

<td style="text-align:right;">

47.7379

</td>

<td style="text-align:right;">

\-122.233

</td>

<td style="text-align:right;">

2720

</td>

<td style="text-align:right;">

8062

</td>

</tr>

<tr>

<td style="text-align:right;">

2487200875

</td>

<td style="text-align:left;">

20141209T000000

</td>

<td style="text-align:right;">

604000

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

3.00

</td>

<td style="text-align:right;">

1960

</td>

<td style="text-align:right;">

5000

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

1050

</td>

<td style="text-align:right;">

910

</td>

<td style="text-align:right;">

1965

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98136

</td>

<td style="text-align:right;">

47.5208

</td>

<td style="text-align:right;">

\-122.393

</td>

<td style="text-align:right;">

1360

</td>

<td style="text-align:right;">

5000

</td>

</tr>

<tr>

<td style="text-align:right;">

1954400510

</td>

<td style="text-align:left;">

20150218T000000

</td>

<td style="text-align:right;">

510000

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

2.00

</td>

<td style="text-align:right;">

1680

</td>

<td style="text-align:right;">

8080

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

1680

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1987

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98074

</td>

<td style="text-align:right;">

47.6168

</td>

<td style="text-align:right;">

\-122.045

</td>

<td style="text-align:right;">

1800

</td>

<td style="text-align:right;">

7503

</td>

</tr>

</tbody>

</table>

 

En este caso vamos a realizar una regresión lineal múltiple con la mejor
sub-selección de variables. Recordamos algunos de los principios básicos
de la regresión lineal:

  - Asume que la relación entre la variable dependiente (*Y*) y las
    variables predictoras
    (<img src="https://render.githubusercontent.com/render/math?math=X_1, X_2, X_3...X_n">)
    es lineal.
      - Por consiguiente, si la regresión lineal simple asume que:

<img src="https://render.githubusercontent.com/render/math?math=Y=\beta_0+\beta_1X+\epsilon">

``` r
colnames(housing)
```

    ##  [1] "id"            "date"          "price"         "bedrooms"     
    ##  [5] "bathrooms"     "sqft_living"   "sqft_lot"      "floors"       
    ##  [9] "waterfront"    "view"          "condition"     "grade"        
    ## [13] "sqft_above"    "sqft_basement" "yr_built"      "yr_renovated" 
    ## [17] "zipcode"       "lat"           "long"          "sqft_living15"
    ## [21] "sqft_lot15"

``` r
housing_reg <- housing %>% 
  select(-c(id, date, zipcode, lat, long))

colnames(housing_reg)
```

    ##  [1] "price"         "bedrooms"      "bathrooms"     "sqft_living"  
    ##  [5] "sqft_lot"      "floors"        "waterfront"    "view"         
    ##  [9] "condition"     "grade"         "sqft_above"    "sqft_basement"
    ## [13] "yr_built"      "yr_renovated"  "sqft_living15" "sqft_lot15"

 

Ahora tenemos que tener cuidad con las variables que muestran un alto
grado de colinearidad: variables predictivas que tienen un altto grado
de correlación. Esto se debe a que la colinearidad entre variables
predictivas genera alteraciones en los signos de los coeficientes,
dificultando su intepretabilidad.

``` r
# Correlation matrix
cor <-cor(housing_reg[,-c(6,7,8,9, 10)])

# Plot
corrplot::corrplot(cor, method = "color",
                   addCoef.col = TRUE,
                   number.font = 2,
                   number.cex = 0.75,
                   type = "lower",
                   sig.level = 0.001,
                   insig = "blank")
```

![](Predicción-precio-viviendas_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->
