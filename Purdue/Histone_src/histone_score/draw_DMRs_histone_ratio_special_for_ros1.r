# R --slave --vanilla --args indir png_pre  < R_script.r
# R --slave --vanilla --args input outpre outdir < R_script.r
args = commandArgs( trailingOnly =  T)  
#indir		= args[1]
input		=args[1]
png_pre		= args[2]
outdir		= args[3]

#setwd(outdir)

cex_lab = 2
cex_axis = 1.8
cex_axis_plot = 1.5
mgp =  c(5, 0.8, 0)

width_val = 8# 3.8; 
height_val = 11#4;
units_val = "in"; res_val = 500; pointsize_val =8;

file_name = paste(outdir, "/", png_pre , "_w", width_val, "_h", height_val, "_res", res_val, "_pt", pointsize_val, ".png", sep="")
png(file_name, width = width_val, height = height_val, units = units_val , res = res_val, pointsize = pointsize_val );

par(oma = c(3, 3, 1, 0) ) #down left up rigth
par(mar = c(2, 10 , 2, 1) + 0.1)

#par(mar = c(4, 4 , 4, 1) + 0.1)
#par(mar = c(6, 6 , 2, 1))

gray_col = "gray70"
lwd_abline = 1.5

las_val = 1; # axis labels horizontal or vertical

x = read.table(input, head=T,sep="\t")
names(x) = sub("(.+).bam", "\\1",  names(x) , perl =T)
#sub("(.+).bam", "\\1",y, perl =T)

#layoutmat =  matrix(1:12,ncol = 3);
layoutmat =  matrix(1:10,ncol = 2,byrow=T);
layout(layoutmat); 
#for (i in 2:11) {
for (i in c(11, 6, 7,8,9,10, 2:5)){
	plot (x[,1],x[,i]/x[,12], type="l",col="blue", xaxt="n", las = las_val,xlab="", ylab = colnames(x)[i], cex.lab= cex_lab, cex.axis = cex_axis_plot, mgp = mgp) ; 
   #ylab="", xlab = colnames(x)[i])
	abline(v=41, lty= "dotted") 
	axis(1, at = c(1,41,81), labels=c("-2kb","Midpoint","+2kb"), cex.axis=cex_axis)
}

#axis

dev.off()



if(FALSE){
length = length(files)
x_lables =  sub("(.+)_DMRs_.+.txt", "\\1", files, perl =T)

max_y = max (unlist(lapply(x_data, function(x) max(x[,4 ]) ) ) )  #

if(FALSE){
cols_db =  c( 
#rgb(153, 153, 153, maxColorValue = 255), #grey
rgb ( 222,147,142 ,maxColorValue = 255 ), #edm2 red
rgb (200,226, 126  ,maxColorValue = 255 ), # ibm1 green
rgb ( 160, 132, 200  ,maxColorValue = 255 ) # rdd purple

#rgb( 0, 255, 255, maxColorValue = 255)   #blue

)
}
cols_db =  c( 
#rgb(153, 153, 153, maxColorValue = 255), #grey
rgb ( 222,147,142 ,maxColorValue = 255 ), #edm2 red

#rgb (200,226, 126  ,maxColorValue = 255 ), # ibm1 green
rgb (177,199,112  ,maxColorValue = 255 ), # ibm1 green for ibm2paper


#rgb ( 160, 132, 200  ,maxColorValue = 255 ) # rdd purple

rgb ( 142,120,176  ,maxColorValue = 255 ), # ibm2paper ibm2 purple

#rgb ( 160, 132, 200  ,maxColorValue = 255 ) # rdd purple for edm2Paper
rgb ( 127,184,207 ,maxColorValue = 255 ) # rdd blue for edm2Paper


#rgb( 0, 255, 255, maxColorValue = 255)   #blue

)


cols = cols_db[1:length];



#plot( y[,5],y[,4], type="l" , col = "blue", ylab = "Number of DMRs / 500kb",  xaxt="n", cex.lab =  1.5, xlab="", cex.axis = 1.5, cex.main = 2, lwd = 2 )
# lines(x[,5],x[,4],col="red",lwd = 2 )

plot( x_data[[1]][,5] , x_data[[1]][,4] , 
		ylim = c(0, max_y),
		type="l" , 
		col = cols_db[1], 
		ylab = "Number of DMRs / 500kb", 
		font.lab = 2,
	xlab = "Chromosome",
#xlab="", 
		xaxt="n", 
		cex.lab =  1.5, 
		cex.axis = 1.5, 
		cex.main = 2, 
		lwd = 2,
		las = 1
)
for (i in 2:length(files)){
	lines(x_data[[i]][,5] , x_data[[i]][,4] , 
		  col= cols_db[i],
		  lwd = 2 
		  )
}


#> x = c(30427671, 19698289, 23459830, 18585056, 26975502 );
#> sum(x[1:2])
#[1] 50125960
#> sum(x[1:3])
#[1] 73585790
#> sum(x[1:4])
#[1] 92170846
#> sum(x[1:5])
#[1] 119146348

# 

abline( v = 30427671, col = gray_col , lwd = lwd_abline )
abline( v = 50125960, col = gray_col, lwd = lwd_abline )
abline( v = 73585790, col = gray_col, lwd = lwd_abline )
abline( v = 92170846 , col = gray_col, lwd = lwd_abline )

#centromere
# symbols(c(1,2,3,4,5),c(-15000000,-3600000,-13500000,-3920000,-11700000),circles=c(1,1,1,1,1),add=T,inches=0.08,fg="red",bg="red")

# chr_len = c(30427671, 19698289, 23459830, 18585056, 26975502 );

#0 + 15000000 
#>  30427671 + 3600000  
#[1] 34027671
#>  50125960 + 13500000
#[1] 63625960
#>  73585790 + 3920000
#[1] 77505790
#>  92170846 + 11700000
#[1] 103870846

par(xpd=NA)
text(x = c(15000000, 35027671 ,63625960 , 77505790,103870846  ), y= rep(-50,5) , labels = 1:5, cex = 1.5)
legend (   3050207, -132,
		legend= x_lables, 
		col = cols,
		lwd = 2,
		bty = "n",
		cex = 1.5,
		ncol = length
)

dev.off()

}