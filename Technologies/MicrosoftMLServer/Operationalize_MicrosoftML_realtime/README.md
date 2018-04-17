# BAAI313
Code for Microsoft Ready BAAI313

# Introduction

This is demo code for the MS Ready Talk TECH-BAAI313 - 50ms scoring with Microsoft R, 
A Customer's journey from SQL Server2016CTP3 to Microsoft R o16n

# What this Contains
## Demo1OperationalizeStandard.R

Code for the first demo on how to operationalize Open Source R models; specifically a
Logistic Regression Model. 

There are two parts to this code; first we send the model as part of the publish webservice
and this registers in the sqlite db of Microsoft R o16n

The second part saves the model on a local file-system and we load it off the native file
system at every execution call. 

## Demo2OperationalizeRealTime.R

Code for the second demo on Real-Time Operationalization of Microsoft R (ScaleR) models.


## LogisticModel.RData

The open-source Logistic Model used


## sampleData.RData

Sample Airline Dataset (50k rows)

# Prerequisites

* Microsoft R Client 9.1
* Microsoft R Server 9.1 with Microsoft R o16n 9.1 configured

To speed things up; use the DSVM Windows on Azure MarketPlace and open port 12800
for Microsoft R o16n. 
