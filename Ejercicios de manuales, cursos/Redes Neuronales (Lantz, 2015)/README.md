## Introducción  

En este ejemplo de código se presenta un análisis de **regresión por medio de redes neuronales** para modelar la fuerza del cemento. El ejemplo corresponde al capítulo de Lantz (2019) sobre redes nueronales, mientras que el dataset procede de Yeh (1998) y está disponible en: http://archive.ics.uci.edu/ml/datasets/Concrete+Compressive+Strength.  

## Flujo de trabajo:   

El objetivo es un **análisis de regresión** para modelar la fuerza del cemento en base a determinados componentes. El flujo de trabajo seguido es el siguiente:  

  1) Carga y procesamiento de los datos  
  2) **Normalización de los datos**  
  3) **Barajado de los datos** para evitar sesgos en la generación del train/test sets  
  4) Entrenamiento de una **red neuronal** usando el paquete **neuralnet**   
  5) Validación y precisado del modelo   
  6) Selección y entrenamiento de un modelo con **mejores hiperparámetros**  
  7) Validación y precisado del nuevo modelo

## Resultados  

El mejor modelo de 5 *hidden layers* presenta una *r* de 0.9390418 (<img src="https://render.githubusercontent.com/render/math?math=r^2 = 8818">).   

## Bibliografía  

Lantz, B., 2019. Machine Learning with R, Third Edition. ed. Packt Publishing Ltd., Birmingham.   

Yeh IC. Modeling of strength of high performance concrete using artificial neural networks. Cement and Concrete Research. 1998; 28:1797-1808  

