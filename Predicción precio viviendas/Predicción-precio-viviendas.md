Predicción precio viviendas
================

## Introducción

Mencionabamos en el inicio que se trata de un **ejercicio clásico de
regeresión** (predecir un outcome numérico).

En este caso vamos a emplear la base de datos de dominio público de
viviendas de King County (Washington State, USA). Se trata de un datset
de 21613 viviendas con 21 variables asociadas al precio. Las ventas se
produjeron entre mayo de 2014 y mayo de 2015.

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
# Variable structure  
str(housing)
```

    ## 'data.frame':    21613 obs. of  21 variables:
    ##  $ id           : num  7.13e+09 6.41e+09 5.63e+09 2.49e+09 1.95e+09 ...
    ##  $ date         : chr  "20141013T000000" "20141209T000000" "20150225T000000" "20141209T000000" ...
    ##  $ price        : num  221900 538000 180000 604000 510000 ...
    ##  $ bedrooms     : int  3 3 2 4 3 4 3 3 3 3 ...
    ##  $ bathrooms    : num  1 2.25 1 3 2 4.5 2.25 1.5 1 2.5 ...
    ##  $ sqft_living  : int  1180 2570 770 1960 1680 5420 1715 1060 1780 1890 ...
    ##  $ sqft_lot     : int  5650 7242 10000 5000 8080 101930 6819 9711 7470 6560 ...
    ##  $ floors       : num  1 2 1 1 1 1 2 1 1 2 ...
    ##  $ waterfront   : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ view         : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ condition    : int  3 3 3 5 3 3 3 3 3 3 ...
    ##  $ grade        : int  7 7 6 7 8 11 7 7 7 7 ...
    ##  $ sqft_above   : int  1180 2170 770 1050 1680 3890 1715 1060 1050 1890 ...
    ##  $ sqft_basement: int  0 400 0 910 0 1530 0 0 730 0 ...
    ##  $ yr_built     : int  1955 1951 1933 1965 1987 2001 1995 1963 1960 2003 ...
    ##  $ yr_renovated : int  0 1991 0 0 0 0 0 0 0 0 ...
    ##  $ zipcode      : int  98178 98125 98028 98136 98074 98053 98003 98198 98146 98038 ...
    ##  $ lat          : num  47.5 47.7 47.7 47.5 47.6 ...
    ##  $ long         : num  -122 -122 -122 -122 -122 ...
    ##  $ sqft_living15: int  1340 1690 2720 1360 1800 4760 2238 1650 1780 2390 ...
    ##  $ sqft_lot15   : int  5650 7639 8062 5000 7503 101930 6819 9711 8113 7570 ...

 

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

 

Ahora podemos comprobar si hay alguna casa representada más de una vez.
Esto no afecta en exceso al modelo, pero es interesante saber si durante
este periodo de tiempo se vendió una casa más de una vez.

``` r
# This should return TRUE
n_distinct(housing$id) == nrow(housing)
```

    ## [1] FALSE

 

``` r
housing$repeated <- duplicated(housing$id)

repeated <- housing %>% filter(repeated == TRUE)
```

``` r
kable(repeated[1:5,])
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

<th style="text-align:left;">

repeated

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

6021501535

</td>

<td style="text-align:left;">

20141223T000000

</td>

<td style="text-align:right;">

700000

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

1.50

</td>

<td style="text-align:right;">

1580

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

3

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

1290

</td>

<td style="text-align:right;">

290

</td>

<td style="text-align:right;">

1939

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98117

</td>

<td style="text-align:right;">

47.6870

</td>

<td style="text-align:right;">

\-122.386

</td>

<td style="text-align:right;">

1570

</td>

<td style="text-align:right;">

4500

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:right;">

4139480200

</td>

<td style="text-align:left;">

20141209T000000

</td>

<td style="text-align:right;">

1400000

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

3.25

</td>

<td style="text-align:right;">

4290

</td>

<td style="text-align:right;">

12103

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

3

</td>

<td style="text-align:right;">

11

</td>

<td style="text-align:right;">

2690

</td>

<td style="text-align:right;">

1600

</td>

<td style="text-align:right;">

1997

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98006

</td>

<td style="text-align:right;">

47.5503

</td>

<td style="text-align:right;">

\-122.102

</td>

<td style="text-align:right;">

3860

</td>

<td style="text-align:right;">

11244

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:right;">

7520000520

</td>

<td style="text-align:left;">

20150311T000000

</td>

<td style="text-align:right;">

240500

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

1.00

</td>

<td style="text-align:right;">

1240

</td>

<td style="text-align:right;">

12092

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

960

</td>

<td style="text-align:right;">

280

</td>

<td style="text-align:right;">

1922

</td>

<td style="text-align:right;">

1984

</td>

<td style="text-align:right;">

98146

</td>

<td style="text-align:right;">

47.4957

</td>

<td style="text-align:right;">

\-122.352

</td>

<td style="text-align:right;">

1820

</td>

<td style="text-align:right;">

7460

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:right;">

3969300030

</td>

<td style="text-align:left;">

20141229T000000

</td>

<td style="text-align:right;">

239900

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

1.00

</td>

<td style="text-align:right;">

1000

</td>

<td style="text-align:right;">

7134

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

1000

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1943

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98178

</td>

<td style="text-align:right;">

47.4897

</td>

<td style="text-align:right;">

\-122.240

</td>

<td style="text-align:right;">

1020

</td>

<td style="text-align:right;">

7138

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

<tr>

<td style="text-align:right;">

2231500030

</td>

<td style="text-align:left;">

20150324T000000

</td>

<td style="text-align:right;">

530000

</td>

<td style="text-align:right;">

4

</td>

<td style="text-align:right;">

2.25

</td>

<td style="text-align:right;">

2180

</td>

<td style="text-align:right;">

10754

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

1100

</td>

<td style="text-align:right;">

1080

</td>

<td style="text-align:right;">

1954

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

98133

</td>

<td style="text-align:right;">

47.7711

</td>

<td style="text-align:right;">

\-122.341

</td>

<td style="text-align:right;">

1810

</td>

<td style="text-align:right;">

6929

</td>

<td style="text-align:left;">

TRUE

</td>

</tr>

</tbody>

</table>

 

## Regresión lineal múltiple

En este caso vamos a realizar una regresión lineal múltiple con la mejor
sub-selección de variables. Recordamos algunos de los principios básicos
de la regresión lineal (James et al., 2013):

  - La regresión lineal Asume que la relación entre la variable
    dependiente (*Y*) y las variables predictoras
    (<img src="https://render.githubusercontent.com/render/math?math=X_1, X_2, X_3...X_n">)
    es lineal.
      - Por consiguiente, si la regresión lineal simple asume que:

<img src="https://latex.codecogs.com/gif.latex?Y&space;=&space;\beta_{0}&space;&plus;&space;\beta_{1}X&space;&plus;&space;\epsilon" title="Y = \beta_{0} + \beta_{1}X + \epsilon" />

  - Entonces la **regresión lineal mútiple asume**:

<img src="https://latex.codecogs.com/gif.latex?Y&space;=&space;\beta_{0}&space;&plus;&space;\beta_{1}X_{1}&space;&plus;&space;\beta_{2}X_{2}&space;&plus;&space;\beta_{n}X_{n}&space;&plus;&space;\epsilon" title="Y = \beta_{0} + \beta_{1}X_{1} + \beta_{2}X_{2} + \beta_{n}X_{n} + \epsilon" />

Siendo:

  - *Y* la variable de respuesta a predecir

  - *X* las variables predictoras

  - <img src="https://latex.codecogs.com/gif.latex?\beta_{n}" title="\beta_{0}" />:
    el intercept (constante que representa el punto de contacto de la
    recta en valor 0)

  - <img src="https://latex.codecogs.com/gif.latex?\beta_{n}" title="\beta_{n}" />:
    el coeficiente/parámetro de la variable.

  - <img src="https://latex.codecogs.com/gif.latex?\epsilon" title="\epsilon" />:
    corresponde al término de error

En la práctica puede decirse que

``` r
# Check column names 
colnames(housing)
```

    ##  [1] "id"            "date"          "price"         "bedrooms"     
    ##  [5] "bathrooms"     "sqft_living"   "sqft_lot"      "floors"       
    ##  [9] "waterfront"    "view"          "condition"     "grade"        
    ## [13] "sqft_above"    "sqft_basement" "yr_built"      "yr_renovated" 
    ## [17] "zipcode"       "lat"           "long"          "sqft_living15"
    ## [21] "sqft_lot15"    "repeated"

``` r
# Remove non-usefull columns
housing_reg <- housing %>% 
  select(-c(id, date, zipcode, lat, long))

colnames(housing_reg)
```

    ##  [1] "price"         "bedrooms"      "bathrooms"     "sqft_living"  
    ##  [5] "sqft_lot"      "floors"        "waterfront"    "view"         
    ##  [9] "condition"     "grade"         "sqft_above"    "sqft_basement"
    ## [13] "yr_built"      "yr_renovated"  "sqft_living15" "sqft_lot15"   
    ## [17] "repeated"

 

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

![](Predicción-precio-viviendas_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

 

## Bibliografía

James, G., Witten, D., Hastie, T., Tibshirani, R., 2013. An Introduction
to Statistical Learning, Springer Texts in Statistics. Springer New
York, New York, NY. <https://doi.org/10.1007/978-1-4614-7138-7>
