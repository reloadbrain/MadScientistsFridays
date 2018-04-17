##########################################################
#       Real Time Logistic Regression Model Example        #
##########################################################

# For R Server 9.0, load mrsdeploy package on R Server     
library(mrsdeploy)
options(digits=10)

# We build a larger Logistic REgression Model
# On a larger airline dataset 
# to articulate a larger Open Source R model built (30MB RData File)
# This increases the latency for real-time scoring


library(randomForest)

# Create randomForest model on Large Airline Dataset
load("sampleData.RData")

rxLogitModel <- rxLogit(Cancelled ~ DayofMonth + DayOfWeek + Distance +
    ArrDelay + DepDelay, data = sampleData)
summary(rxLogitModel)

##Check Size of R Object
object.size(LogitModel)

##Predict Locally

testData <- data.frame(DayofMonth = 15, DayOfWeek = "Monday", Distance = 550,
        ArrDelay = 20, DepDelay = 15)

testData <- sampleData[100,c("DayofMonth","DayOfWeek","Distance","ArrDelay","DepDelay")]
rxPredict(rxLogitModel, data = testData) # Kyphosis_Pred: 0.005074613

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
#             Publish Model as a Real Time Service       #
##########################################################

# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName <- "mtServiceRealTime"

# Publish as service using publishService() function. 
# Use the variable name for the service and version `v1.0`
# Assign service to the variable `realtimeApi`.
realtimeApi <- publishService(
     serviceType = "Realtime",
     name = serviceName,
     code = NULL,
     model = rxLogitModel,
     v = "v1.0",
     alias = "mtServiceRealTime"
)


##########################################################
#                 Consume Service in R                   #
##########################################################
print(realtimeApi$capabilities())

# Consume service by calling function contained in this service
realtimeResult <- realtimeApi$mtServiceRealTime(testData)

# Print response output
print(realtimeResult$outputParameters) # 0.6418125


##########################################################
#       Speed Execution Test                            ##
##########################################################

results <- numeric()
nCounter <- 10

for (i in 1:nCounter) {
    start.time <- as.numeric(Sys.time(),digits=15)
    realtimeApi$mtServiceRealTime(testData)
    end.time <- as.numeric(Sys.time(), digits = 15)
    results[i] <- end.time-start.time
    print(results[i],digits=10)
}


mean(results)


##########################################################
#          Delete service version when finished          #
##########################################################

# User who published service or user with owner role can
# remove the service when it is no longer needed
status <- deleteService(serviceName, "v1.0")
status

##########################################################
#                   Log off of R Server                  #
##########################################################

# Log off of R Server
remoteLogout()












##          REALTIME WEB SERVICE EXAMPLE                ##

##########################################################
#   Create/Test GLM Classification Model with rxGlm   #
##########################################################

carsModel2 <- rxLogit(am ~ hp + wt, data = mtcars)


# Test the model locally
testData <- data.frame(hp = c(120), wt = c(2.8))
rxPredict(carsModel2, data = testData) # Kyphosis_Pred: 0.1941938

##########################################################
#            Log into Microsoft R Server                 #
##########################################################

# Use `remoteLogin` to authenticate with R Server using 
# the local admin account. Use session = false so no 
# remote R session started
# REMEMBER: replace with the login info for your organization
remoteLogin("http://readydemobaai313.westus2.cloudapp.azure.com:12800",
            username = "admin",
            password = "P@ssword1234",
            session = FALSE)

##########################################################
#    Publish GLM Model as a Realtime Service        #
##########################################################

# Generate a unique serviceName for demos 
# and assign to variable serviceName
serviceName <- "mtServiceRealTime"

# Publish as service using publishService() function. 
# Use the variable name for the service and version `v1.0`
# Assign service to the variable `realtimeApi`.
realtimeApi <- publishService(
     serviceType = "Realtime",
     name = serviceName,
     code = NULL,
     model = carsModel2,
     v = "v1.0",
     alias = "mtServiceRealTime"
)

##########################################################
#           Consume Realtime Service in R                #
##########################################################

# Print capabilities that define the service holdings: service 
# name, version, descriptions, inputs, outputs, and the 
# name of the function to be consumed
print(realtimeApi$capabilities())

# Consume service by calling function contained in this service
realtimeResult <- realtimeApi$mtServiceRealTime(testData)

# Print response output
print(realtimeResult$outputParameters) # 0.6418125

########################################
for (i in 1:20) {
    a <- system.time(result <- realtimeApi$mtServiceRealTime(testData))
    print(a)
}



##########################################################
#         Get Service-specific Swagger File in R         #
##########################################################

# During this authenticated session, download the  
# Swagger-based JSON file that defines this service
rtSwagger <- realtimeApi$swagger()
cat(rtSwagger, file = "realtimeSwagger.json", append = FALSE)

# Share Swagger-based JSON with those who need to consume it