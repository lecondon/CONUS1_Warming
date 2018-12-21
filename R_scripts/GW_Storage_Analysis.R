rm(list=ls())
setwd("/Users/laura/Documents/CONUS/Warming_Runs")
library(raster)
library(maptools)
library(fields)
library(RColorBrewer)
source("~/Documents/R_Functions/PFB-ReadFcn.R")

######################
#Setup
plotdir="./Figures_December18/"

dir="./Simulation_Averages"
runlist=c(0,2,4)
ylist=4:7
nyear=length(ylist)
nrun=length(runlist)

varlist=c("storage", "LH")

#Domain info 
nx=3342
ny=1888
nval=nx*ny

#make xy arrays
ncell=nx*ny
x=rep(1:nx, ny)
y=rep(1:ny, each=nx)

#Making xy vectors with the UTM coordinates
xll=-1884563.7545319
yll= -605655.0023757
xUTM=x*1000+xll
yUTM=y*1000+yll

# Latent Heat of vaporization 
lvap= 2.5104*10^6 # J/kg n- this is the value for 'hvap' in pfsimulator/clm/clm_varcon.F90 
#to convert from W/m2 to mm/hr
# w/m2= J/(s*m2) 
# LH (j/(s*m2)) / lvap (J/kg) = kg/(m2*s) /(1000 kg/m3) = m *1000 =mm
# so just multiply by 3600/lvap to get mm   

##########################################
#Some useful layers to include in plots
domainshp=readShapeSpatial("/Users/laura/Documents/CONUS/Shape_Files/Domain_shp/Domain_short.shp")
regshp=readShapeSpatial("/Users/laura/Documents/CONUS/Shape_Files/Regions_shp/Regions_Project.shp")
#statshp=readShapeSpatial("/Users/laura/Documents/CONUS/Shape_Files/States/states_epa_project.shp")
statshp=readOGR("/Users/laura/Documents/CONUS/CONUS-GIS/States/states_epa_project.shp")
greatlakes=readShapeSpatial("/Users/laura/Documents/CONUS/Shape_Files/GreatLakes/great_lakes", proj4string=CRS("+proj=merc +lon_0=0 +lat_ts=0 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +units=m +no_defs"))
#Project to UTM
greatlakesUTM=spTransform(greatlakes,CRS("+proj=lcc +lat_1=33 +lat_2=45 +lat_0=39 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs "))

#########################
#Reading inputs
#Read in the LH flux data - this is annual average [w/m2]
lh=array(NA, dim=c(nval, nyear, nrun))
for(r in 1:nrun){
	print(r)
	for(y in 1:nyear){
		print(paste("Year:", y))
		
		fin=sprintf("%s/Temp%d_Year%d/LH.yearly.bin", dir,runlist[r], ylist[y])
		print(fin)
		to.read = file(fin, "rb")
		header=readBin(to.read, integer(), endian = "little", size=4, n=3)
		lh[,y,r]=readBin(to.read, double(), endian = "little", size=8, n=nval)
		close(to.read)	
	} #end for y
} #end for r

#convert from annual average W/m2
lhmm=lh/lvap*3600*24*365 

#Get the simulation totals
lhmm_tot=matrix(NA, nrow=nval, ncol=nrun)
for(r in 1:nrun){ 
	lhmm_tot[,r]=apply(lhmm[,,r], 1, sum )
}

#Read in the year end storage - month 12 average storage m3
storend=array(NA, dim=c(nval, nyear, nrun))
for(r in 1:nrun){
	print(r)
	for(y in 1:nyear){
		print(paste("Year:", y))
		
		fin=sprintf("%s/Temp%d_Year%d/storage.monthly.12.bin", dir,runlist[r], ylist[y])
		print(fin)
		to.read = file(fin, "rb")
		header=readBin(to.read, integer(), endian = "little", size=4, n=3)
		storend[,y,r]=readBin(to.read, double(), endian = "little", size=8, n=nval)
		close(to.read)	
	} #end for y
} #end for r

storendmm=storend/(1000^2)*1000 #convert from m^3 to mm
stordif=storendmm[,4,2:nrun]-storendmm[,4,1] #difference in ending storage

#########################
#Analysis and plotting

####################
# Year 4 ending storage differences
fout=paste(plotdir, "Ending_Storage_Diff.pdf", sep="")
pdf(fout, width=8.1, height=8.9)
par(mfrow=c(2,1), mar=c(1,2,3,3))

maxz=0
minz=-100

#2 degree 
plottemp=stordif[,1]
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=rev(brewer.pal(name="YlOrRd", n=5)), colNA='lightblue',  legend=T, main="2 Degree Ending Storage dif [mm]", axes=F, zlim=c(minz, maxz))

#4 degree 
plottemp=stordif[,2]
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=rev(brewer.pal(name="YlOrRd", n=5)), colNA='lightblue',  legend=T, main="4 Degree Ending Storage dif [mm]", axes=F, zlim=c(minz, maxz))

dev.off()


####################
# 4 year total LH differences
fout=paste(plotdir, "LH_Total_Diff.pdf", sep="")
pdf(fout, width=8.1, height=8.9)
par(mfrow=c(2,1), mar=c(1,2,3,3))

maxz=1000
minz=0

#2 degree 
plottemp=lhmm_tot[,2]-lhmm_tot[,1]
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=brewer.pal(name="YlGnBu", n=10), colNA='lightblue',  legend=T, main="2 Degree Total LH Difference [mm]", axes=F, zlim=c(minz, maxz))

#4 degree 
plottemp=lhmm_tot[,3]-lhmm_tot[,1]
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=brewer.pal(name="YlGnBu", n=10), colNA='lightblue',  legend=T, main="2 Degree Total LH Difference [mm]", axes=F, zlim=c(minz, maxz))

dev.off()


####################
# Storage change/LH increase
fout=paste(plotdir, "Storage_LH_Ratio.pdf", sep="")
pdf(fout, width=8.1, height=8.9)
par(mfrow=c(2,1), mar=c(1,2,3,3))

maxz=0.5
minz=0

#2 degree 
plottemp=(-stordif[,1])/(lhmm_tot[,2]-lhmm_tot[,1]) #year for ending storage dif/ total LH dif
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=brewer.pal(name="YlGnBu", n=10), colNA='lightblue',  legend=T, main="2 Degree stordif/LH dif [mm]", axes=F, zlim=c(minz, maxz))

#4 degree 
plottemp=(-stordif[,2])/(lhmm_tot[,3]-lhmm_tot[,1])
plottemp[which(plottemp>maxz)]=maxz
plottemp[which(plottemp<minz)]=minz
rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
plot(rastertemp1, maxpixels=(nx*ny*10), col=brewer.pal(name="YlGnBu", n=10), colNA='lightblue',  legend=T, main="2 Degree stordif/LH dif[mm]", axes=F, zlim=c(minz, maxz))

dev.off()






