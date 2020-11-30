## Introducción  

Determinar el precio de una vivienda es una tarea común que depende de diversos factores, como la localización, tamaño, antiguedad del inmueble, etc.   

Este es un **ejercicio clásico de regresión** en el que se prueban diferentes modelos para **determinar el precio de una vivienda**.   

Este ejemplo se divide en los  siguientes apartados:    

* Análisis exploratorio de los datos   
* Entrenamiento y evaluación de un **modelo de regresión lineal múltiple** con la **mejor sub-selección de predictores**.    
* Modelo de regresión lineal múltiple con transformación logarítmica de la variable a predecir (precio) y estandarización de los predictores.    
* Modelo de regresión de Random Forest con selección de hiperparámetros

| Model | MAE | RMSE | MAPE | Correlation |    
|-------|-----|------|------|------------------------------|     
| Multiple Linear Regression | 126982.2 | 202401.4 | 0.26 | 0.70 |     
| Mult. Linear Reg. Log scale | 0.09 | 0.11 | 0.02 | 0.76 |    
| Random Forest Regression | 0.06 | 0.08 | 0.01 | 0.88 |    

Los modelos, además de determinar el precio de una vivienda, permiten **determinar qué factores estan influyendo el valor de las viviendas** (posición respecto a la latitud, tamaño habitable, año de construcción, etc.).   
Finalmente los **valores de precios conocidos y predicción de precios son reconvertidos a la escala lineal**, junto con un **rango de estimaión de precios**.  

\ 

### Regresión lineal múltiple   

Empezamos por entrenar una **regresión lineal múltiple**. Esto se debe a que:      

* Sirve como **referencia del mínimo exigible al resto de los modelos**   
* Ofrece una **fácil interpretabilidad**   
* Aunque no es siempre correcta, nunca está completamnete equivocada  

### Regresión lineal múltiple con transformación logarítmica de la variable dependiente y estandarización de las variables independientes   

En este caso la transformación logarítmica del precio permite obtener una distribución paramétrica de los datos y evitar obtener valores negativos en las predicciones. La estandarización de variables predictivas es un procedimiento común para variables en diferentes escalas, y que facilita la interpretación de coeficientes, resultando en modelos más precisos.   

### Modelo de regresión de Random Forest con selección de hiperparámetros   

Los random forests combinan la fuerza de los árboles de decisión junto con la capacidad de modelar datos numéricos, relaciones no lineales entre los datos y la variable dependiente, y la habilidad de modelar una gran cantidad de variables. La modificación de los hiperparámetros permite en muchos casos mejorar las predicciones del modelo.  