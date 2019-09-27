# Install Apache Spark on Windows
This repository contains a powershell script to install Apache Spark on Windows 10 automatically.
The goal is to create an environment on a personal computer for developing and testing routines for processing large-scale data using Spark. 
However, spark will use only the number of cores of your pc, so you will not have the distributed computing capabilities presented in cloud systems like Microsoft Azure, AWS, etc...

I don't recommend using it for a production environment.


## Programs that will be installed:
1. Scala
2. Java SDK 1.8
3. Maven
4. Miniconda3
5. Hadoop Winutils 2.7.1
6. Apache Spark with Hadoop 2.7
7. The environment variables on the User-level required to execute Spark and Pyspark.


## How to install?

1. Download the script "spark-install.ps1".
2. Open Powershell x86
3. cd to the root folder where you downloaded the script.
4. Execute the following command:

```
powershell -executionpolicy bypass -File .\spark-install.ps1
```
5. Follow the instructions.

## How to test if apache spark works?

* Open a CMD shell and execute:
```
> spark-shell
```
