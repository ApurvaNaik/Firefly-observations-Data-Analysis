# Exploring the Firefly Observations dataset
#### * By Apurva Naik on April 11, 2016 *
#### This [dataset](https://legacy.mos.org/fireflywatch/data_analysis) is maintained and updated by the Museum of Science, Boston
### 1. Introduction
When most of us think about our childhood and summers, many things come to our mind. We might think about ice creams, the 4th of July fireworks or the deafening chirruping of the crickets. What comes most prominently to my mind is my firefly lantern! I used to roam around in the meadows near my house at twilight and collect as many fireflies as I could in my glass bottle just to see them twinkle at night before I went to bed. (Of course, having a conscientious mother, I would release them first thing in the morning!). So, when the time came to crunch some data, I knew what I was going to look for! There is much that we don't know about what ecological and human-made factors affect firefly populations. The data collected for Firefly Watch can shed some light on this problem and maybe, we will gain a better understanding of the elements that influence survival of the fireflies.

The dataset contains all of the data from the 2008 - 2014 seasons. It is divided into three data sets: habitats, observations, and individual firefly reporting. This data is a collection of individual reporting from all over the USA and the world . The data set is very unclean: there is a lot of inconsistency, blank fields and redundancy.

In the first part of the report, I have cleaned the data and done some Feature Engineering to see which properties of the habitat are most important for sustaining firefly populations. In the second part, I've tried to classify the fireflies into different species and have plotted this on a map, based on the location coordinates in the dataset.

Each and every step has been explained in the code. Here, I will present some of my findings.

### 2. Exploring data
The heat map below shows the population distribution of fireflies in the country according to the [Fire Observations dataset.](https://legacy.mos.org/fireflywatch/data_analysis) It is clear that some areas in New England and the midwest are hotspots for these bugs. Proximity to a large water body seems to work in favor of the fireflies. I would like to see if this can be confirmed from the analysis.
![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/pop.usa.png)

#### Identifying the relevant predictors
I have  only included predictors describing the habitat and individual practices like lawn care and landscaping. It is important to include data about light sources since most fireflies find a mate by flashing. They must be able to see the flash of a prospective mate and return the flash and we'd like to determine if light plays a detrimental role in sustaining firefly population. Climate and location of the habitat play a crucial role, so these are also included in the analysis.

The dataset has 30785 rows and 53 columns. There are 52 predictors and 1 response variable, __Number.Seen.in.10.s__. I will input the correct number by multiplying the column values by 10 and rename the column to __Number__ for easy reference. The response variable __Number__ appears to be continuous variable, but is actually discontinuous between the intervals: 10, 20, 30, 40 and 50. Rather than keeping is as a numeric variable, I will converted it into a factor  __Population__.

I am interested in identifying the predictors necessary for sustaining firefly population. It makes sense to define the response variable that will take the value of 1 if __Population__ is  "High" (11 < __Number__) and 0 if __Population__ is "Low" (__Number__ < 10 ).

#### Identifying the missing values

The dataset was imported in such a way that all missing values, if any, were represented as NA. Checking for the number of NAs according to column:

Variable | Number of NAs
--- | --- | ---
State|22
Location|230
Your.Backyard.|230
Tree.Type|230
Creek.River..yards.away.|230
Pond.Lake..yards.away.|230
Freshwater.Marsh..yards.away.|230
Salt.Water.Marsh..yards.away.|230
Agricultural.Field..yards.away.|230
Cultivated.Bog..yards.away.|230
Golf.Course..yards.away.|230
Swimming.Pool..yards.away.|230
Man.made.Pool..yards.away.|230
Ocean..yards.away.|230
Is.the.Grass.Mowed.|230
Fertilized|230
Weed.Killer|230
Pesticides|230
Cast.Light|230
Street.Light..yards.away.|673
Light.Source..yards.away.|7838

22 predictors have NAs. For the predictors __Light.Source..yards.away.__ NA values comprise of about 25% of all their observations! This cannot be good for our classification problem.
##### Missing value treatment

 - Mode imputation: In this method we will fill the missing values with the most common value in that column.
 - __Light.Source..yards.away.__ This predictor has nearly 25% missing values. Any kind of imputation can add more bias to the model, so it is best to exclude this predictor from our analysis. This is vey unfortunate, since this predictor might be quite important.
 - __Street.Light..yards.away.__ This predictor has just above 2% missing values, so we will go ahead and replace them with the mode of that column.

- Deletion of missing values: Now, the maximum number of missing values any column has is 230, which is less than 2 % of the total data. Also, since most columns have exactly 230 values missing, they are most probably in the same rows. Removing these values from our analysis will not be detrimental to the outcome, so we'll go ahead and delete the rows containing these missing values.

##### Feature Engineering for better representation of variables
After converting all character variables to factor, we see that some variables like __State__ and __Country__ have many levels.

![Alt text](https://github.com/ApurvaNaik/Firefly-observations-Data-Analysis/blob/master/img/image1.png?raw=true)

From the above figure we see that some variables appear more number of times than other. We will 'bin' these frequently occurring variables and group the ones that appear rarely.
#### Identifying the most important predictors
Here, I have to visualized __Population__ with respect to the categorical predictors:

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/cat.plot1.png)
![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/cat.plot3.png)
![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/cat.plot2.png)

Nnow, visualizing the correlation between the numerical predictors. There is a strong correlation between __Habitat.ID__ and __Year__.
![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/cont.plot.png)


The most promising predictors with respect to habitat properties include
__Your.Backyard.__,
__Grassy__,
__Wetland__,
__Forest__,
__Cropland__,
__Pasture__,
__Beach__,
__Hedge.Rows.Thick.Shrubs__,
__Tall.Grass__,
__Tree.Type__,
__Creek.River..yards.away.__,
__Freshwater.Marsh..yards.away.__,
__Salt.Water.Marsh..yards.away.__,
__Agricultural.Field..yards.away.__,
__Cultivated.Bog..yards.away.__,
__Golf.Course..yards.away.__,
__Swimming.Pool..yards.away.__,
__Man.made.Pool..yards.away.__,
__Ocean..yards.away.__,
__Is.the.Grass.Mowed.__,
__Fertilized__,
__Weed.Killer__,
__Pesticides__,
__Street.Light..yards.away.__ and
__newFactorCountry__. All numerical redictors are also included in the analysis.

### 3. Using decision trees to identify the most important predictors
I'm using random forest to find out the factors most important for survival of fireflies.
In case of random forest, there is no need to split the data into trainig and test sets, because the model does that for us. only a subset of the total data is used for fitting. The remaining observations (also known as Out Of Bag observations) are used to test the fit. The resulting OOB error can then be used to evaluate the model.

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/errplot.rf.firefly.png)
#### Evaluating performance of the model

 With the inclusion of all relevant predictors, the error plot indicates the model is doing a fair job. This is concluded from the OOB error which is about 0.16.

 Using the __prop.table()__ function, I have found out that 80% of the observations belong to class "High" of the __Population__ response. If I have no further information, the probability for the the firefly population to belong to the class "High" is 80%. This means that there is a 20% chance that the observation will be classified into the wrong class, giving me an error of 0.2. The OOB error for the model is 0.16, implying the model missclassified the observation 16 out of 100 times. the model does better than random guessing!

#### Improving the performance  of the model

Model performance depends on the predictors. According to rule of thumb, performance improves as number of predictors increase. However, this can also lead to overfitting of data, which increases the OOB error. Random forests are generally immune from highly correlated predictors, yet it can be helpful to exclude predictors which repeat the information.

For example, in the Firefly Observations dataset, __Latitude__, __Longitude__, __Habitat.ID.__, __State__ and __Country__ contain basically the same information in different forms: Location.

The __importance()__ function can be used to see which are the most influential predictors based on their mean decrease in prediction accuracy. The importance plot shows the relative importance of the predictors with respect to the Gini Index. From the importance plot, it is clear, and not surprising that temperature and location play an important role. The strong correlation between the location predictors might dominate the less strong, yet more important predictors that appear lower on the plot. This can lead to us drawing wrong conclusions.

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/impPlot.rf.firefly.png)

###### *Will it help if we remove all the location predictors and keep only __Latitude__ and __Longitude__?*
The error plot indicates the model is performing better after removing the __Habitat.ID.__, __State__ and __Country__. The OOB error is 0.13, an improvement from the previous model! This also confirms our suspicion about high correlation between the excluded predictors.

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/errplot.rf.firefly.clean.png)

Looking at the importance plot, as expected, the important predictors are related to temperature and location. __Year__ is not too far behind indicating that there were some warm summers when the firefly population exploded. Human activity like lawn mowing and using pesticides is also fairly important.

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/impPlot.rf.firefly.clean.png)

#### Reassessing the importance of predictors
This is done by examining the partial dependence plots. A partial dependence plot shows graphically, the marginal effect of a predictor on the class probability when all the other predictors are held at a constant value. The figure below shows single-variable partial dependence plots of the most relevant population predictors. The y axis of the plots are nearly the same, and give a visual comparison of the relative importance of the different predictors.

![Alt text](https://raw.githubusercontent.com/ApurvaNaik/Firefly-observations-Data-Analysis/master/img/partialPlot.png)

The first figure shows the partial dependence of __Population__ on __Month__. The curve ranges from 0.5 to nearly 3.5 on the Y axis. No other curve has a comparable range, thus confirming the fact that __Month__ is the most important predictor.
__Population__ seems to have a non-monotonic partial dependence on __Month__, indicating that the dependence is the strongest for the months from May to August. In contrast, the partial dependence on __Temperature..F.__ is monotonic increasing, being nearly linear over the main body of the data. The partial dependency on __Latitude__ and __Longitude__ is relatively weak, indicated by the range of the Y axis.

The hash marks at the base of each plot delineate the deciles of the data distribution of the corresponding variables. Note that here the data density is lower near the edges, especially for larger values. This causes the curves to be somewhat less well determined in those regions.

### 4. Conclusion
From our analysis we conclude that climate and location of the habitat are extremely important for the survival of fireflies.  in maintaining moisture levels. Human activity also plays an important role, though not as much as climate. From the heat map, it seemed that proximity to the ocean or a huge lake might play an important role, but this was not the case, since __Ocean..yards.away._ features quite low in the importance plot. However, since variables like __Creek.River..yards.away.__ and __Swimming.Pool..yards.away.__ feature way up, sources of water do play an important role in maintaining favorable environment. The moist soil and air near the water source are essential for the [survival](https://legacy.mos.org/fireflywatch/environmental_factors) of the firefly larvae.
