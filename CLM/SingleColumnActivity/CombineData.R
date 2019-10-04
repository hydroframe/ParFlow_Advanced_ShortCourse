# Process data for each time step
# Prepared for ParFlow Short Course
# 5.18.16

rm(list=ls())

stopt = 2184		#number of time steps

# Combine forcing data
directory1 = "/Users/JenJ/Desktop/Test_SC_Activity"
setwd(directory1)
source("PFB-ReadFcn.R")

clm_forc_out = matrix(NA,ncol=4,nrow=stopt)
colnames(clm_forc_out)=c("precip","air_temp","btran","can_temp")

fin = "narr_1hr.txt"
data = matrix(scan(fin,skip=0,nlines=stopt), ncol=8, byrow=T)
clm_forc_out[,1] = data[,3]
clm_forc_out[,2] = data[,4]

directory = "./LW_SC"
setwd(directory)

clm_dat = matrix(NA,ncol=6,nrow=stopt)
colnames(clm_dat)=c("latentheat","evap_tot","evap_soi","evap_veg","tran_veg","t_grnd")

#Combine single file output and output variables
for(k in 1:stopt){
	#print(k)
	fin1=sprintf("LW_SC.out.clm_output.%05d.C.pfb",k) 
	data1=readpfb(fin1,F)
	clm_dat[k,1]=data1[1,1,1]		#total (really, it is net) latent heat flux (Wm-2)
	clm_dat[k,2]=data1[1,1,5]		#net veg. evaporation and transpiration and soil evaporation (mms-1)
	clm_dat[k,3]=data1[1,1,7]		#soil evaporation (mms-1)
	clm_dat[k,4]=data1[1,1,8]		#vegetation evaporation and transpiration (mms-1)
	clm_dat[k,5]=data1[1,1,9]		#transpiration (mms-1)
	clm_dat[k,6]=data1[1,1,12]		#ground temperature (K)
	}
write.table(clm_dat,file="LW_SC.clm_dat.txt",row.names=FALSE,col.names=TRUE)
#saveRDS(clm_dat,file="LW_SC.clm_dat.rds")	
	
fin2 = "LW_SC.out.txt"
data2 = matrix(scan(fin2,skip=8,nlines=stopt), ncol=3, byrow=T)	
clm_forc_out[,3] = data2[,2]
clm_forc_out[,4] = data2[,3]	
write.table(clm_forc_out,file="LW_SC.clm_forc_out.txt",row.names=FALSE,col.names=TRUE)

#Make plots
plot(clm_forc_out[,2]-clm_forc_out[,4],xlab="Hour Count (from September 1)",ylab="Temperature Difference (K)",type="l",col="gray50")
mtext("(air temperature - canopy temperature)",2,line=2)
abline(h=0,col="black")

plot(clm_dat[,5]*3600,xlab="Hour Count (from September 1)",ylab="Transpiration (mm/hr)",type="l",col="darkolivegreen")
abline(h=0,col="black")

par(mar=c(5,5,2,5))
plot(clm_forc_out[,3],ylim=c(0,1),xlab="Hour Count (from September 1)",ylab="Vegetation Water Stress Factor (-)",type="l",col="firebrick")
par(new=T)
plot(clm_forc_out[,1],col="dodgerblue",type="l",axes=F,xlab=NA,ylab=NA)
axis(4)
mtext(side=4,line=3,"Precipitation Rate (mm/s)")