# Explore a dataset on fireflies to identify factors that are most important for a thriving firefly population # #
# title: 'Essential conditions for sutvival of fireflies'
# author: 'Apurva Naik (@ Yvonne)'
# date: '20 April 2016'

library(dplyr) # data manipulation
library(lubridate) # dates
library(randomForest) # classification algorithm
library(ggplot2) # plots
library(ggthemes) # plots
library(ggmap) # maps
library(corrplot) # correlation plot
library(colorRamps) # color gradient for variable importance
library(RCurl) # pull .csv from url
library(DiagrammeR) # plot flowchart


# Data mining of the firefly dataset: Find what factors affect firefly population, predict the population numbers for the test set carved out of this data set
link = "https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/data/firefly.data1.csv"
x = getURL(link)
firefly = read.csv(textConnection(x))

# Change name of response variable
names(firefly)[42] = "Number"
firefly$Number = firefly$Number * 10

# Response variable "Population" ranges 5 values in multiples of 10. Convert it into a categorical variableconsisting of High, Medium or Low population density
Population = ifelse (firefly$Number > 11, "High", "Low")
table(Population)
firefly = data.frame(firefly, Population)

# Clean the data by replacing NULL, N/A with "No", etc.
firefly[firefly == "NULL"] = "No"
firefly[firefly == "N/A"] = "No"

# Observation.Date is not in a format lubridate() can process. Converting into the correct format
firefly$Observation.Date =  parse_date_time(firefly$Observation.Date, orders="mdy hm")

# Extract year and month from Observation.Date
firefly$Year = year(firefly$Observation.Date)
firefly$Month = month(firefly$Observation.Date)

# Find number of empty cells
sum(firefly == "")
sum(is.na(firefly))

# How many observations have no missing values?
dim(na.omit(firefly))

# Which variables have how many missing values?
apply(firefly, 2, function(x) length(which(is.na(x))))
# or
colSums(is.na(firefly))

# impute values for Light source with the most common
firefly$Street.Light..yards.away. = ifelse(is.na(firefly$Street.Light..yards.away.), "No", firefly$Street.Light..yards.away.)

# Analysis of continous variables | convert int to num and chr to factor| to refernce all coulumns by index
i <- sapply(firefly, is.integer)
firefly[i] <- lapply(firefly[i], as.numeric)

j <- sapply(firefly, is.character)
firefly[j] <- lapply(firefly[j], as.factor)

# Most columns seem to have atleast 230 NAs. Then there are some variables which have 11000 NAs. These cannot anyway be used in analysis. So keeping a threshold of 233 NAs remove else
firefly = firefly[, colSums(is.na(firefly)) < 233]

# get summary of all num columns by first creating a subset of all num columns and then calling the summary function
nums <- sapply(firefly, is.numeric)


# Of these, probably only Habitat.ID and Temperature are of use. We already have a Population based on Population.
# Maximum Temperature appears to be 8000! the fireflies are on fire! Probably a typo, will change this to 80
firefly$Temperature..F. = ifelse(firefly$Temperature..F. > 80, 80, firefly$Temperature..F.)

# Exclude irrelevant predictors
act.var = as.data.frame(firefly[, -c(37, 39, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50)])
#dim(act.var)

# compare plots to see which are the most effective variables
# create a subset of the response and most likely predictors for feature engineering

# create new variable for Country  and State by binning the most rare levels as 'Other'
length(unique(act.var$Country))
country.table = data.frame(table(act.var$Country))
country.table = country.table[order(-country.table$Freq), ]
noChange2 <- country.table$Var1[1:1]
act.var$newFactorCountry = (ifelse(act.var$Country %in% noChange2, act.var$Country, "Other"))
state.table = data.frame(table(act.var$State))
state.table = state.table[order(-state.table$Freq), ]
noChange1 = state.table$Var1[1:31]
act.var$newFactorState = (ifelse(act.var$State %in% noChange1, act.var$State, "Other"))

# convert chr to factor
i = sapply(act.var, is.character)
act.var[i] = lapply(act.var[i], as.factor)
str(act.var)

# move response variable to the 1st column for consistency
col_idx = grep("Population", names(act.var))
act.var = act.var[, c(col_idx, (1:ncol(act.var))[-col_idx])]
names(act.var)

# plot individual bar plots and proportion plots and identify the most relevant predictors
# Create two separate dataframes containing factor and numeric variables resp.
cat.var = sapply(act.var, is.factor)
cat.var = act.var[, cat.var]
cont.var = sapply(act.var, is.numeric)
cont.var = act.var[, cont.var]

# Print out all the plots to compare

# print 16 of them at once
par(mfrow = c(4,4))
for(i in 1:16) {
  mytitle = paste("my title is", colnames(cat.var[i]))
  barplot(table(cat.var[, 1], cat.var[,i]), ylim = c(0, 30000), ann = F, axes = F,las = 2, cex.names = 0.8, col = c("green1", "darkorange1"), main = colnames(cat.var[i]))
  axis(2,at=seq(0,30000,10000), las = 2)
  print(colnames(cat.var[i]))
}
for(i in 17:31) {
  mytitle = paste("my title is", colnames(cat.var[i]))
  barplot(table(cat.var[, 1], cat.var[,i]), ylim = c(0, 30000), ann = F, axes = F,las = 2, cex.names = 0.8, col = c("green1", "darkorange1"), main = colnames(cat.var[i]))
  axis(2,at=seq(0,30000,10000), las = 2)
  print(colnames(cat.var[i]))
}
for(i in 32:36) {
  mytitle = paste("my title is", colnames(cat.var[i]))
  barplot(table(cat.var[, 1], cat.var[,i]), ylim = c(0, 30000), ann = F, axes = F,las = 2, cex.names = 0.8, col = c("green1", "darkorange1"), main = colnames(cat.var[i]))
  axis(2,at=seq(0,30000,10000), las = 2)
  print(colnames(cat.var[i]))
}
dev.off()

# gauge correlation between cont.var
par(mfrow = c(1,1))
corrplot(cor(cont.var), method = "number", type = "lower")

# Delete all rows with NA. Rows with NA are just 0.7% of the total data. It's OK to delete them
act.var.no.na = na.omit(act.var)

# create a subset containig only the necessary predictors
firefly.full = as.data.frame(act.var.no.na[, -c(3, 6, 7, 12, 17, 19, 20, 21, 41, 42)])

# start Random Forest classification
print("Staring Random Forest")
rf.firefly = randomForest(Population~. , data = firefly.full, mtry = 5, n.trees = 600, importance = T, node.size = 300)
print("Classification over")

# Post process: error plot, importance plot, partial dependence plot
plot(rf.firefly)
legend('topright', colnames(rf.firefly$err.rate), col = 1:6, fill = 1:6)

# Plot relative importance

# Get importance
importance = as.data.frame(importance(rf.firefly))
# create a relative importance variable that is highest for the most important predictor
importance.max = max(importance$MeanDecreaseGini, na.rm = T)
importance$RelImp = (importance$MeanDecreaseGini/importance.max)*100
varImportance <- data.frame(Variables = row.names(importance), Importance = round(importance$RelImp))
# Use ggplot2 to visualize the relative importance of variables, colored by Importance
ggplot(varImportance, aes(x= reorder(Variables, Importance), y = Importance)) + geom_bar(data = varImportance, stat = "identity", aes(fill = Importance)) + scale_fill_gradientn(colours = matlab.like2(16)) + xlab("Variables") + ylab("Relative Importance %") + coord_flip() + theme_few()
dev.off()

# arrange vars by decreasing importance
# partial plots of first 5 most important variables
imp.var = rownames(importance)[order(importance[, 1], decreasing = T)]
imp.var[1:10]
importance.first.five = imp.var[1:5]
par(mfrow = c(3, 2))
for (i in seq_along(importance.first.five)) {
  partialPlot(rf.firefly, firefly.train, x.var = importance.first.five[i], xlab=importance.first.five[i], main=paste("Partial Dependence on", importance.first.five[i]))
}
dev.off()


# identify genus based on color and flash pattern

# create a subset containing only male firefly
firefly.male = firefly[which(firefly$Fly.Location == 'Flying'), ] 
attr.firefly = data.frame(firefly.male[, c(3, 4, 50, 51)])
colnames(attr.firefly) = c("lat", "lon", "col", "flash")

# replace "No" color with most common
attr.firefly$col = as.character(attr.firefly$col)
attr.firefly$col[attr.firefly$col == "No"] = "Yellow green"
# remove "No" flash and "0" color observations
attr.firefly$col[attr.firefly$col == "0"] = NA
attr.firefly$flash = as.character(attr.firefly$flash)
attr.firefly$flash[attr.firefly$flash == "No"] = NA
na.omit(attr.firefly)

# convert back to factor
i = sapply(attr.firefly, is.character)
attr.firefly[i] = lapply(attr.firefly[i], as.factor)

# cross tab col and flash
table(attr.firefly[, c("col", "flash")])

# identify genus
attr.firefly$genus = ifelse(attr.firefly$col == "Yellow green", "Photinus", ifelse(attr.firefly$col == "Orange", "Pyractomena", ifelse(attr.firefly$col == "Green" & attr.firefly$flash == "Single", "Photinus", "Photuris")))
table(attr.firefly$genus, attr.firefly$flash)


# Plot the genus on the map of USA
# get map of USA
mapusa = get_map(location = c(lon = mean(firefly$Longitude), lat = mean(firefly$Latitude)), zoom = 5, color = "bw")
# plot genus on map
ggmap(mapusa) + geom_point(data = attr.firefly, aes(x = lon, y = lat, color = genus, alpha = 0.5),na.rm = T, shape = 20) + scale_colour_manual(values = c("greenyellow", "green4", "darkorange1")) + guides(fill=FALSE, alpha=FALSE, size=FALSE)

# Plot hea map of population distribution 
# get map of USA
mapusa = get_map(location = c(lon = mean(firefly$Longitude), lat = mean(firefly$Latitude)), zoom = 5, color = "bw")
# heat map of population
ggmap(mapusa) + geom_density2d(data = firefly, aes(x = Longitude, y = Latitude)) + stat_density2d(aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, data = firefly, geom = "polygon") + scale_fill_gradient(low = "green", high = "red")+ theme(legend.position = "none", axis.title = element_blank(), text = element_text(size = 12))

# plot genus on map
ggmap(mapusa) + geom_point(data = attr.firefly, aes(x = lon, y = lat, color = genus, alpha = 0.5),na.rm = T, shape = 20) + scale_colour_manual(values = c("greenyellow", "green4", "darkorange1")) + guides(fill=FALSE, alpha=FALSE, size=FALSE)

# plot flowchart for genus identification  
grViz("
      digraph DAG {
      
      # Intialization of graph attributes
      graph [overlap = true]
      
      # Initialization of node attributes
      node [shape = box,
      fontname = Helvetica,
      color = black,
      type = box,
      fixedsize = T]
      
      # Initialization of edge attributes
      edge [color = black, fill = yellow
      rel = yields]
      
      # Node statements
      Color; YellowGreen;Orange;Green;SingleFlash;Yes;No;
      # Revision to node attributes
      node [shape = circle,
      fontname = Helvetica,
      color = red,
      fixedsize = F]
      # Node statements
      Photinus;Pyractomena;Photuris
      
      # Edge statements
      Color->YellowGreen; Color->Orange; Color->Green; Green->SingleFlash; SingleFlash->Yes; SingleFlash->No; 
      # Revision to edge attributes
      edge [color = red]
      # Edge statements
      YellowGreen->Photinus;Orange->Pyractomena;Yes->Photinus;No->Photuris
      }
      ")