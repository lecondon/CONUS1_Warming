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

##########################################
#Merge US and Canadian HUCs and format into a vector for grouping
#Read in the HUCS
#NOTE- These are the older text files the HUC8 didn't line up perfectly with the USGS gdb file I had and they were cut off at the US border so I remade the HUC8 raster in QGIS in the CONUS_Warming.qgs workspace in this main directory. 
#HUC8=matrix(scan("/Users/laura/Documents/CONUS/Domain_TextFiles/HUC_8.format.txt", skip=1))
#HUC4=matrix(scan("/Users/laura/Documents/CONUS/Domain_TextFiles/HUC_4.format.txt", skip=1))
HUCrast=raster("/Users/laura/Documents/CONUS/CONUS-GIS/HUC8/HUC8_Clip_Raster.tif")
HUCmat=as.matrix(HUCrast)
HUC8=rep(0, nx*ny)
kk=1
for(j in ny:1){
  for(i in 1:nx){
    HUC8[kk]=HUCmat[j,i]
    kk=kk+1
  }	
}
HUC=HUC8 #choosing which HUC to work with

#plottemp=HUC
#maxz=150
#minz=0
#plottemp[which(plottemp>maxz)]=maxz
#plottemp[which(plottemp<minz)]=minz
#rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM, plottemp))
#plot(rastertemp1, maxpixels=(nx*ny*10), colNA='lightblue',  col=rev(brewer.pal(name="Spectral", n=11)), legend=T, main="HUC_map", axes=F, zlim=c(minz, maxz))


# Create a combined HUC file with the Candian NHN files
CanNHN=raster("/Users/laura/Documents/CONUS/CONUS-GIS/NHN_INDEX_WORKUNIT_LIMIT_2/NHN_Raster_Temp.tif")
Canmat=as.matrix(CanNHN)
NHN_vec=rep(0, nx*ny)
kk=1
for(j in ny:1){
  for(i in 1:nx){
    NHN_vec[kk]=Canmat[j,i]
    kk=kk+1
  }	
}

HUC_Merge=HUC
#fixlist=which(HUC==(-999) & NHN_vec>0) #for previous HUC matrix where where the NAs were -999
fixlist=which(HUC==(0) & NHN_vec>0) 
HUC_Merge[fixlist]=NHN_vec[fixlist]+3000 #I created a numbering system for the canadian HUCS starting counting at 10 so I'm adding 3000 here so the Canadian numbers don't overlap with the US ones
#rastertemp1=rasterFromXYZ(cbind(xUTM, yUTM,HUC_Merge))
#plot(rastertemp1, maxpixels=(nx*ny*10), colNA='lightblue',  col=rev(brewer.pal(name="Spectral", n=11)), legend=T, main="Baseline PET", axes=F, zlim=c(0,4400))


##########################################
#Other layers
#Porosity for calculating PET
porosity=readpfb("./Simulation_Averages/CONUS.5layer.pfclm.PumpHS.run4.out.porosity.pfb", verbose=F)
porosity1=as.vector(porosity[,,5])
image.plot(porosity1)

#Read in the precipitation
fin="/Users/laura/Documents/CONUS/Transient_Runs/Forcing_Averages/precip.yearly.bin"
to.read = file(fin, "rb")
header=readBin(to.read, integer(), endian = "little", size=4, n=3)
precip=readBin(to.read, double(), endian = "little", size=8, n=nval)
close(to.read)

#I think the units of precip are mm/s and the yearly file is average
precipmm=precip*3600

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
#Caclculate PET using Beta

#Cacluate Beta and PET based on Beta
beta=PET=array(NA, dim=c(nval, nyear, nrun))
for(r in 1:nrun){
  print(r)
  for(y in 1:nyear){
      beta[,y,r]=((lhmm[,y,r]/porosity1)-0.2)/0.8
      beta[(beta[,y,r]<0),y,r]=0 #getting rid of the negative values where the saturation is less than sres
      PET[,y,r]=lhmm[,y,r]/beta[,y,r]
  }
}

#########################
#Aggregate by HUC
HUC_list=sort(unique(HUC_Merge))
nhuc=length(HUC_list)

#HUC Summary matrices
precipmm_HUC=area_HUC=rep(0, nhuc) #Summary matrix with a row for every HUC
lhmm_HUC=storendmm_HUC=array(0, c(nhuc, nyear, nrun))
stordif_HUC=matrix(0, nrow=nhuc, ncol=(nrun-1))

#HUG grid matrices
lhmm_Hgrid=storendmm_Hgrid=array(0, c(nval, nyear, nrun)) #matrix assigning the HUC sum value to every grid cell
stordif_Hgrid=array(0, c(nval, nrun-1) )#matrix assigning the HUC sum value to every grid cell
precipmm_Hgrid=area_Hgrid=rep(0, nval)
                     
#summing all of the matrix values
for(h in 1:nhuc){
  print(h)
  hnum=HUC_list[h]
  ilist=which(HUC_Merge==hnum)
  
  #Recording the HUC sums in the HUC matrix
  area_HUC=length(ilist)
  
  if(length(ilist)>1){
    #Precipitation
    precipmm_HUC[h]=sum(precipmm[ilist])
    precipmm_Hgrid[ilist]= precipmm_HUC[h]
    
    #lhmm and storend sums
    for(r in 1:nrun){
      for(y in 1:nyear){
        lhmm_HUC[h,y,r]=sum(lhmm[ilist, y, r])
        lhmm_Hgrid[ilist,y,r]=lhmm_HUC[h,y,r]
          
        storendmm_HUC[h,y,r]=sum(storendmm[ilist, y, r])
        storendmm_Hgrid[ilist,y,r]=storendmm_HUC[h,y,r]
      }
    }
    
    #stordif sum
    for(r in 1:(nrun-1)){
      stordif_HUC[h, r]=sum(stordif[ilist, r])
      stordif_Hgrid[ilist, r]=stordif_HUC[h, r]
    }
  } #end if
  
}

#zeroing out the valuse for the -999 HUC
stordif_HUC[1,]=NA
storendmm_HUC[1,,]=NA
lhmm_HUC[1,,]=NA
precipmm_HUC[1]=NA

ilist=which(HUC_Merge==HUC_list[1])
stordif_Hgrid[ilist,]=NA
storendmm_Hgrid[ilist,,]=NA
lhmm_Hgrid[ilist,,]=NA
precipmm_Hgrid[ilist]=NA


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






