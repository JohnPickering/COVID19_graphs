# COVID19_graphs
COVID19_graphs
Graphs showing the number of days needed to double the number of COVID-19 cases or deaths per country.  
For convenience separated into geographical areas.

The "Execute first.R" file has the code for extracting data from John Hopkins University (thanks JH Uni) and with the help of functions in covid_fns.R (not mine: from https://joachim-gassen.github.io/2020/03/tidying-the-john-hopkins-covid-19-data/) execute code to:

1. Classify countries according to geographical region.  This ca be used to determine which countries to graph togehter.  
2. Calculate the number of days needed to double.  This is simply the inverse of the slope of the Case v Time (& Death v Time) graphs.  I use simply the  latest days change to the previous days cumulative total to calculate the slope.  Because I'm doubling I just invert this to get the numebr of days to double.  If you want the number of day to triple you'll need to adjust.
3. Because this slope is really between days I adjust ndays by -0.5.
4. I output Rdata files for cases where the number of days is counted from the day they first exceeded 100 for a country.  
5. I output Rdata files for deaths where the number of days is counted from the day they first exceeded 10 for a country.  

The Rmd files are examples of creating the graphs by geographical region.
Note:
1. I use splines with 3 knots for the smoothing (blue lines on the graphs).  Eventually more knots may need to be added. 
2. The shaded area is the 95% confidence interval of the smoothed line.  set se = FALSE to remove.  
3. I also plot the actual number of days needed to double (coloured points).  I think worth seeing as it gives a better idea of the accuracy of the fit.  
4. For Australia and New Zealand the John Hopkins data is ~12h behind so I manually add the latests information I have.  Gotta be careful here. 

I've uploaded some example graphs generated.  For a new day I just change the dates and away I go ....



