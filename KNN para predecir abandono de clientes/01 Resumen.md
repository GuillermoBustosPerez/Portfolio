## Resumen:  
Comunmente las compañías quieren predecir qué clientes abandonarán sus servicios (permite la realización de ofertas para retener al cliente o estimar pérdidas de ingresos).  
En este caso se emplea el dataset corresponde a una compañía de telecomunicaciones ficticia donde figura el abandono de los cleintes.  
El **objetivo** es entrenar un **algoritmo de KNN que permita identificar clientes que van a abandonar la compañía**.  

## Flujo de trabajo:  

  * Exploración de los datos y eliminado de variables no útiles  
  * Transformación de variables categóricas usando **dummy coding**  
  * Equilibrado del dataset   
  * Normalización de los datos y creación del train set y hold-out set  
  * Determinación del **valor óptimo de K**   
  * Entrenamiento del **modelo KNN** y estimación de precisión   
  * Prueba sobre el hold-out set   

## Resultados:  

El modelo presenta un buen grado de precisión. La AUC tiene un valor de 0.830    

Measure  | K-fold  | Hold-Out set |
----------|--------|-----------|
Accuracy  | 0.7485 |  0.7527   |
Balanced Accuracy | 0.7490  | 0.7508  |  
No Information Rate | 0.502  | 0.508  |  
Sensitivity | 0.8541  | 0.8658  | 
Specificity | 0.6439  | 0.6359  | 
