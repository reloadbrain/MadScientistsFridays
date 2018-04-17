##########################################################
#       Create & Test a Logistic Regression Model        #
##########################################################

# For R Server 9.0, load mrsdeploy package on R Server     
library(mrsdeploy)

# We build a larger Logistic REgression Model
# On a larger airline dataset 
# to articulate a larger Open Source R model built (30MB RData File)
# This increases the latency for real-time scoring


library(randomForest)

# Create randomForest model on Large Airline Dataset
load("sampleData.RData")

LogitModel <- glm(Cancelled ~ DayofMonth + DayOfWeek + Distance +
    ArrDelay + DepDelay, data = sampleData, family=binomial())
summary(LogitModel)

##Check Size of R Object
object.size(LogitModel)

# Produce a prediction function that can use the model
FlightCancellation <- function(DayofMonth, DayOfWeek, Distance,
    ArrDelay, DepDelay) {
    library(randomForest)
    library(ggplot2)
    newdata <- data.frame(DayofMonth = DayofMonth, DayOfWeek = DayOfWeek,
            Distance = Distance, ArrDelay = ArrDelay, DepDelay = DepDelay)
    predict(LogitModel, newdata, type = "response")
}

# test function locally by printing results
print(FlightCancellation(15, "Monday", 550, 20, 15)) # 0.00786

##########################################################
#            Log into Microsoft R Server                 #
##########################################################

# Use `remoteLogin` to authenticate with R Server using 
# the local admin account. Use session = false so no 
# remote R session started
# REMEMBER: Replace with your login details
remoteLogin("http://readydemobaai313.westus2.cloudapp.azure.com:12800",
            username = "admin",
            password = "P@ssword1234",
            session = FALSE)

##########################################################
#             Publish Model as a Service                 #
##########################################################

# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName <- "mtServiceStandard01"

# Publish as service using publishService() function from 
# mrsdeploy package. Use the service name variable and provide
# unique version number. Assign service to the variable `api`

##Do Not run code below will take 15 minutes to upload model
api <- publishService(
     serviceName,
     code = FlightCancellation,
     model = LogitModel,
     inputs = list(DayofMonth = "numeric", DayOfWeek = "character", Distance = "numeric",
                    ArrDelay = "numeric", DepDelay = "numeric"),
     outputs = list(answer = "numeric"),
     v = "v1.0.0"
)

api <- getService(name = serviceName)


##########################################################
#                 Consume Service in R                   #
##########################################################

# Print capabilities that define the service holdings: service 
# name, version, descriptions, inputs, outputs, and the 
# name of the function to be consumed
print(api$capabilities())

# Consume service by calling function, `manualTransmission`
# contained in this service
result <- api$FlightCancellation(15, "Monday", 550, 20, 15)



# Print response output named `answer`
print(result$output("answer")) # 0.007864  


##########################################################
#       Speed Execution Test                            ##
##########################################################

results <- numeric()
nCounter <- 10

for (i in 1:nCounter) {
    start.time <- as.numeric(Sys.time(), digits = 15)
    api$FlightCancellation(15, "Monday", 550, 20, 15)
    end.time <- as.numeric(Sys.time(), digits = 15)
    results[i] <- end.time - start.time
    print(results[i], digits = 10)
}


mean(results)


#############################
## Optimize         #########

FlightCancellationLoad <- function(DayofMonth, DayOfWeek, Distance,
    ArrDelay, DepDelay) {
    load("C:\\Models\\LogisticModel.RData")
    library(randomForest)
    library(ggplot2)
    newdata <- data.frame(DayofMonth = DayofMonth, DayOfWeek = DayOfWeek,
            Distance = Distance, ArrDelay = ArrDelay, DepDelay = DepDelay)
    predict(LogitModel, newdata, type = "response")
    }



# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName <- "mtServiceStandard02"

api <- publishService(
     serviceName,
     code = FlightCancellationLoad,
     inputs = list(DayofMonth = "numeric", DayOfWeek = "character", Distance = "numeric",
                    ArrDelay = "numeric", DepDelay = "numeric"),
     outputs = list(answer = "numeric"),
     v = "v1.0.0"
)

api <- getService(name = serviceName)


##########################################################
#       Speed Execution Test                            ##
##########################################################

results <- numeric()
nCounter <- 10

for (i in 1:nCounter) {
    start.time <- as.numeric(Sys.time(), digits = 15)
    api$FlightCancellationLoad(15, "Monday", 550, 20, 15)
    end.time <- as.numeric(Sys.time(), digits = 15)
    results[i] <- end.time - start.time
    print(results[i], digits = 10)
    
}

mean(results)


##########################################################
#          Delete service version when finished          #
##########################################################

# User who published service or user with owner role can
# remove the service when it is no longer needed
status <- deleteService(serviceName, "v1.0.0")
status

##########################################################
#                   Log off of R Server                  #
##########################################################

# Log off of R Server
remoteLogout()