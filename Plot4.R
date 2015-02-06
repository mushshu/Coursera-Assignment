# This script provides a function for getting and preprocessing the required 
# two-day usage data. If the data file is not found in the current directory, 
# it will be downloaded and unzipped first. 
get_twoday_powerusage <- function() { 
  if(!  file.exists("household_power_consumption.txt")){ 
    download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip",destfile="housepower.zip",method="wget") 
    system("unzip housepower.zip") 
  } 
  ## Read in the table (I tried fread from data.table, but it didn't seem to handle using "?" as NA) 
  powerusage <- read.table("household_power_consumption.txt",header=TRUE,colClasses=c("character","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric"),na.strings=c("?"),sep=";") 
  # Convert Date to actual date format 
  powerusage$Date <- as.Date(powerusage$Date, "%d/%m/%Y") 
  # Subset for chosen dates 
  twoday_usage  <- subset(powerusage, powerusage$Date == "2007-02-01" | 
                            powerusage$Date == "2007-02-02") 
  # Create new DateTime column that contains both date and time to use for plotting 
  twoday_usage$DateTime <- paste(twoday_usage$Date, twoday_usage$Time) 
  twoday_usage$DateTime <- strptime(twoday_usage$DateTime, format="%Y-%m-%d %H:%M:%S") 
  return(twoday_usage) 
} 

#Plot 4

if( ! exists("usage") ){ 
source("twoday_usage.R") 
usage <- get_twoday_powerusage() 
} 
# Create new graphics device for the fourth plot 
png("plot4.png") 
# Set line-width (so that legend will show lines) 
par(lwd=1) 
# Set up device to display four plots (filling columns first) 
par(mfcol=c(2,2)) 
# Top left plot (Global_active_power time series) 
plot(usage$DateTime,usage$Global_active_power,type="n",ylab="Global Active Power",xlab="") 
lines(usage$DateTime,usage$Global_active_power,col="black") 
# Bottom left plot (Sub metering time series) 
plot(c(usage$DateTime,usage$DateTime,usage$DateTime),                   # x values 
c(usage$Sub_metering_1,usage$Sub_metering_2,usage$Sub_metering_3), # y values 
ylab="Energy sub metering",        # y-axis title 
xlab="",                           # No title for x-axis 
type="n"                           # Don't draw it yet 
) 
lines(usage$DateTime,usage$Sub_metering_1,col="black")      # Draw sub metering 1 
lines(usage$DateTime,usage$Sub_metering_2,col="red")        # Draw sub metering 2 
lines(usage$DateTime,usage$Sub_metering_3,col="blue")       # Draw sub metering 3 
# Draw legend 
legend("topright",                      # Position of legend 
col=c("black","red","blue"), 
legend=c("Sub_metering_1","Sub_metering_2", "Sub_metering_3"), 
lty=c(1),    # Show data lines in legend 
bty="n"      # Don't show a box around the legend 
) 
 # Top right plot (Time series for Voltage) 
plot(usage$DateTime,usage$Voltage,type="n",ylab="Voltage",xlab="datetime") 
lines(usage$DateTime,usage$Voltage,col="black") 
# Bottom right plot (Time series for Global_reactive_power) 
plot(usage$DateTime,usage$Global_reactive_power,type="n",xlab="datetime",ylab="Global_reactive_power") 
lines(usage$DateTime,usage$Global_reactive_power,col="black") 
dev.off() 
