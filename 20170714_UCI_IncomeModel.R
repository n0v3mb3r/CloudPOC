## Sample R Code

library('glmnet')
library('doParallel')

data <- read.csv('https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data',header = FALSE)
colnames(data) <- c('age',
                    'workclass',
                    'fnlwgt',
                    'education',
                    'education-num',
                    'marital-status',
                    'occupation',
                    'relationship',
                    'race',
                    'sex',
                    'capital-gain',
                    'capital-loss',
                    'hours-per-week',
                    'native-country',
                    'income_level')
attach(data)
data$response[income_level == " <=50K"] <- 0
data$response[income_level == " >50K"] <- 1
detach(data)

data$income_level <- NULL
data$age <- as.numeric(data$age)
data$fnlwgt <- as.numeric(data$fnlwgt)
data$`education-num` <- as.numeric(data$`education-num`)
data$`capital-gain` <- as.numeric(data$`capital-gain`)
data$`capital-loss` <- as.numeric(data$`capital-loss`)
data$`hours-per-week` <- as.numeric(data$`hours-per-week`)

x.data <- model.matrix(response ~ ., data)
y.data <- data$response

train.glm <- glmnet(x.data, y.data, alpha = .5, family = "binomial")
parallelCluster <- parallel::makeCluster(parallel::detectCores())
registerDoParallel(parallelCluster, cores = numCores)
clusterCall(parallelCluster,function(x) .libPaths(x), .libPaths())
clusterEvalQ(parallelCluster, library(doParallel))

train.glm.cv <- cv.glmnet(x.data, y.data, alpha = .5, family = "binomial", type.measure = "auc", parallel = TRUE)

